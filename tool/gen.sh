#!/bin/bash

set -e  # Exit on error

echo "🔄 Downloading latest RemixIcon release from GitHub..."

# Get the latest release info from GitHub API
LATEST_RELEASE=$(curl -s https://api.github.com/repos/Remix-Design/RemixIcon/releases/latest)

# Extract version number from the release
VERSION=$(echo "$LATEST_RELEASE" | grep -o '"tag_name": *"v[^"]*"' | head -1 | sed 's/"tag_name": *"v//' | sed 's/"//')

if [ -z "$VERSION" ]; then
  echo "❌ Failed to get version from GitHub releases"
  exit 1
fi

# Extract the download URL for the Fonts zip file (RemixIcon_Fonts_vX.X.X.zip)
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep -o '"browser_download_url": *"[^"]*RemixIcon_Fonts[^"]*\.zip"' | head -1 | sed 's/"browser_download_url": *"//' | sed 's/"//')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "❌ Failed to get download URL from GitHub releases"
  echo "ℹ️  Trying to construct URL from version..."
  DOWNLOAD_URL="https://github.com/Remix-Design/RemixIcon/releases/download/v${VERSION}/RemixIcon_Fonts_v${VERSION}.zip"
fi

echo "📦 Found RemixIcon version: $VERSION"
echo "🌐 Download URL: $DOWNLOAD_URL"

# Create remix_source directory if it doesn't exist
mkdir -p remix_source
cd remix_source

# Download the latest release
echo "⬇️  Downloading RemixIcon Fonts..."
curl -L -o remixicon_fonts.zip "$DOWNLOAD_URL"

# Also download the SVG version for icons
SVG_URL=$(echo "$LATEST_RELEASE" | grep -o '"browser_download_url": *"[^"]*RemixIcon_Svg[^"]*\.zip"' | head -1 | sed 's/"browser_download_url": *"//' | sed 's/"//')

if [ -z "$SVG_URL" ]; then
  echo "ℹ️  Constructing SVG URL from version..."
  SVG_URL="https://github.com/Remix-Design/RemixIcon/releases/download/v${VERSION}/RemixIcon_Svg_v${VERSION}.zip"
fi

echo "⬇️  Downloading RemixIcon SVG icons..."
curl -L -o remixicon_svg.zip "$SVG_URL"

# Remove old extracted directories if they exist
if [ -d "RemixIcon-$VERSION" ]; then
  echo "🗑️  Removing old RemixIcon-$VERSION directory..."
  rm -rf "RemixIcon-$VERSION"
fi

# Create the version directory
mkdir -p "RemixIcon-$VERSION"

# Extract the fonts zip file into the version directory
echo "📂 Extracting remixicon_fonts.zip..."
unzip -q remixicon_fonts.zip -d "RemixIcon-$VERSION"

# Extract the SVG zip file
echo "📂 Extracting remixicon_svg.zip..."
unzip -q remixicon_svg.zip -d "RemixIcon-$VERSION-temp"

# Move icons folder from temp to version directory
if [ -d "RemixIcon-$VERSION-temp/icons" ]; then
  mv "RemixIcon-$VERSION-temp/icons" "RemixIcon-$VERSION/"
  rm -rf "RemixIcon-$VERSION-temp"
  echo "✅ SVG icons extracted successfully"
fi

echo "✅ RemixIcon downloaded and extracted successfully!"

# Check if required files exist
if [ ! -f "RemixIcon-$VERSION/fonts/remixicon.glyph.json" ]; then
  echo "❌ Error: remixicon.glyph.json not found!"
  echo "📂 Checking directory structure..."
  ls -la "RemixIcon-$VERSION/" 2>/dev/null || echo "Directory not found"
  exit 1
else
  echo "✅ Found remixicon.glyph.json"
fi

# Go back to tool directory
cd ..

# Update generate_remix_fonts.dart to use the correct version
echo "🔧 Updating generator script to use version $VERSION..."
if [ -f "generate_remix_fonts.dart" ]; then
  # Replace all RemixIcon version paths (both with and without 'tool/' prefix)
  sed -i.bak "s|tool/remix_source/RemixIcon-[0-9]*\.[0-9]*\.[0-9]*|remix_source/RemixIcon-$VERSION|g" generate_remix_fonts.dart
  sed -i.bak "s|remix_source/RemixIcon-[0-9]*\.[0-9]*\.[0-9]*|remix_source/RemixIcon-$VERSION|g" generate_remix_fonts.dart
  rm -f generate_remix_fonts.dart.bak
  echo "✅ Generator script updated to version $VERSION!"
fi

# Go to project root and install dependencies
cd ../
echo "📦 Installing Flutter dependencies..."
dart pub get

# Go back to tool directory and run the generator
cd tool
echo "🚀 Generating RemixIcon Flutter package..."
dart run generate_remix_fonts.dart

echo "↔️  Generating directional RemixIcon aliases..."
dart run gen_dir_icon.dart

echo "🎉 Done! RemixIcon Flutter package generated successfully!"
