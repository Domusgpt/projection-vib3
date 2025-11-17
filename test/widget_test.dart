import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vib3_light_lab/main.dart';

void main() {
  testWidgets('VIB3 Light Lab app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(
        child: VIB3LightLabApp(),
      ),
    );

    // Verify app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
