#!/bin/bash

set -e

# --- SETTINGS ---
ICON_CODE_JSON="../../assets/info.json"
ICON_NAME="LucideVariable"
WORKDIR="build_font"
SVG_INPUT_DIR="svg_input"
WEIGHTS=(100 200 300 400 500 600)

# --- CHECK DEPENDENCIES ---
command -v jq >/dev/null 2>&1 || {
  echo "❌ jq not found. Please install it: brew install jq or sudo apt install jq"
  exit 1
}

mkdir -p "$WORKDIR"

# --- BUILD TTFs PER WEIGHT ---
echo "🔤 Building TTF fonts..."
for weight in "${WEIGHTS[@]}"; do
  weight_dir="${SVG_INPUT_DIR}/weight${weight}"
  ttf_path="${WORKDIR}/${ICON_NAME}-w${weight}.ttf"

  echo "📦 Generating TTF for weight ${weight}..."

  cat > /tmp/gen_font.pe <<EOL
New()
SetFontNames("LucideVariable", "LucideVariable", "LucideVariable w$weight")
ScaleToEm(1000)
Reencode("unicode")
EOL

  i=0
  for svg in "$weight_dir"/*.svg; do
    base_name=$(basename "$svg" .svg)
    glyph_name=$(echo "$base_name" | tr '-' '_')

    encoded=$(jq -r --arg name "$base_name" '.[$name].encodedCode' "$ICON_CODE_JSON")
    if [[ "$encoded" == "null" ]]; then
      echo "⚠️  No Unicode found for $base_name → skipping"
      continue
    fi

    unicode_hex=$(echo "$encoded" | sed 's/\\e/0xe/')
    unicode_dec=$((unicode_hex))
    fallback_codepoint=$((0xE000 + i))

    echo "Select(${fallback_codepoint});" >> /tmp/gen_font.pe
    echo "Clear();" >> /tmp/gen_font.pe
    echo "SetGlyphName(\"$glyph_name\");" >> /tmp/gen_font.pe
    echo "Import(\"$svg\");" >> /tmp/gen_font.pe
    echo "SetUnicodeValue($unicode_dec);" >> /tmp/gen_font.pe

    ((i++))
  done

  echo "Generate(\"$ttf_path\"); Quit();" >> /tmp/gen_font.pe
  fontforge -script /tmp/gen_font.pe
done

echo "✅ Done! All TTF fonts generated:"
ls "$WORKDIR"/*.ttf