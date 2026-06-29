import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:persistence_assets/persistence_assets.dart';

import 'package:tiebanshenshu/infrastructure/di/strategy_providers.dart';
import 'package:tiebanshenshu/providers/datetime_provider.dart';
import 'package:tiebanshenshu/dev/dev_fixtures.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:tiebanshenshu/presentation/viewmodels/theme_view_model.dart';
import 'dev_tiaowen_page.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_preferences/persistence_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:persistence_drift/tiebanshenshu/tiebanshenshu_module_registry.dart';

void main() async {
  // Initialize timezone data
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();

  final newDb = PersistenceDriftDatabase(NativeDatabase.memory());
  final prefs = await SharedPreferences.getInstance();
  final sessionRepo = PreferencesAccountSessionRepository(prefs);
  final accountDb = AccountDatabase(NativeDatabase.memory());
  final identityLinkRepo = DriftAccountIdentityLinkRepository(accountDb);
  
  final bootstrapStore = DriftScopeBootstrapStore(newDb);
  final ledger = DriftScopeLedger(db: newDb, bootstrapStore: bootstrapStore);
  final resolver = ScopeResolver(
    sessionRepository: sessionRepo,
    identityLinkRepository: identityLinkRepo,
    ledger: ledger,
  );
  final resolvedScope = await resolver.resolve();
  final scopeUid = resolvedScope.scopeUid;

  final ds = DriftRecordDataSource(newDb, scopeUid: scopeUid);
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([TiebanshenshuModuleRegistry.codec()]));
  final recordBackedRepository = TiebanshenshuModuleRegistry.repository(store: store);

  runApp(
    MultiProvider(
      providers: [
        // Basic configuration providers
        Provider<String>.value(value: 'example_app'),

        // DateTime provider from tiebanshenshu
        ChangeNotifierProvider<DateTimeProvider>(
          create: (_) =>
              DateTimeProvider()
                ..updateDateTime(TiebanshenshuDevFixtures.devUsa),
        ),

        ChangeNotifierProvider(create: (_) => ThemeViewModel()),

        Provider<TiaoWenRepository>(
          create: (_) => AssetsTiaoWenRepository(dataPath: kDefaultTiaoWenAssetPath),
        ),

        // All strategy related providers from tiebanshenshu
        ...StrategyProviders.getProviders(recordBackedRepository),
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
