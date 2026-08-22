import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:drift_flutter/drift_flutter.dart';
import 'package:persistence_drift/tiebanshenshu/tiebanshenshu_module_registry.dart';
import 'package:persistence_drift/scope/scope_handover.dart';
import 'package:drift/native.dart';
import 'package:persistence_core/persistence_core.dart' hide StorageError;

void main() async {
  // Initialize timezone data
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();

  final newDb = PersistenceDriftDatabase(driftDatabase(name: 'tieban_example_persistence'));
  final prefs = await SharedPreferences.getInstance();
  final sessionRepo = PreferencesAccountSessionRepository(prefs);
  final accountDb = AccountDatabase(driftDatabase(name: 'tieban_example_account'));
  final identityLinkRepo = DriftAccountIdentityLinkRepository(accountDb);

  final bootstrapStore = DriftScopeBootstrapStore(newDb);
  final ledger = DriftScopeLedger(db: newDb, bootstrapStore: bootstrapStore);
  final resolver = ScopeResolver(
    sessionRepository: sessionRepo,
    identityLinkRepository: identityLinkRepo,
    ledger: ledger,
    handoverService: _NoOpScopeHandoverService(),
  );
  final resolvedScope = await resolver.resolve();
  final scopeUid = resolvedScope.scopeUid;

  final ds = DriftRecordDataSource(newDb, scopeUid: scopeUid);
  final store = LocalRecordRepository(
    ds,
    RecordAdapterRegistry([TiebanshenshuModuleRegistry.codec()]),
  );
  final recordBackedRepository = TiebanshenshuModuleRegistry.repository(
    store: store,
  );
  // XRAP 链路：数据经 tiebanshenshu.tiao_wen 数据集（XRAP 协议）安装进
  // TiebanshenshuDatabase（drift），查询走 SQLite。替代旧桩 AssetsTiaoWenRepository
  // （CSV 直读，已 @Deprecated）。
  final tiaoWenDb = TiebanshenshuDatabase(NativeDatabase.memory());
  final tiaoWenInstaller = TiebanshenshuDriftDatasetInstaller(
    db: tiaoWenDb,
    bundledSource: const BundledDatasetSource(),
  );
  registerTiebanshenshuDatasets(db: tiaoWenDb);
  final tiaoWenRepository = XrapTiaoWenRepository(
    db: tiaoWenDb,
    installer: tiaoWenInstaller,
  );

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

        // All strategy related providers from tiebanshenshu
        ...StrategyProviders.getProviders(
          recordBackedRepository,
          tiaoWenRepository: tiaoWenRepository,
        ),
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

/// 示例应用中不需要真实的 scope 交接逻辑。
class _NoOpScopeHandoverService implements ScopeHandoverService {
  @override
  Future<void> handover({
    required String fromScope,
    required String toScope,
  }) async {}
}
