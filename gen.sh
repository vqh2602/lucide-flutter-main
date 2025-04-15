

dart pub get
cd tool
dart run generate_fonts_1.dart ../assets/info.json

cd lucide
bash generate_variable_font.sh
bash build_font.sh
cp -r build_font ../../assets

cd ../..
dart format .