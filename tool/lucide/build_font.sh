#!/usr/bin/env bash
set -euo pipefail

# =========================
# SETTINGS
# =========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ICON_FAMILY="LucideVariable"
WORKDIR="build_font"
SVG_INPUT_DIR="svg_input"
ICON_SOURCE_DIR="lucide-source"
ICON_METADATA_DIR="$ICON_SOURCE_DIR"
ASSET_FONT_DIR="../../assets/build_font"
BASE_FONT="../../assets/lucide.ttf"
if [[ -n "${BUILD_WEIGHTS:-}" ]]; then
  read -r -a WEIGHTS <<< "$BUILD_WEIGHTS"
else
  WEIGHTS=(100 200 300 400 500 600)
fi

if [[ -f "$ICON_SOURCE_DIR/codepoints.json" ]]; then
  ICON_CODE_JSON="$ICON_SOURCE_DIR/codepoints.json"
else
  ICON_CODE_JSON="../../assets/codepoints.json"
fi

# Đặt 1 để bỏ qua SVGO nếu muốn
SKIP_SVGO="${SKIP_SVGO:-0}"
# NORMALIZE_SVG modes:
#   auto: stroke-to-path only known fill-prone SVGs before FontForge import.
#   closed: stroke-to-path SVGs with closed paths, plus known fill-prone SVGs.
#   1:    stroke-to-path every SVG.
#   0:    import generated SVGs directly.
NORMALIZE_SVG="${NORMALIZE_SVG:-auto}"
AUTO_OUTLINE_ICONS="${AUTO_OUTLINE_ICONS:-anvil bluetooth bluetooth-connected bluetooth-off bluetooth-searching brain-circuit file-type fish lasso-select layers layers-plus library-big package-open palette podcast ribbon rocket ruler salad scale skull thermometer-snowflake tree-pine usb wheat wheat-off}"

# =========================
# DEP CHECK
# =========================
need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing: $1"; exit 1; }; }
need jq
need fontforge
INKSCAPE_BIN=""
if [[ "$NORMALIZE_SVG" == "1" || "$NORMALIZE_SVG" == "auto" || "$NORMALIZE_SVG" == "closed" ]]; then
  need inkscape
  INKSCAPE_BIN="$(command -v inkscape)"
fi
PYTHON_BIN=""
for candidate in "${PYTHON:-}" python3 python; do
  if [[ -z "$candidate" ]]; then
    continue
  fi
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" - <<'PY' >/dev/null 2>&1; then
import fontTools.ttLib
PY
    PYTHON_BIN="$candidate"
    break
  fi
done
if [[ -z "$PYTHON_BIN" ]]; then
  echo "❌ Missing Python package: fontTools"
  exit 1
fi
if [[ "$SKIP_SVGO" != "1" ]]; then
  if ! command -v svgo >/dev/null 2>&1; then
    echo "ℹ️  svgo not found (optional). Install for better SVG cleanup: npm i -g svgo"
  fi
fi

mkdir -p "$WORKDIR"
TMP_DIR="$(mktemp -d /private/tmp/lucide-font.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT
AUTO_OUTLINE_MATCH_FILE="$TMP_DIR/auto_outline_icons.txt"
ALIAS_MAP_FILE="$TMP_DIR/icon_aliases.tsv"
CODEPOINT_SHELL_FILE="$TMP_DIR/codepoints.sh"

# =========================
# HELPERS
# =========================

should_outline_svg() {
  local in_svg="$1"
  local base_name
  base_name="$(basename "$in_svg" .svg)"

  case "$NORMALIZE_SVG" in
    1)
      return 0
      ;;
    0)
      return 1
      ;;
  esac

  if grep -Fxq "$base_name" "$AUTO_OUTLINE_MATCH_FILE"; then
    return 0
  fi

  if [[ "$NORMALIZE_SVG" == "closed" ]]; then
    grep -Eq '<path[^>]*d="[^"]*[zZ][^"]*"' "$in_svg"
    return $?
  fi

  return 1
}

# Chuẩn hoá 1 SVG: stroke->path, object->path; tối ưu (nếu có svgo)
normalize_svg() {
  local in_svg="$1"
  local out_svg="$2"

  if should_outline_svg "$in_svg"; then
    # Inkscape chuyển stroke => filled outlines trước khi FontForge import,
    # tránh việc FontForge fill nhầm path đang có fill="none".
    "$INKSCAPE_BIN" "$in_svg" --export-filename="$out_svg" --export-type=svg \
      --actions="select-all:all;object-stroke-to-path;object-to-path;export-do" >/dev/null 2>&1
  fi

  # Default path: dùng SVG đã sinh trong svg_input trực tiếp để giữ flow nhanh,
  # đồng bộ với stroke-width đã generate cho từng weight.
  if [[ ! -s "$out_svg" ]]; then
    cp "$in_svg" "$out_svg"
  fi

  # Tối ưu bằng svgo (không để fail script)
  if [[ "$SKIP_SVGO" != "1" ]] && command -v svgo >/dev/null 2>&1; then
    # Thử cú pháp v3
    if ! svgo --multipass -q --output "$out_svg" "$out_svg" >/dev/null 2>&1; then
      # Thử cách gọi khác
      svgo --multipass -q "$out_svg" --output "$out_svg" >/dev/null 2>&1 || true
    fi
  fi
}

prepare_svg_dir_with_aliases() {
  local source_dir="$1"
  local prepared_dir="$2"

  mkdir -p "$prepared_dir"
  cp "$source_dir"/*.svg "$prepared_dir"/ 2>/dev/null || true

  while IFS=$'\t' read -r alias_name canonical_name; do
    local canonical_svg
    canonical_svg="$prepared_dir/${canonical_name}.svg"

    if [[ ! -f "$canonical_svg" ]]; then
      continue
    fi

    cp "$canonical_svg" "$prepared_dir/${alias_name}.svg"
  done < "$ALIAS_MAP_FILE"
}

prepare_codepoint_lookup() {
  PYTHONDONTWRITEBYTECODE=1 "$PYTHON_BIN" - "$ICON_CODE_JSON" > "$CODEPOINT_SHELL_FILE" <<'PY'
import json
import re
import sys

with open(sys.argv[1], encoding="utf-8") as file:
    codepoints = json.load(file)

for name, codepoint in sorted(codepoints.items()):
    if isinstance(name, str) and isinstance(codepoint, int):
        key = "CP_" + re.sub(r"[^A-Za-z0-9_]", "_", name)
        print(f"{key}={codepoint}")
PY

  # shellcheck source=/dev/null
  source "$CODEPOINT_SHELL_FILE"
}

# Đọc mã Unicode từ codepoints.json -> thập phân (trả "" nếu không có)
decode_unicode_dec() {
  local name="$1"
  local key="CP_${name//-/_}"
  eval "printf '%s\n' \"\${$key:-}\""
}

prepare_alias_map() {
  PYTHONDONTWRITEBYTECODE=1 "$PYTHON_BIN" - "$ICON_METADATA_DIR" > "$ALIAS_MAP_FILE" <<'PY'
import json
import sys
from pathlib import Path

for metadata_file in sorted(Path(sys.argv[1]).glob("*.json")):
    canonical_name = metadata_file.stem
    with metadata_file.open(encoding="utf-8") as file:
        metadata = json.load(file)

    for alias in metadata.get("aliases", []):
        if isinstance(alias, str):
            alias_name = alias
        elif isinstance(alias, dict):
            alias_name = alias.get("name", "")
        else:
            alias_name = ""

        if alias_name:
            print(f"{alias_name}\t{canonical_name}")
PY
}

prepare_auto_outline_matches() {
  : > "$AUTO_OUTLINE_MATCH_FILE"

  for icon_name in $AUTO_OUTLINE_ICONS; do
    echo "$icon_name" >> "$AUTO_OUTLINE_MATCH_FILE"
  done

  while IFS=$'\t' read -r alias_name canonical_name; do
    for icon_name in $AUTO_OUTLINE_ICONS; do
      if [[ "$canonical_name" == "$icon_name" ]]; then
        echo "$alias_name" >> "$AUTO_OUTLINE_MATCH_FILE"
        break
      fi
    done
  done < "$ALIAS_MAP_FILE"

  sort -u "$AUTO_OUTLINE_MATCH_FILE" -o "$AUTO_OUTLINE_MATCH_FILE"
}

# =========================
# BUILD PER WEIGHT
# =========================
if [[ ! -f "$ICON_CODE_JSON" ]]; then
  echo "❌ Missing codepoints file: $ICON_CODE_JSON"
  exit 1
fi

if [[ ! -d "$SVG_INPUT_DIR" ]]; then
  echo "❌ Missing SVG input folder: $SVG_INPUT_DIR"
  echo "   Run generate_variable_font.sh first."
  exit 1
fi

mkdir -p "$ASSET_FONT_DIR"
prepare_codepoint_lookup
prepare_alias_map
prepare_auto_outline_matches

echo "🔤 Building TTF fonts…"
echo "🔢 Codepoints: $ICON_CODE_JSON"
for weight in "${WEIGHTS[@]}"; do
  weight_dir="${SVG_INPUT_DIR}/weight${weight}"
  ttf_path="${WORKDIR}/${ICON_FAMILY}-w${weight}.ttf"

  if [[ ! -d "$weight_dir" ]]; then
    echo "⚠️  Skip weight ${weight}: folder not found -> ${weight_dir}"
    continue
  fi

  echo "📦 Generating TTF for weight ${weight}…"

  prepared_weight_dir="${TMP_DIR}/weight${weight}_with_aliases"
  prepare_svg_dir_with_aliases "$weight_dir" "$prepared_weight_dir"

  PE_FILE="$TMP_DIR/gen_w${weight}.pe"
  : > "$PE_FILE"

  cat >> "$PE_FILE" <<EOL
New()
SetFontNames("${ICON_FAMILY}", "${ICON_FAMILY}", "${ICON_FAMILY} w${weight}")
ScaleToEm(1000)
Reencode("unicode")
EOL

  i=0
  shopt -s nullglob
  missing_codepoints=()
  for svg in "$prepared_weight_dir"/*.svg; do
    base_name="$(basename "$svg" .svg)"
    glyph_name="$(echo "$base_name" | tr '-' '_' )"

    # Chuẩn hoá SVG trước khi import
    tmp_svg="$TMP_DIR/${base_name}_w${weight}.svg"
    normalize_svg "$svg" "$tmp_svg"

    # Mã unicode từ codepoints.json. Không fallback PUA để tránh lệch mapping
    # giữa Dart constants, CSS, unicode.html và TTF.
    unicode_dec="$(decode_unicode_dec "$base_name")"
    if [[ -z "$unicode_dec" || "$unicode_dec" == "null" ]]; then
      missing_codepoints+=("$base_name")
      continue
    fi

    codepoint="$unicode_dec"

    # Viết lệnh FontForge cho từng glyph
    cat >> "$PE_FILE" <<EOF
# ---- ${glyph_name} (U+$(printf '%04X' ${codepoint})) ----
Select(${codepoint});
Clear();
SetGlyphName("${glyph_name}");
Import("${tmp_svg}");

# Normalize paths (không dùng SelectWorthOutputting để tránh đổi selection)
RemoveOverlap();
CorrectDirection();
Simplify(0, 0);
AddExtrema();
RoundToInt();

# Chọn lại đúng glyph rồi gán unicode (tránh "More than one character selected")
Select(${codepoint});
SetUnicodeValue(${codepoint});
EOF

    i=$((i + 1))
  done
  shopt -u nullglob

  if [[ ${#missing_codepoints[@]} -gt 0 ]]; then
    echo "❌ Missing codepoints for weight ${weight}: ${missing_codepoints[*]}"
    exit 1
  fi

  # Sinh font
  cat >> "$PE_FILE" <<EOL
Generate("${ttf_path}")
Quit()
EOL

  fontforge -script "$PE_FILE" >/dev/null
  if [[ -f "$BASE_FONT" ]]; then
    "$PYTHON_BIN" fix_ttf_metrics.py --fallback-font "$BASE_FONT" "$ttf_path"
  else
    "$PYTHON_BIN" fix_ttf_metrics.py "$ttf_path"
  fi
  cp "$ttf_path" "$ASSET_FONT_DIR/"
  echo "✅  ${ttf_path}"
done

echo "🎉 Done. Output in: ${WORKDIR}/"
ls -1 "${WORKDIR}"/*.ttf 2>/dev/null || true
echo "✅ Synced TTF fonts to ${ASSET_FONT_DIR}"
