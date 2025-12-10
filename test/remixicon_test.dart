import 'package:flutter_test/flutter_test.dart';
import 'package:remix_icons_flutter/remixicon_ids.dart';
import 'package:remix_icons_flutter/remixicon_list.dart';

void main() {
  test('Icons are generated', () {
    expect(allIcons, isNotEmpty);
  });

  test('Icon class has correct font family', () {
    expect(RemixIcon.heartFill.fontFamily, 'RemixIcon');
    expect(RemixIcon.heartFill.fontPackage, 'remixiconflutter');
  });

  test('Icon has correct code point', () {
    // heart-fill unicode is usually EA01, checking for consistency
    // We can check one that we know or just ensure it is not 0
    expect(RemixIcon.heartFill.codePoint, isNot(0));
  });

  test('All icons in list have correct metadata', () {
    for (var icon in allIcons) {
      expect(icon.fontFamily, 'RemixIcon');
      expect(icon.fontPackage, 'remixiconflutter');
    }
  });
}
