import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rongilareshom/providers/providers.dart';
import 'package:rongilareshom/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final settingsProvider = SettingsProvider();
    await settingsProvider.loadSettings();
    
    await tester.pumpWidget(MyApp(settingsProvider: settingsProvider));
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
