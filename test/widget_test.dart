import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csbouira_app/app.dart';

Widget createTestApp() {
  return const ProviderScope(child: CSBouiraApp());
}

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    expect(find.text('CS Bouira'), findsOneWidget);
  });
}
