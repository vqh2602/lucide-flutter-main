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
