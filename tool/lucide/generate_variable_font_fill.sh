#!/bin/bash

set -e

# --- SETTINGS ---
ICON_NAME="LucideFill"
WORKDIR="build_font"
SVG_CLONE_DIR="lucide"
SVG_SRC_DIR="${SVG_CLONE_DIR}/icons"
SVG_INPUT_DIR="svg_input"
DEFAULT_OPSZ=24

# --- CHECK DEPENDENCIES ---
command -v fontmake >/dev/null 2>&1 || { echo "❌ fontmake not found. Run: pip install fontmake"; exit 1; }
command -v fontforge >/dev/null 2>&1 || { echo "❌ fontforge not found. Install via brew (macOS) or apt (Ubuntu)"; exit 1; }
command -v xmlstarlet >/dev/null 2>&1 || { echo "❌ xmlstarlet not found. Install with: brew install xmlstarlet or sudo apt install xmlstarlet"; exit 1; }

# --- CLEANUP ---
rm -rf "$WORKDIR" "$SVG_INPUT_DIR"
mkdir -p "$WORKDIR" "$SVG_INPUT_DIR"

# --- CLONE ICONS ---
if [ ! -d "$SVG_CLONE_DIR" ]; then
  echo "📦 Cloning Lucide icons..."
  git clone --depth 1 https://github.com/lucide-icons/lucide.git "$SVG_CLONE_DIR"
fi

# --- GENERATE FILLED SVGs ---
echo "🎨 Generating filled SVGs..."
fill_dir="${SVG_INPUT_DIR}/fill"
mkdir -p "$fill_dir"

for svg in "$SVG_SRC_DIR"/*.svg; do
  filename=$(basename "$svg")
  output_svg="${fill_dir}/${filename}"

  # Copy the original SVG
  cp "$svg" "$output_svg"
  
  # Convert strokes to fills by:
  # 1. Remove any existing fill attributes
  # 2. Add fill="currentColor" to all elements with stroke
  # 3. Remove stroke attributes
  xmlstarlet ed -L \
    -d '//@fill' \
    -s '//*[@stroke]' -t attr -n "fill" -v "currentColor" \
    -d '//@stroke' \
    -d '//@stroke-width' \
    -d '//@stroke-linecap' \
    -d '//@stroke-linejoin' \
    "$output_svg" 2>/dev/null || true

  # Check if the SVG file is valid before processing
  if ! fontforge -script -c "Open('$output_svg')" 2>/dev/null; then
    echo "❌ Skipping invalid or unreadable SVG file: $output_svg"
    continue
  fi
done

# The rest of your font building process would go here
# You may need to adjust the remaining code to work with filled icons

echo "✅ Done! Filled SVGs created in ${fill_dir}"
