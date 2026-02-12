import 'package:common/dev_constant.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'domain/models/multi_base_number_selection.dart';
import 'domain/models/yuan_hui_yun_shi.dart';
import 'navigator.dart';
import 'ui/pages/dev_page.dart';
import 'presentation/pages/strategy_demo_page.dart';
import 'presentation/pages/tai_xuan_interactive_page.dart';

import 'providers/datetime_provider.dart';
import 'infrastructure/di/strategy_providers.dart';
import 'presentation/viewmodels/theme_view_model.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(
    MultiProvider(
      providers: [
        Provider<String>.value(value: 'example'),
        ChangeNotifierProvider<DateTimeProvider>(
          create: (_) =>
              DateTimeProvider()..updateDateTime(DevConstant.dev_usa),
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
  const AlgorithmEditorApp({Key? key}) : super(key: key);

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
