import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'divination_result.dart';
import '../yuan_hui_yun_shi.dart';

/// 排盘上下文
///
/// 作为不可变的状态容器，持有所有排盘所需的信息和中间结果
class DivinationContext {
  /// 八字信息 (必需)
  final EightChars eightChars;

  /// 性别 (必需)
  final Gender gender;

  /// 三元 (可选，上元/中元/下元)
  /// 如果未提供，可能需要通过算法推导
  /// TODO: 使用强类型枚举 ThreeYuan
  final dynamic threeYuan;

  /// 出生节气 (可选，用于决定前后卦等)
  /// TODO: 使用强类型 BirthAfterZhi
  final dynamic birthAfterZhi;

  /// 刻分 (可选，用于六亲考刻)
  final String? keFen;

  /// 元会运世 (派生状态，可选)
  final YuanHuiYunShi? yuanHuiYunShi;

  /// 策略执行结果
  /// Key: StrategyID
  /// Value: DivinationResult
  final Map<String, DivinationResult> results;

  const DivinationContext({
    required this.eightChars,
    required this.gender,
    this.threeYuan,
    this.birthAfterZhi,
    this.keFen,
    this.yuanHuiYunShi,
    this.results = const {},
  });

  /// 创建一个新的上下文
  factory DivinationContext.create({
    required EightChars eightChars,
    required Gender gender,
  }) {
    return DivinationContext(
      eightChars: eightChars,
      gender: gender,
      // 可以在这里进行一些基础的派生计算，如 YuanHuiYunShi
      // 注意: YuanHuiYunShi.fromEightChars 可能需要更多参数(如Mapper)，这里使用默认值
      yuanHuiYunShi: YuanHuiYunShi.fromEightChars(eightChars),
    );
  }

  /// 复制并更新上下文
  ///
  /// 用于创建新的分叉状态 (Forking)
  DivinationContext copyWith({
    EightChars? eightChars,
    Gender? gender,
    dynamic threeYuan,
    dynamic birthAfterZhi,
    String? keFen,
    YuanHuiYunShi? yuanHuiYunShi,
    Map<String, DivinationResult>? results,
  }) {
    return DivinationContext(
      eightChars: eightChars ?? this.eightChars,
      gender: gender ?? this.gender,
      threeYuan: threeYuan ?? this.threeYuan,
      birthAfterZhi: birthAfterZhi ?? this.birthAfterZhi,
      keFen: keFen ?? this.keFen,
      yuanHuiYunShi: yuanHuiYunShi ?? this.yuanHuiYunShi,
      results: results ?? this.results,
    );
  }

  /// 添加或更新策略结果
  DivinationContext withResult(String strategyId, DivinationResult result) {
    final newResults = Map<String, DivinationResult>.from(results);
    newResults[strategyId] = result;
    return copyWith(results: newResults);
  }

  /// 获取指定策略的结果
  DivinationResult? getResult(String strategyId) {
    return results[strategyId];
  }

  @override
  String toString() {
    return 'DivinationContext(eightChars: $eightChars, gender: $gender, results: ${results.length})';
  }
}
