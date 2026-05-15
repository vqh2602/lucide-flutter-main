#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"
dart pub get

bash "$SCRIPT_DIR/lucide/clone.sh"
bash "$SCRIPT_DIR/lucide/generate_variable_font.sh"

cd "$SCRIPT_DIR"
dart run generate_fonts_1.dart ../assets/info.json
