/// 邵子先天推演计算策略接口
///
/// 定义邵子数推演的核心计算步骤：元会运世 → 先天卦 → 条文数。
library;

import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';
import '../models/shaozi_tuibian_models.dart';

/// 邵子先天推演策略抽象接口
///
/// 定义了从八字推演到条文数的三个核心计算步骤。
abstract class ShaoziTuibianStrategy {
  /// 策略名称
  String get name;

  /// 策略描述
  String get description;

  /// 第一步：根据八字计算元会运世
  ///
  /// [eightChars] 用户八字
  /// 返回元会运世计算结果
  YuanHuiYunShi calculateYuanHuiYunShi(EightChars eightChars);

  /// 第二步：根据元会运世计算先天卦与后天卦
  ///
  /// [yuanHuiYunShi] 元会运世计算结果
  /// 返回卦象计算结果（含先天卦、后天卦、元堂爻位）
  GuaCalculationResult calculateXianTianGua(YuanHuiYunShi yuanHuiYunShi);

  /// 第三步：根据卦象计算结果推演条文数
  ///
  /// [guaResult] 卦象计算结果
  /// 返回条文编号列表
  List<int> calculateTiaoWenNumber(GuaCalculationResult guaResult);
}
