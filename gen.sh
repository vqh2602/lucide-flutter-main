#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

dart pub get

bash tool/lucide/clone.sh
bash tool/lucide/generate_variable_font.sh

cd tool
dart run generate_fonts_1.dart ../assets/info.json

cd ..
dart run tool/add_directional_icon_variants.dart

dart format .

echo "🔍 Kiểm tra chất lượng và độ toàn vẹn của các icon..."
PYTHON_BIN=""
for candidate in "${PYTHON:-}" python3 python /Users/vuongquanghuy/.pyenv/versions/3.12.5/bin/python3; do
  if [ -n "$candidate" ] && command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c "import fontTools.ttLib" >/dev/null 2>&1; then
    PYTHON_BIN="$candidate"
    break
  fi
done

if [ -n "$PYTHON_BIN" ]; then
  "$PYTHON_BIN" tool/lucide/check_icons.py
else
  echo "⚠️  Không tìm thấy Python có fontTools để chạy kiểm tra icon."
fi
