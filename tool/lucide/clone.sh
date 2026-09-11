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
font_zip_url=$(echo $release_data | grep -o 'https://[^"]*lucide-font-[^"]*\.zip' | head -1)
icons_zip_url=$(echo $release_data | grep -o 'https://[^"]*lucide-icons-[^"]*\.zip' | head -1)
version=$(echo $release_data | grep -o '"tag_name": *"[^"]*' | cut -d'"' -f4)

echo "⭐️ Phiên bản mới nhất: $version"

# --- TẢI & GIẢI NÉN lucide-font ---
if [ -n "$font_zip_url" ]; then
    echo "⬇️ Đang tải lucide-font-$version.zip..."
    curl -L "$font_zip_url" -o lucide-font-$version.zip
    rm -rf "$DEST_FONT"
    mkdir -p "$DEST_FONT"
    echo "📦 Đang giải nén lucide-font vào thư mục $DEST_FONT"
    unzip -q lucide-font-$version.zip -d "$DEST_FONT"
    rm lucide-font-$version.zip

    # --- Move contents out of the nested dir (font) ---
    inner_font_dir=$(find "$DEST_FONT" -mindepth 1 -maxdepth 1 -type d | head -1)
    if [ -n "$inner_font_dir" ]; then
        mv "$inner_font_dir"/* "$DEST_FONT"/
        rm -rf "$inner_font_dir"
    fi

    # --- XÓA SẠCH assets trước khi chuyển ---
    echo "🗑  Xóa sạch toàn bộ nội dung cũ trong $ASSETS_DIR"
    rm -rf "$ASSETS_DIR"
    mkdir -p "$ASSETS_DIR"

    # --- CHUYỂN TOÀN BỘ FILE/FOLDER sang ../../assets ---
    echo "🚚 Chuyển toàn bộ file từ $DEST_FONT sang $ASSETS_DIR"
    mv "$DEST_FONT"/* "$ASSETS_DIR"/

    # (Tùy chọn) XÓA LẠI lucide-font
    rm -rf "$DEST_FONT"
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
    unzip -q lucide-icons-$version.zip -d "$DEST_ICONS"
    rm lucide-icons-$version.zip

    # --- Move contents out of the nested dir (icons) ---
    inner_icons_dir=$(find "$DEST_ICONS" -mindepth 1 -maxdepth 1 -type d | head -1)
    if [ -n "$inner_icons_dir" ]; then
        mv "$inner_icons_dir"/* "$DEST_ICONS"/
        rm -rf "$inner_icons_dir"
    fi
else
    echo "❌ Không tìm thấy file lucide-icons trong release mới nhất!"
fi

echo "✅ Hoàn tất."
