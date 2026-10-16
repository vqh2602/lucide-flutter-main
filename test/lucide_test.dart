import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_weights.dart';

void main() {
  group('Lucide Icons Tests', () {
    testWidgets('Icons can be rendered', (WidgetTester tester) async {
      // Test a few sample icons
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Icon(LucideIcons.activity),
                Icon(LucideIcons.airplay),
              ],
            ),
          ),
        ),
      );

      // Verify icons are rendered
      expect(find.byIcon(LucideIcons.activity), findsOneWidget);
      expect(find.byIcon(LucideIcons.airplay), findsOneWidget);
    });

    testWidgets('Icons can be customized', (WidgetTester tester) async {
      const Color customColor = Colors.red;
      const double customSize = 48.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(
              LucideIcons.heart,
              color: customColor,
              size: customSize,
            ),
          ),
        ),
      );

      // Find the icon
      final IconWidget = find.byIcon(LucideIcons.heart);
      expect(IconWidget, findsOneWidget);

      // Verify customization
      final Icon icon = tester.widget(IconWidget);
      expect(icon.color, equals(customColor));
      expect(icon.size, equals(customSize));
    });

    test('All icons are defined and accessible', () {
      // Sample a subset of icons to ensure they're defined
      final sampleIcons = [
        LucideIcons.activity,
        LucideIcons.airplay,
        LucideIcons.anchor,
        LucideIcons.aperture,
        LucideIcons.archive,
        LucideIcons.arrowDown,
        LucideIcons.arrowLeft,
        LucideIcons.arrowRight,
        LucideIcons.arrowUp,
      ];

      // Ensure all icons in the sample are not null
      for (final icon in sampleIcons) {
        expect(icon, isNotNull);
        expect(icon.codePoint, isNot(0));
        expect(icon.fontFamily, equals('Lucide'));
      }
    });

    test('Directional icons have matchTextDirection true', () {
      expect(LucideIcons.activityDir.matchTextDirection, isTrue);
      expect(LucideIcons.activity.matchTextDirection, isFalse);
    });

    test('Weight libraries are defined and accessible', () {
      expect(LucideIcons100.activity.fontFamily, equals('Lucide100'));
      expect(LucideIcons200.activity.fontFamily, equals('Lucide200'));
      expect(LucideIcons300.activity.fontFamily, equals('Lucide300'));
      expect(LucideIcons400.activity.fontFamily, equals('Lucide400'));
      expect(LucideIcons500.activity.fontFamily, equals('Lucide500'));
      expect(LucideIcons600.activity.fontFamily, equals('Lucide600'));

      expect(LucideIcons300.activityDir.matchTextDirection, isTrue);
      expect(LucideIcons300.activity.codePoint, equals(LucideIcons.activity.codePoint));
    });
  });
}

