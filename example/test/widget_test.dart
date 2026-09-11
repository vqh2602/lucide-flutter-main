import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('Search filters icons by icon name', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(EditableText), 'folder-search');
    await tester.pump();

    expect(find.text('folderSearch'), findsOneWidget);
    expect(find.text('accessibility'), findsNothing);
  });
}
