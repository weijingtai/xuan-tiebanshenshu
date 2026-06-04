import 'package:tiebanshenshu/dev/dev_fixtures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigator.dart';

import 'providers/datetime_provider.dart';
import 'infrastructure/di/strategy_providers.dart';
import 'presentation/viewmodels/theme_view_model.dart';

import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(
    MultiProvider(
      providers: [
        Provider<String>.value(value: 'example'),
        ChangeNotifierProvider<DateTimeProvider>(
          create: (_) =>
              DateTimeProvider()..updateDateTime(TiebanshenshuDevFixtures.devUsa),
        ),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        // Strategy相关的Provider配置
        ...StrategyProviders.providers,
      ],
      child: const AlgorithmEditorApp(),
    ),
  );
}

class AlgorithmEditorApp extends StatelessWidget {
  const AlgorithmEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<String>.value(value: 'example2')],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return MaterialApp(
            title: 'Algorithm Editor Prototype',
            theme: themeViewModel.materialThemeData,
            initialRoute: '/dev',
            onGenerateRoute: NavigatorGenerator.generateRoute,
          );
        },
      ),
    );
  }
}
