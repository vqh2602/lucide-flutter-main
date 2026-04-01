#!/usr/bin/env bash
set -euo pipefail

# =========================
# SETTINGS
# =========================
ICON_CODE_JSON="../../assets/info.json"  # JSON map tên icon -> encodedCode (vd: "\ue987")
ICON_FAMILY="LucideVariable"
WORKDIR="build_font"
SVG_INPUT_DIR="svg_input"
ICON_METADATA_DIR="lucide-source/icons"
WEIGHTS=(100 200 300 400 500 600)

# Đặt 1 để bỏ qua SVGO nếu muốn
SKIP_SVGO="${SKIP_SVGO:-0}"

# =========================
# DEP CHECK
# =========================
need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing: $1"; exit 1; }; }
need jq
need fontforge
need inkscape
if [[ "$SKIP_SVGO" != "1" ]]; then
  if ! command -v svgo >/dev/null 2>&1; then
    echo "ℹ️  svgo not found (optional). Install for better SVG cleanup: npm i -g svgo"
  fi
fi

mkdir -p "$WORKDIR"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# =========================
# HELPERS
# =========================

# Chuẩn hoá 1 SVG: stroke->path, object->path, ungroup, flatten; tối ưu (nếu có svgo)
normalize_svg() {
  local in_svg="$1"
  local out_svg="$2"

  # Inkscape chuyển stroke => path, shape => path
  inkscape "$in_svg" --export-plain-svg="$out_svg" \
    --actions="select-all:all;object-stroke-to-path;object-to-path;ungroup-deep;export-do" >/dev/null 2>&1 || true

  # Nếu Inkscape thất bại (file đơn giản), fallback copy
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

# Đọc mã Unicode từ info.json -> thập phân (trả "" nếu không có)
# Hỗ trợ: \uXXXX, \UXXXXXXXX, \eXXXX (PUA có tiền tố 'e')
decode_unicode_dec() {
  local name="$1"
  local encoded=""
  encoded="$(jq -r --arg k "$name" '.[$k].encodedCode // empty' "$ICON_CODE_JSON")"

  if [[ -z "$encoded" || "$encoded" == "null" ]]; then
    echo ""
    return 0
  fi

  local hex="0x0"
  # \uXXXX  -> 0xXXXX
  # \UXXXXXXXX -> 0xXXXXXXXX
  # \eXXXX  -> 0xEXXXX  (chuyển về vùng PUA bắt đầu bằng E)
  hex="$(printf '%s' "$encoded" \
        | sed -E 's/\\u([0-9a-fA-F]+)/0x\1/; s/\\U([0-9a-fA-F]+)/0x\1/; s/\\e([0-9a-fA-F]+)/0xE\1/;')"

  if ! [[ "$hex" =~ ^0x[0-9a-fA-F]+$ ]]; then
    echo ""
    return 0
  fi

  # Đổi sang thập phân
  local dec=""
  dec=$((hex)) || dec=""
  echo "$dec"
}

prepare_svg_dir_with_aliases() {
  local source_dir="$1"
  local prepared_dir="$2"

  mkdir -p "$prepared_dir"
  cp "$source_dir"/*.svg "$prepared_dir"/ 2>/dev/null || true

  shopt -s nullglob
  for metadata_file in "$ICON_METADATA_DIR"/*.json; do
    local canonical_name
    local canonical_svg

    canonical_name="$(basename "$metadata_file" .json)"
    canonical_svg="$prepared_dir/${canonical_name}.svg"

    if [[ ! -f "$canonical_svg" ]]; then
      continue
    fi

    while IFS= read -r alias_name; do
      if [[ -z "$alias_name" ]]; then
        continue
      fi

      cp "$canonical_svg" "$prepared_dir/${alias_name}.svg"
    done < <(jq -r '.aliases[]? | if type == "string" then . else .name // empty end' "$metadata_file")
  done
  shopt -u nullglob
}

# =========================
# BUILD PER WEIGHT
# =========================
echo "🔤 Building TTF fonts…"
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
  for svg in "$prepared_weight_dir"/*.svg; do
    base_name="$(basename "$svg" .svg)"
    glyph_name="$(echo "$base_name" | tr '-' '_' )"

    # Chuẩn hoá SVG trước khi import
    tmp_svg="$TMP_DIR/${base_name}_w${weight}.svg"
    normalize_svg "$svg" "$tmp_svg"

    # Mã unicode từ JSON (nếu trống sẽ dùng PUA fallback)
    unicode_dec="$(decode_unicode_dec "$base_name")"
    fallback_codepoint=$((0xE000 + i))
    codepoint="${unicode_dec:-$fallback_codepoint}"

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

    ((i++))
  done
  shopt -u nullglob

  # Sinh font
  cat >> "$PE_FILE" <<EOL
Generate("${ttf_path}")
Quit()
EOL

  fontforge -script "$PE_FILE" >/dev/null
  echo "✅  ${ttf_path}"
done

echo "🎉 Done. Output in: ${WORKDIR}/"
ls -1 "${WORKDIR}"/*.ttf 2>/dev/null || true
