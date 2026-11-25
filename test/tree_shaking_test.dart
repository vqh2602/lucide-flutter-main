import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/src/tree_shaking.dart';

void main() {
  test('forceCompileTimeTreeShaking covers every font in pubspec.yaml', () {
    final declaredFamilies = RegExp(r'^\s*- family: (\w+)', multiLine: true)
        .allMatches(File('pubspec.yaml').readAsStringSync())
        .map((match) => match[1])
        .toSet();

    expect(
      oneGlyphPerFont.map((icon) => icon.fontFamily).toSet(),
      declaredFamilies,
    );
    expect(
      oneGlyphPerFont.map((icon) => icon.fontPackage).toSet(),
      {'lucide_icons_flutter'},
    );
  });
}
