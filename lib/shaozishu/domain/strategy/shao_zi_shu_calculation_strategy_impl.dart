/// 邵子数计算策略实现
///
/// 对标 kao_ke_calculation_strategy_impl.dart，实现 [ShaoZiShuCalculationStrategy] 接口。
/// 计算逻辑委托给 [ShaoZiShuCalculationHelper]（静态纯函数），
/// 条文查询委托给 [TiaoWenRepository]。
library;

import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import '../../helper/shao_zi_shu_calculation_helper.dart';
import 'shao_zi_shu_calculation_strategy.dart';

/// 邵子数计算策略实现
///
/// 职责：
/// - [calculateResult] → 委托给 [ShaoZiShuCalculationHelper.calculate]
/// - [getTiaoWenContent] → 委托给 [TiaoWenRepository.getByIdList]
/// - [getExpandedTiaoWenContent] → 使用接口默认实现（委托给 getTiaoWenContent）
class ShaoZiShuCalculationStrategyImpl
    implements ShaoZiShuCalculationStrategy {
  final TiaoWenRepository _repository;

  /// 构造注入
  ///
  /// [repository] 条文数据源（Phase 2 产物），负责根据编号列表查询条文内容。
  ShaoZiShuCalculationStrategyImpl({
    required TiaoWenRepository repository,
  }) : _repository = repository;

  // ===========================================================================
  // ShaoZiShuCalculationStrategy 接口实现
  // ===========================================================================

  @override
  ShaoZiShuResult calculateResult(EightChars eightChars) {
    return ShaoZiShuCalculationHelper.calculate(eightChars);
  }

  @override
  Future<List<TiaoWenDataModel>> getTiaoWenContent({
    required List<int> tiaoWenNumbers,
  }) async {
    if (tiaoWenNumbers.isEmpty) return [];

    final ctx = RequestContext(scopeUid: 'local-anonymous');
    final result = await _repository.query(
      {"ids": tiaoWenNumbers},
      PageRequest(limit: 1000),
      ctx,
    );
    return switch (result) {
      Ok(:final value) => value.items,
      Err(:final error) => throw error,
    };
  }

  @override
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
