# ... existing code ...

# Create font with different weights
echo "🔤 Creating fonts with different weights and stroke widths..."

# Create directories for each weight
mkdir -p "$TEMP_DIR/lucide/lucide-font-default"
mkdir -p "$TEMP_DIR/lucide/lucide-font-500"
mkdir -p "$TEMP_DIR/lucide/lucide-font-600"
mkdir -p "$TEMP_DIR/lucide/lucide-font-700"
mkdir -p "$TEMP_DIR/lucide/lucide-font-800"
mkdir -p "$TEMP_DIR/lucide/lucide-font-900"

# Build default font
echo "🔄 Building default font..."
pnpm build:font
if [ -d "lucide-font" ]; then
  cp -R lucide-font/* "$TEMP_DIR/lucide/lucide-font-default/"
  rm -rf lucide-font
fi

# Build font with weight 500 and increased stroke width
echo "🔄 Building font with weight 500 and stroke width 1.5..."
pnpm build:font -- --weight 500 --stroke-width 1.5
if [ -d "lucide-font" ]; then
  cp -R lucide-font/* "$TEMP_DIR/lucide/lucide-font-500/"
  rm -rf lucide-font
fi

# Build font with weight 600 and increased stroke width
echo "🔄 Building font with weight 600 and stroke width 1.8..."
pnpm build:font -- --weight 600 --stroke-width 1.8
if [ -d "lucide-font" ]; then
  cp -R lucide-font/* "$TEMP_DIR/lucide/lucide-font-600/"
  rm -rf lucide-font
fi

# Build font with weight 700 and increased stroke width
echo "🔄 Building font with weight 700 and stroke width 2.1..."
pnpm build:font -- --weight 700 --stroke-width 2.1
if [ -d "lucide-font" ]; then
  cp -R lucide-font/* "$TEMP_DIR/lucide/lucide-font-700/"
  rm -rf lucide-font
fi

# Build font with weight 800 and increased stroke width
echo "🔄 Building font with weight 800 and stroke width 2.4..."
pnpm build:font -- --weight 800 --stroke-width 2.4
if [ -d "lucide-font" ]; then
  cp -R lucide-font/* "$TEMP_DIR/lucide/lucide-font-800/"
  rm -rf lucide-font
fi

# Build font with weight 900 and increased stroke width
echo "🔄 Building font with weight 900 and stroke width 2.7..."
pnpm build:font -- --weight 900 --stroke-width 2.7
if [ -d "lucide-font" ]; then
  cp -R lucide-font/* "$TEMP_DIR/lucide/lucide-font-900/"
  rm -rf lucide-font
fi

# Export the fonts to the original directory
echo "✅ Fonts built successfully!"

# Create the export directories in the original location
mkdir -p "$CURRENT_DIR/lucide-font-default"
mkdir -p "$CURRENT_DIR/lucide-font-500"
mkdir -p "$CURRENT_DIR/lucide-font-600"
mkdir -p "$CURRENT_DIR/lucide-font-700"
mkdir -p "$CURRENT_DIR/lucide-font-800"
mkdir -p "$CURRENT_DIR/lucide-font-900"

# Copy the font files to the current directory
cp -R "$TEMP_DIR/lucide/lucide-font-default/"* "$CURRENT_DIR/lucide-font-default/"
cp -R "$TEMP_DIR/lucide/lucide-font-500/"* "$CURRENT_DIR/lucide-font-500/"
cp -R "$TEMP_DIR/lucide/lucide-font-600/"* "$CURRENT_DIR/lucide-font-600/"
cp -R "$TEMP_DIR/lucide/lucide-font-700/"* "$CURRENT_DIR/lucide-font-700/"
cp -R "$TEMP_DIR/lucide/lucide-font-800/"* "$CURRENT_DIR/lucide-font-800/"
cp -R "$TEMP_DIR/lucide/lucide-font-900/"* "$CURRENT_DIR/lucide-font-900/"

echo "📁 Font files exported to separate directories in: $CURRENT_DIR"
echo "📋 Generated font directories:"
ls -la "$CURRENT_DIR" | grep "lucide-font"
else
  echo "❌ Font build failed. Check for errors above."
  exit 1
fi

# ... existing code ...