import 'package:flutter/widgets.dart';

class LucideIconData extends IconData {
  const LucideIconData(int codePoint, {String? fontFamily})
      : super(
          codePoint,
          fontFamily: fontFamily ?? 'Lucide',
          fontPackage: 'lucide_icons_flutter',
          matchTextDirection: true,
        );
}
