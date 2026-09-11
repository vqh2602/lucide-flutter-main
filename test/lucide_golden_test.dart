import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_test/golden_test.dart';
import 'package:lucide_icons_flutter/test_icons.dart' as lucide;

const String _fontPackage = 'lucide_icons_flutter';
const List<int> _weights = [100, 200, 300, 400, 500, 600];
const int _columns = 28;
const double _tileSize = 36;
const double _iconSize = 24;
const double _padding = 8;
const double _gridWidth = _columns * _tileSize + _padding * 2;

const Map<String, String> _fontAssets = {
  'Lucide': 'assets/lucide.ttf',
  'Lucide100': 'assets/build_font/LucideVariable-w100.ttf',
  'Lucide200': 'assets/build_font/LucideVariable-w200.ttf',
  'Lucide300': 'assets/build_font/LucideVariable-w300.ttf',
  'Lucide400': 'assets/build_font/LucideVariable-w400.ttf',
  'Lucide500': 'assets/build_font/LucideVariable-w500.ttf',
  'Lucide600': 'assets/build_font/LucideVariable-w600.ttf',
};

final RegExp _weightSuffixPattern = RegExp(r'(100|200|300|400|500|600)$');

final List<_IconGoldenGroup> _groups = [
  _IconGoldenGroup('regular', _iconsForWeight(null)),
  for (final weight in _weights)
    _IconGoldenGroup('w$weight', _iconsForWeight(weight)),
];

void main() {
  setUpAll(_loadLucideFonts);

  test('golden groups include every generated icon', () {
    expect(lucide.iconNames, hasLength(lucide.icons.length));

    final coveredCount = _groups.fold<int>(
      0,
      (count, group) => count + group.icons.length,
    );

    expect(coveredCount, lucide.icons.length);
  });

  for (final group in _groups) {
    goldenTest(
      name: 'lucide_icons_${group.name}',
      builder: (_) => _IconGrid(icons: group.icons),
      supportedDevices: [_deviceForIconCount(group.icons.length)],
      supportedThemes: const [Brightness.light],
      subdirectory: 'lucide_icons',
    );
  }
}

Future<void> _loadLucideFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in _fontAssets.entries) {
    await (FontLoader('packages/$_fontPackage/${entry.key}')
          ..addFont(rootBundle.load('packages/$_fontPackage/${entry.value}')))
        .load();
  }
}

List<IconData> _iconsForWeight(int? weight) {
  return [
    for (var index = 0; index < lucide.icons.length; index++)
      if (_isIconForWeight(lucide.iconNames[index], weight))
        lucide.icons[index],
  ];
}

bool _isIconForWeight(String iconName, int? weight) {
  final match = _weightSuffixPattern.firstMatch(iconName);

  if (weight == null) {
    return match == null;
  }

  return match?.group(0) == '$weight';
}

Device _deviceForIconCount(int iconCount) {
  return Device(
    name: 'icons',
    width: _gridWidth,
    height: _gridHeight(iconCount),
  );
}

double _gridHeight(int iconCount) {
  final rows = (iconCount / _columns).ceil();
  return rows * _tileSize + _padding * 2;
}

class _IconGoldenGroup {
  const _IconGoldenGroup(this.name, this.icons);

  final String name;
  final List<IconData> icons;
}

class _IconGrid extends StatelessWidget {
  const _IconGrid({required this.icons});

  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox(
          width: _gridWidth,
          height: _gridHeight(icons.length),
          child: Padding(
            padding: const EdgeInsets.all(_padding),
            child: IconTheme(
              data: const IconThemeData(
                color: Colors.black,
                size: _iconSize,
              ),
              child: Wrap(
                children: [
                  for (final icon in icons)
                    SizedBox.square(
                      dimension: _tileSize,
                      child: Center(
                        child: Icon(icon),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
