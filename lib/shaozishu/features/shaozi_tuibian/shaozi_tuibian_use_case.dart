/// 邵子先天推演业务编排
///
/// 负责协调策略、Repository 和 ViewModel 之间的业务流程。
library;

import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'models/shaozi_tuibian_models.dart';
import 'strategy/shaozi_tuibian_strategy.dart';

/// 邵子先天推演用例
///
/// 编排推演完整流程：八字 → 元会运世 → 卦象 → 条文。
class ShaoziTuibianUseCase {
  final ShaoziTuibianStrategy _strategy;
  final TiaoWenRepository _tiaoWenRepository;

  const ShaoziTuibianUseCase({
    required ShaoziTuibianStrategy strategy,
    required TiaoWenRepository tiaoWenRepository,
  })  : _strategy = strategy,
        _tiaoWenRepository = tiaoWenRepository;

  /// 执行完整推演流程
  ///
  /// [eightChars] 用户八字
  /// 返回包含完整状态的推演会话
  Future<ShaoziTuibianSession> execute(EightChars eightChars) async {
    // TODO: 实现完整推演编排
    throw UnimplementedError('execute 尚未实现');
  }
}
