/// 邵子先天推演计算策略实现
///
/// 邵子数推演的具体实现，引用 shared 层的策略基类。
library;

import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:tiebanshenshu/service/strategy/base_calculation_strategy.dart';
import 'package:tiebanshenshu/shared/models/yuan_hui_yun_shi.dart';
import '../models/shaozi_tuibian_models.dart';
import 'shaozi_tuibian_strategy.dart';

/// 邵子先天推演计算策略实现
///
/// 继承 shared 层的 [BaseCalculationStrategy]，实现 [ShaoziTuibianStrategy] 接口。
class ShaoziTuibianStrategyImpl
    implements ShaoziTuibianStrategy {
  @override
  String get name => '邵子先天推演';

  @override
  String get description => '基于邵子数的先天推演算法';

  @override
  YuanHuiYunShi calculateYuanHuiYunShi(EightChars eightChars) {
    // TODO: 实现邵子数特有的元会运世计算逻辑
    throw UnimplementedError('calculateYuanHuiYunShi 尚未实现');
  }

  @override
  GuaCalculationResult calculateXianTianGua(YuanHuiYunShi yuanHuiYunShi) {
    // TODO: 实现邵子先天卦计算逻辑
    throw UnimplementedError('calculateXianTianGua 尚未实现');
  }

  @override
  List<int> calculateTiaoWenNumber(GuaCalculationResult guaResult) {
    // TODO: 实现邵子条文数推演逻辑
    throw UnimplementedError('calculateTiaoWenNumber 尚未实现');
  }
}
