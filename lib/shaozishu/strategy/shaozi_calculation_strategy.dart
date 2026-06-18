/// 邵子数核心计算策略
///
/// 继承 shared 层的策略基类，定义邵子数特有的计算逻辑。
library;

import 'package:tiebanshenshu/service/strategy/base_calculation_strategy.dart';

/// 邵子数计算参数
class ShaoziCalculationParams extends BaseCalculationParams {
  @override
  String get description => '邵子数计算参数';

  // TODO: 添加邵子数特有的参数字段（如八卦加则、考刻数据等）
}

/// 邵子数计算结果
class ShaoziCalculationResult extends BaseCalculationResult {
  /// 最终条文数
  final int? finalTiaoWenNumber;

  /// 各步骤中间结果（用于展示计算过程）
  final Map<String, dynamic>? intermediateResults;

  ShaoziCalculationResult({
    this.finalTiaoWenNumber,
    this.intermediateResults,
  });

  @override
  String toString() =>
      'ShaoziCalculationResult(finalNumber: $finalTiaoWenNumber)';
}

/// 邵子数核心计算策略
///
/// 继承 [BaseCalculationStrategy]，实现邵子数完整的计算流程：
/// 元会运世 → 起卦 → 八卦加则 → 条文定数。
abstract class ShaoziCalculationStrategy
    extends BaseCalculationStrategy<
        ShaoziCalculationParams,
        ShaoziCalculationResult> {
  @override
  String get school => '邵子';

  @override
  String get description => '邵子数先天推演算法';

  /// 邵子数默认条文计算配置：
  /// 基础数分别 ±96 四次：±96、±192、±384、±768
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return const GenericTiaoWenCalculationConfig(
      name: '邵子数条文展开',
      description: '基础数分别 ±96 四次：±96、±192、±384、±768',
      calculationList: [0, 96, 192, 384, 768],
      withSub: true,
    );
  }

  @override
  String get tiaoWenCalculationDescription =>
      '邵子数标准条文展开：基础数 ± (96, 192, 384, 768)';

  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs => [
        defaultTiaoWenCalculationConfig,
      ];
}
