/// 邵子数主页面
///
/// 对标 kao_ke_interactive_page.dart，简化版（无交互选择）。
/// 纯演绎流程：初始化 → 计算 → 查看条文。
library;

import 'package:flutter/material.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:provider/provider.dart';

import '../view_model/shao_zi_shu_view_model.dart';
import '../domain/session/shao_zi_shu_session_models.dart';
import 'widgets/shao_zi_shu_result_widget.dart';
import 'widgets/tiao_wen_list_widget.dart';

/// 邵子数主页面
///
/// [eightChars] 用户八字（由上游页面传入）
class ShaoZiShuPage extends StatefulWidget {
  final EightChars eightChars;
  final String? sessionName;

  const ShaoZiShuPage({
    super.key,
    required this.eightChars,
    this.sessionName,
  });

  @override
  State<ShaoZiShuPage> createState() => _ShaoZiShuPageState();
}

class _ShaoZiShuPageState extends State<ShaoZiShuPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载后自动初始化会话
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final viewModel = context.read<ShaoZiShuViewModel>();
    await viewModel.initialize(
      eightChars: widget.eightChars,
      sessionName: widget.sessionName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('邵子神数'),
        actions: [
          // 回滚按钮（仅当可回滚时显示）
          Consumer<ShaoZiShuViewModel>(
            builder: (context, viewModel, child) {
              if (!viewModel.canRollback) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.undo),
                tooltip: '回滚到上一阶段',
                onPressed: () => _handleRollback(viewModel),
              );
            },
          ),
        ],
      ),
      body: Consumer<ShaoZiShuViewModel>(
        builder: (context, viewModel, child) {
          // 加载状态
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载中...'),
                ],
              ),
            );
          }

          // 错误状态
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '出错了: ${viewModel.error}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      viewModel.clearError();
                      _initialize();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          // 根据阶段展示内容
          return _buildPhaseContent(viewModel);
        },
      ),
    );
  }

  /// 根据当前阶段构建内容
  Widget _buildPhaseContent(ShaoZiShuViewModel viewModel) {
    final phase = viewModel.currentPhase;

    if (phase == null) {
      return const Center(child: Text('会话未初始化'));
    }

    switch (phase) {
      case ShaoZiShuSessionPhase.initialized:
        return _buildInitializedPhase(viewModel);

      case ShaoZiShuSessionPhase.calculating:
        return _buildCalculatingPhase();

      case ShaoZiShuSessionPhase.calculated:
        return _buildCalculatedPhase(viewModel);

      case ShaoZiShuSessionPhase.resultReady:
        return _buildResultReadyPhase(viewModel);
    }
  }

  // ==================== 各阶段 UI ====================

  /// initialized 阶段：显示八字信息 + "开始计算"按钮
  Widget _buildInitializedPhase(ShaoZiShuViewModel viewModel) {
    final eightChars = viewModel.eightChars;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '邵子神数',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            if (eightChars != null) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '输入八字',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${eightChars.yearGanZhi}  '
                        '${eightChars.monthGanZhi}  '
                        '${eightChars.dayGanZhi}  '
                        '${eightChars.hourGanZhi}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            FilledButton.icon(
              onPressed: () => _handleStartCalculation(viewModel),
              icon: const Icon(Icons.calculate),
              label: const Text('开始计算'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// calculating 阶段：显示计算中动画
  Widget _buildCalculatingPhase() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              '正在计算邵子数...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '河洛天地数法 · 加一倍法',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// calculated 阶段：显示计算结果摘要 + "查看条文"按钮
  Widget _buildCalculatedPhase(ShaoZiShuViewModel viewModel) {
    final result = viewModel.shaoZiShuResult;
    final record = viewModel.calculationRecord;

    if (result == null || record == null) {
      return const Center(child: Text('计算数据异常'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 结果摘要卡片
            ShaoZiShuResultWidget(result: result, compact: true),
            const SizedBox(height: 24),

            // 查看条文按钮
            FilledButton.icon(
              onPressed: () => _handleLoadTiaoWen(viewModel),
              icon: const Icon(Icons.menu_book),
              label: const Text('查看条文'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// resultReady 阶段：显示完整条文列表
  Widget _buildResultReadyPhase(ShaoZiShuViewModel viewModel) {
    final tiaoWenList = viewModel.tiaoWenResults;
    final expanded = viewModel.expandedTiaoWenResults;

    if (tiaoWenList == null || tiaoWenList.isEmpty) {
      return const Center(child: Text('暂无条文内容'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TiaoWenListWidget(
        tiaoWenList: tiaoWenList,
        expandedMap: expanded,
      ),
    );
  }

  // ==================== 事件处理 ====================

  Future<void> _handleStartCalculation(
    ShaoZiShuViewModel viewModel,
  ) async {
    await viewModel.startCalculation();
    // startCalculation 内部已推进到 calculating → calculated
    // ViewModel 通知后 Consumer 自动重建
  }

  Future<void> _handleLoadTiaoWen(
    ShaoZiShuViewModel viewModel,
  ) async {
    await viewModel.loadTiaoWenContent();
    // loadTiaoWenContent 内部已推进到 resultReady
  }

  Future<void> _handleRollback(ShaoZiShuViewModel viewModel) async {
    await viewModel.rollback();
  }
}
