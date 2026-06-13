/// 邵子先天推演会话模型
///
/// 定义邵子推演过程中的会话状态、阶段枚举和相关数据结构。
library;

import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';
import 'package:tiebanshenshu/shared/models/yuan_hui_yun_shi.dart';

/// 邵子先天推演阶段枚举
enum ShaoziTuibianPhase {
  /// 已初始化，等待计算元会运世
  initialized,

  /// 元会运世已计算，等待起卦
  yuanHuiYunShiCalculated,

  /// 卦象已计算，等待查询条文
  guaCalculated,

  /// 条文已查询，推演完成
  tiaoWenQueried,
}

/// 卦象计算结果
class GuaCalculationResult {
  /// 先天卦
  final Enum64Gua xianTianGua;

  /// 后天卦
  final Enum64Gua houTianGua;

  /// 元堂爻位（1-based）
  final int? yuanTangYao;

  const GuaCalculationResult({
    required this.xianTianGua,
    required this.houTianGua,
    this.yuanTangYao,
  });

  @override
  String toString() =>
      'GuaCalculationResult(先天: ${xianTianGua.fullname}, 后天: ${houTianGua.fullname}, 元堂爻: $yuanTangYao)';
}

/// 邵子先天推演会话
///
/// 包含八字、元会运世、先天卦、后天卦、条文等推演全过程的完整状态。
class ShaoziTuibianSession {
  /// 会话唯一标识
  final String id;

  /// 用户八字
  final EightChars eightChars;

  /// 元会运世计算结果
  final YuanHuiYunShi? yuanHuiYunShi;

  /// 卦象计算结果
  final GuaCalculationResult? guaResult;

  /// 推演当前阶段
  final ShaoziTuibianPhase phase;

  /// 查询到的条文编号列表
  final List<int> tiaoWenNumbers;

  const ShaoziTuibianSession({
    required this.id,
    required this.eightChars,
    this.yuanHuiYunShi,
    this.guaResult,
    this.phase = ShaoziTuibianPhase.initialized,
    this.tiaoWenNumbers = const [],
  });

  /// 复制并更新部分字段
  ShaoziTuibianSession copyWith({
    String? id,
    EightChars? eightChars,
    YuanHuiYunShi? yuanHuiYunShi,
    GuaCalculationResult? guaResult,
    ShaoziTuibianPhase? phase,
    List<int>? tiaoWenNumbers,
  }) {
    return ShaoziTuibianSession(
      id: id ?? this.id,
      eightChars: eightChars ?? this.eightChars,
      yuanHuiYunShi: yuanHuiYunShi ?? this.yuanHuiYunShi,
      guaResult: guaResult ?? this.guaResult,
      phase: phase ?? this.phase,
      tiaoWenNumbers: tiaoWenNumbers ?? this.tiaoWenNumbers,
    );
  }

  @override
  String toString() =>
      'ShaoziTuibianSession(id: $id, phase: $phase, tiaoWenCount: ${tiaoWenNumbers.length})';
}
