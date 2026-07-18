import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

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
    return [
      ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ...StrategyProviders.getProvidersWithRealRepo(repo,
          forwardedTiaoWenRepository: forwardedTiaoWenRepository),
    ];
  }
}
