import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:xuan_time_location/xuan_time_location.dart';

import '../../infrastructure/di/strategy_providers.dart';
import '../../presentation/viewmodels/theme_view_model.dart';

final class TiebanshenshuModuleManifest {
  const TiebanshenshuModuleManifest._();

  static const String id = 'tiebanshenshu';
  static const String displayNameKey = 'module_tiebanshenshu_name';
  static const String version = '0.1.0';
  static const String minShellVersion = '0.1.0-a3';

  static List<SingleChildWidget> createProviders(
      TiebanRecordRepository repo, {
      TiaoWenRepository? forwardedTiaoWenRepository,
    }) {
    // timezone 数据库须在使用 tz.getLocation() 前初始化，
    // 否则抛 "Tried to get location before initializing timezone database"。
    // 幂等：重复调用安全（仅重新装载时区数据）。
    tz.initializeTimeZones();
    // 注册产品时区标识 Asia/Beijing → IANA Asia/Shanghai 别名
    // （tzdata 无 Asia/Beijing，见 china_time_zone_alias.dart）。
    ensureChinaTimeZoneAlias();

    return [
      ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ...StrategyProviders.getProvidersWithRealRepo(repo,
          forwardedTiaoWenRepository: forwardedTiaoWenRepository),
    ];
  }
}
