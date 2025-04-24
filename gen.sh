

dart pub get
cd tool

cd lucide
bash generate_variable_font.sh
sleep 2
cd ../
dart run generate_fonts_1.dart ../assets/info.json
sleep 2
cd lucide
bash build_font.sh
cp -r build_font ../../assets

cd ../..
dart format .