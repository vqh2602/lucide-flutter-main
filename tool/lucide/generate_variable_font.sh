#!/bin/bash

set -e

# --- SETTINGS ---
ICON_NAME="LucideVariable"
WORKDIR="build_font"
SVG_CLONE_DIR="lucide"
SVG_SRC_DIR="${SVG_CLONE_DIR}/icons"
SVG_INPUT_DIR="svg_input"
WEIGHTS=(100 200 300 400 500 600)
DEFAULT_WEIGHT=400
DEFAULT_OPSZ=24

# --- CHECK DEPENDENCIES ---
command -v fontmake >/dev/null 2>&1 || { echo "❌ fontmake not found. Run: pip install fontmake"; exit 1; }
command -v fontforge >/dev/null 2>&1 || { echo "❌ fontforge not found. Install via brew (macOS) or apt (Ubuntu)"; exit 1; }
command -v xmlstarlet >/dev/null 2>&1 || { echo "❌ xmlstarlet not found. Install with: brew install xmlstarlet or sudo apt install xmlstarlet"; exit 1; }

# --- CLEANUP ---
rm -rf "$WORKDIR" "$SVG_INPUT_DIR"
mkdir -p "$WORKDIR" "$SVG_INPUT_DIR"
# TODO:
# # --- CLONE ICONS ---
# if [ ! -d "$SVG_CLONE_DIR" ]; then
#   echo "📦 Cloning Lucide icons..."
#   git clone --depth 1 https://github.com/lucide-icons/lucide.git "$SVG_CLONE_DIR"
# fi

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

    # Check if the SVG file is valid before processing
    if ! fontforge -script -c "Open('$output_svg')" 2>/dev/null; then
      echo "❌ Skipping invalid or unreadable SVG file: $output_svg"
      continue
    fi
  done
done

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
