/// 邵子数计算策略接口
///
/// 对标 kao_ke_calculation_strategy.dart，定义邵子数河洛天地数法的计算抽象。
/// 纯演绎流程：八字 → 12个数 → 天地数 → 本命基数 → 条文编号 → 加一倍法展开。
library;

import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import '../../helper/shao_zi_shu_calculation_helper.dart';

/// 邵子数计算策略抽象接口
///
/// 定义了河洛天地数法计算和条文内容获取的抽象方法。
/// 具体实现类负责 Pure Calculation（Helper）与 Repository 的协作。
abstract class ShaoZiShuCalculationStrategy {
  /// 计算邵子数完整结果（同步纯计算）
  ///
  /// [eightChars] 用户八字
  ///
  /// 返回 [ShaoZiShuResult]，包含 12个数、天地数、本命基数、条文编号、加一倍法展开等。
  ShaoZiShuResult calculateResult(EightChars eightChars);

  /// 根据条文编号列表获取条文内容（异步，需 Repository）
  ///
  /// [tiaoWenNumbers] 条文编号列表
  ///
  /// 返回对应的 [TiaoWenDataModel] 列表。
  Future<List<TiaoWenDataModel>> getTiaoWenContent({
    required List<int> tiaoWenNumbers,
  });

  /// 获取加一倍法扩展的完整条文内容
  ///
  /// [result] 上一步的计算结果（含 expandedTiaoWenNumbers）
  ///
  /// 默认实现：以 result.expandedTiaoWenNumbers 为参数调用 [getTiaoWenContent]，
  /// 返回编号→内容的 Map。
  Future<Map<int, TiaoWenDataModel>> getExpandedTiaoWenContent({
    required ShaoZiShuResult result,
  }) async {
    final contents = await getTiaoWenContent(
      tiaoWenNumbers: result.expandedTiaoWenNumbers,
    );
    final map = <int, TiaoWenDataModel>{};
    for (final model in contents) {
      map[model.id] = model;
    }
    return map;
  }
}
