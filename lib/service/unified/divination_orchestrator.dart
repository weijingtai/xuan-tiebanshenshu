import 'dart:async';
import 'package:logger/logger.dart';
import '../../domain/models/unified/divination_context.dart';
import '../../domain/models/unified/divination_result.dart';
import 'unified_strategy_adapter.dart';

/// 内部结果包装类
class _ExecutionResult {
  final String strategyId;
  final DivinationResult result;
  _ExecutionResult(this.strategyId, this.result);
}

/// 排盘协调器
///
/// 负责管理策略依赖关系并执行排盘流程
class DivinationOrchestrator {
  final Logger _logger = Logger();
  final Map<String, UnifiedStrategyAdapter> _adapters = {};

  /// 注册策略适配器
  void register(UnifiedStrategyAdapter adapter) {
    if (_adapters.containsKey(adapter.strategyId)) {
      _logger.w(
        'Strategy ${adapter.strategyId} already registered. Overwriting.',
      );
    }
    _adapters[adapter.strategyId] = adapter;
  }

  /// 注册多个策略适配器
  void registerAll(List<UnifiedStrategyAdapter> adapters) {
    for (var adapter in adapters) {
      register(adapter);
    }
  }

  /// 执行所有已注册的策略, 返回流式更新的上下文
  ///
  /// 该方法会自动分析依赖关系并尽可能并行执行策略
  Stream<DivinationContext> execute(DivinationContext initialContext) async* {
    DivinationContext currentContext = initialContext;
    final Set<String> executedStrategyIds = Set<String>.from(
      currentContext.results.keys,
    );
    final Set<String> pendingStrategyIds = Set<String>.from(_adapters.keys)
      ..removeAll(executedStrategyIds);

    _logger.i(
      'Starting execution with ${pendingStrategyIds.length} pending strategies.',
    );

    // 循环执行，直到没有更多可执行的策略
    while (pendingStrategyIds.isNotEmpty) {
      // 找出所有当前可执行的策略（依赖已满足）
      final List<UnifiedStrategyAdapter> runnableAdapters = [];

      for (var id in pendingStrategyIds) {
        final adapter = _adapters[id]!; // key exists in pending
        // 检查依赖是否都在已执行集合中
        bool depsMet = adapter.dependencies.every(
          (depId) => executedStrategyIds.contains(depId),
        );
        if (depsMet) {
          runnableAdapters.add(adapter);
        }
      }

      if (runnableAdapters.isEmpty) {
        // 有待执行任务但无法执行 -> 循环依赖或缺少依赖
        _logger.e(
          'Circular dependency or missing dependencies detected. Pending: $pendingStrategyIds',
        );
        // 遇到这种情况，我们可以选择抛出异常，或者直接结束流
        // 为了UI不崩溃，我们记录错误并结束
        break;
      }

      // 并行执行本轮所有可运行策略
      _logger.d(
        'Executing batch: ${runnableAdapters.map((a) => a.strategyId).join(', ')}',
      );

      final List<Future<_ExecutionResult>> executionFutures = runnableAdapters
          .map((adapter) async {
            try {
              // 这里传入的是本轮开始时的Context，由于Context是不可变的，这在并发中是安全的
              // 即使同批次的其他任务也在运行，它们都读到一样的“前置状态”
              final result = await adapter.execute(currentContext);
              return _ExecutionResult(adapter.strategyId, result);
            } catch (e, stackTrace) {
              _logger.e(
                'Error executing strategy ${adapter.strategyId}',
                error: e,
                stackTrace: stackTrace,
              );
              // 构造一个错误结果，防止下游无限等待或崩溃
              return _ExecutionResult(
                adapter.strategyId,
                StandardDivinationResult.error(
                  strategyId: adapter.strategyId,
                  title: adapter.title,
                  error: e.toString(),
                ),
              );
            }
          })
          .toList();

      // 等待所有并行任务完成
      final results = await Future.wait(executionFutures);

      // 批量更新 Context
      for (var execResult in results) {
        currentContext = currentContext.withResult(
          execResult.strategyId,
          execResult.result,
        );
        executedStrategyIds.add(execResult.strategyId);
        pendingStrategyIds.remove(execResult.strategyId);
      }

      // 发射当前状态给 UI
      yield currentContext;
    }

    _logger.i('Execution finished.');
  }

  /// 同步获取依赖列表（用于调试或显示图）
  Map<String, List<String>> getDependencyGraph() {
    return _adapters.map((key, value) => MapEntry(key, value.dependencies));
  }
}
