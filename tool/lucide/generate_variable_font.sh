#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# --- SETTINGS ---
ICON_NAME="LucideVariable"
WORKDIR="build_font"
REPO_ASSET_FONT_DIR="../../assets/build_font"
SVG_CLONE_DIR="lucide-source"
SVG_SRC_DIR="${SVG_CLONE_DIR}"
SVG_INPUT_DIR="svg_input"
WEIGHTS=(100 200 300 400 500 600)
DEFAULT_WEIGHT=400
DEFAULT_OPSZ=24

# --- CHECK DEPENDENCIES ---
need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing: $1"; exit 1; }; }
need bc
need xmlstarlet

# --- CLEANUP ---
rm -rf "$SVG_INPUT_DIR"
mkdir -p "$WORKDIR" "$SVG_INPUT_DIR" "$REPO_ASSET_FONT_DIR"

if ! find "$SVG_SRC_DIR" -maxdepth 1 -name '*.svg' -print -quit | grep -q .; then
  echo "❌ Missing Lucide SVG source files in ${SVG_SRC_DIR}"
  echo "   Run clone.sh first, then run this script again."
  exit 1
fi

# --- GENERATE SVGs PER WEIGHT ---
echo "🎨 Generating SVGs for weights..."
for weight in "${WEIGHTS[@]}"; do
  # Adjust the multiplier to make the progression more gradual
  stroke_width=$(echo "scale=2; ($weight - 100) * 0.005 + 0.5" | bc)
  weight_dir="${SVG_INPUT_DIR}/weight${weight}"
  mkdir -p "$weight_dir"

  for svg in "$SVG_SRC_DIR"/*.svg; do
    filename=$(basename "$svg")
    output_svg="${weight_dir}/${filename}"

    cp "$svg" "$output_svg"
    xmlstarlet ed -L -u '//@stroke-width' -v "$stroke_width" "$output_svg" 2>/dev/null || true
  done
done

echo "✅ Generated SVG inputs in ${SVG_INPUT_DIR}"
echo "🔤 Building TTF fonts from generated SVG inputs..."
bash "${SCRIPT_DIR}/build_font.sh"

# # --- CONVERT TO UFO ---
# echo "🔧 Converting SVGs to UFO..."
# for weight in "${WEIGHTS[@]}"; do
#   svg_weight_dir="${SVG_INPUT_DIR}/weight${weight}"
#   ufo_dir="${WORKDIR}/${ICON_NAME}-w${weight}.ufo"
#   mkdir -p "$ufo_dir"

#   # Convert each SVG to its own UFO with fontforge
#   for svg in "$svg_weight_dir"/*.svg; do
#     filename=$(basename "$svg" .svg)
#     fontforge -script svg2ufo.pe "$svg" "${ufo_dir}/${filename}.ufo"
#   done
# done

# # --- CREATE DESIGNSPACE FILE ---
# DESIGNSPACE_FILE="${WORKDIR}/${ICON_NAME}.designspace"
# echo "🛠️  Creating designspace..."

# cat > "$DESIGNSPACE_FILE" <<EOL
# <designspace format="4.0">
#   <axes>
#     <axis tag="wght" name="Weight" minimum="100" maximum="800" default="${DEFAULT_WEIGHT}" />
#     <axis tag="opsz" name="Optical Size" minimum="20" maximum="48" default="${DEFAULT_OPSZ}" />
#   </axes>
#   <sources>
# EOL

# for weight in "${WEIGHTS[@]}"; do
#   echo "    <source filename=\"${ICON_NAME}-w${weight}.ufo\" name=\"wght${weight}\" location=\"wght:$weight opsz:${DEFAULT_OPSZ}\" />" >> "$DESIGNSPACE_FILE"
# done

# cat >> "$DESIGNSPACE_FILE" <<EOL
#   </sources>
#   <instances>
#     <instance name="Regular" location="wght:${DEFAULT_WEIGHT} opsz:${DEFAULT_OPSZ}" filename="${ICON_NAME}-Regular.ufo" />
#   </instances>
# </designspace>
# EOL

# # --- BUILD VARIABLE FONT ---
# echo "🏗️  Building variable font..."
# cd "$WORKDIR"
# fontmake -m "${ICON_NAME}.designspace" -o variable

# echo "✅ Done! Output font:"
# find variable_ttf -name "*.ttf"


# --- BUILD TTFs PER WEIGHT ---
