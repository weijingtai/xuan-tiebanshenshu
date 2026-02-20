import '../../domain/models/unified/divination_context.dart';
import '../../domain/models/unified/divination_result.dart';

/// 统一策略适配器接口
///
/// 所有排盘算法都必须通过此适配器接入 Orcehstrator。
/// 将不同结构的算法输出转换为统一的 DivinationResult。
abstract class UnifiedStrategyAdapter {
  /// 策略唯一ID (Strategy ID)
  String get strategyId;

  /// 策略显示名称 (如 "太玄四柱")
  String get title;

  /// 该策略依赖的其他策略ID列表
  /// Orchestrator 将确保所有依赖项成功执行后再执行此策略
  List<String> get dependencies;

  /// 执行策略计算
  ///
  /// [context] 当前排盘上下文，包含之前的计算结果
  /// 返回标准化的 DivinationResult
  Future<DivinationResult> execute(DivinationContext context);
}
