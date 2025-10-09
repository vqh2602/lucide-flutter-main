import 'package:flutter/widgets.dart';

class LucideIconData extends IconData {
  const LucideIconData(int codePoint,
      {String? fontFamily, bool matchTextDirection = false})
      : super(
          codePoint,
          fontFamily: fontFamily ?? 'Lucide',
          fontPackage: 'lucide_icons_flutter',
          matchTextDirection: matchTextDirection,
        );
}
