import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tiebanshenshu/infrastructure/di/strategy_providers.dart';
import 'package:tiebanshenshu/providers/datetime_provider.dart';
import 'package:common/dev_constant.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:tiebanshenshu/presentation/viewmodels/theme_view_model.dart';
import 'dev_tiaowen_page.dart';

void main() {
  // Initialize timezone data
  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        // Basic configuration providers
        Provider<String>.value(value: 'example_app'),

        // DateTime provider from tiebanshenshu
        ChangeNotifierProvider<DateTimeProvider>(
          create: (_) =>
              DateTimeProvider()..updateDateTime(DevConstant.dev_usa),
        ),

        ChangeNotifierProvider(create: (_) => ThemeViewModel()),

        // All strategy related providers from tiebanshenshu
        ...StrategyProviders.providers,
      ],
      child: const TieBanShenShuExampleApp(),
    ),
  );
}

class TieBanShenShuExampleApp extends StatelessWidget {
  const TieBanShenShuExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, child) {
        return MaterialApp(
          title: '铁版神数示例程序',
          debugShowCheckedModeBanner: false,
          theme: themeViewModel.materialThemeData,
          home: const DevTiaoWenPage(),
        );
      },
    );
  }
}
