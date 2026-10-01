#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LUCIDE_REPO="https://github.com/lucide-icons/lucide"
RELEASES_URL="https://api.github.com/repos/lucide-icons/lucide/releases/latest"
DEST_FONT="lucide-font"
DEST_ICONS="lucide-source"
ASSETS_DIR="../../assets"

echo "🔍 Đang lấy thông tin release mới nhất của Lucide..."
release_data=$(curl -s $RELEASES_URL)
font_zip_url=$(echo "$release_data" | grep -o 'https://[^"]*lucide-font-[^"]*\.zip' | head -1)
icons_zip_url=$(echo "$release_data" | grep -o 'https://[^"]*lucide-icons-[^"]*\.zip' | head -1)
version=$(echo "$release_data" | grep -o '"tag_name": *"[^"]*' | cut -d'"' -f4)

if [ -z "$version" ]; then
    echo "⚠️  GitHub API bị giới hạn lượt gọi, chuyển sang lấy qua web releases/latest..."
    version=$(curl -s -I https://github.com/lucide-icons/lucide/releases/latest | grep -i '^location:' | sed -E 's/.*tag\/([^\r\n]+).*/\1/' | tr -d '\r\n ')
    if [ -n "$version" ]; then
        font_zip_url="https://github.com/lucide-icons/lucide/releases/download/$version/lucide-font-$version.zip"
        icons_zip_url="https://github.com/lucide-icons/lucide/releases/download/$version/lucide-icons-$version.zip"
    fi
fi

echo "⭐️ Phiên bản mới nhất: $version"

# --- TẢI & GIẢI NÉN lucide-font ---
if [ -n "$font_zip_url" ]; then
    echo "⬇️ Đang tải lucide-font-$version.zip..."
    curl -L "$font_zip_url" -o lucide-font-$version.zip
    mkdir -p "$ASSETS_DIR" "$ASSETS_DIR/build_font"
    echo "📦 Đang giải nén lucide-font vào thư mục $ASSETS_DIR"
    unzip -q -o -j lucide-font-$version.zip -d "$ASSETS_DIR"
    rm lucide-font-$version.zip
else
    echo "❌ Không tìm thấy file lucide-font trong release mới nhất!"
fi

# --- TẢI & GIẢI NÉN lucide-icons ---
if [ -n "$icons_zip_url" ]; then
    echo "⬇️ Đang tải lucide-icons-$version.zip..."
    curl -L "$icons_zip_url" -o lucide-icons-$version.zip
    rm -rf "$DEST_ICONS"
    mkdir -p "$DEST_ICONS"
    echo "📦 Đang giải nén lucide-icons vào thư mục $DEST_ICONS"
    unzip -q -o -j lucide-icons-$version.zip -d "$DEST_ICONS"
    rm lucide-icons-$version.zip
else
    echo "❌ Không tìm thấy file lucide-icons trong release mới nhất!"
fi

echo "✅ Hoàn tất."
