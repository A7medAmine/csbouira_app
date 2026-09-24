import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/core/theme/app_theme.dart';
import 'package:csbouira_app/data/services/catalog_index.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';
import 'package:csbouira_app/shared/widgets/catalog_file_tile.dart';

import 'support/catalog_fixture.dart';

Widget _wrap(Widget child, {ThemeMode mode = ThemeMode.dark}) {
  const locale = Locale('en');
  return MaterialApp(
    locale: locale,
    theme: AppTheme.light(locale),
    darkTheme: AppTheme.dark(locale),
    themeMode: mode,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  final index = CatalogIndex.build(sampleRoot());

  testWidgets('CatalogFileTile shows name, module, category and taps',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(CatalogFileTile(
      file: index.byId('exam00000001')!,
      onTap: () => tapped = true,
    )));

    expect(find.text('Examen Analyse 2022.pdf'), findsOneWidget);
    expect(find.text('Analyse 1 · Exams'), findsOneWidget);
    expect(find.text('Correction'), findsNothing);

    await tester.tap(find.byType(CatalogFileTile));
    expect(tapped, isTrue);
  });

  testWidgets('CatalogFileTile marks corrections, in light theme too',
      (tester) async {
    await tester.pumpWidget(_wrap(
      CatalogFileTile(file: index.byId('exam00000002')!, onTap: () {}),
      mode: ThemeMode.light,
    ));
    expect(find.text('Correction'), findsOneWidget);
  });
}
