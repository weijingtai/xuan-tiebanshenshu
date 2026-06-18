/// 元堂卦流运系统展示组件
///
/// 整合大运、流年、流月三层运势展示
library;

import 'package:flutter/material.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../viewmodels/yuan_tang_liuyun_view_model.dart';
import 'yuan_tang_liunian_list.dart';
import 'yuan_tang_liuyue_panel.dart';

/// 流运系统展示组件
///
/// 展示完整的流运系统：
/// - 先天卦大运 + 流年卦
/// - 后天卦大运 + 流年卦
/// - 点击流年卡片展开流月详情
class YuanTangLiuyunSection extends StatefulWidget {
  final YuanTangLiuyunViewModel viewModel;

  const YuanTangLiuyunSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<YuanTangLiuyunSection> createState() => _YuanTangLiuyunSectionState();
}

class _YuanTangLiuyunSectionState extends State<YuanTangLiuyunSection> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = widget.viewModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights,
                color: theme.colorScheme.primary,
                size: 22.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                '流运系统',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  '大运 → 流年 → 流月',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16.0),

        // 先天卦流运
        _buildXiantianLiuyunSection(theme),

        const SizedBox(height: 24.0),

        // 后天卦流运
        _buildHoutianLiuyunSection(theme),
      ],
    );
  }

  /// 构建先天卦流运展示
  Widget _buildXiantianLiuyunSection(ThemeData theme) {
    final vm = widget.viewModel;
    return _buildLiuyunSection(
      theme: theme,
      title: '先天卦流运（${vm.model.xiantianGua}）',
      liunianList: vm.xiantianLiunianList,
      dayunList: vm.xiantianDayunList,
      accentColor: theme.colorScheme.primary,
      guaSource: '先天卦',
      yuantangYaoIndex: vm.xiantianYuantangYaoIndex,
    );
  }

  /// 构建后天卦流运展示
  Widget _buildHoutianLiuyunSection(ThemeData theme) {
    final vm = widget.viewModel;
    return _buildLiuyunSection(
      theme: theme,
      title: '后天卦流运（${vm.model.houtianGua}）',
      liunianList: vm.houtianLiunianList,
      dayunList: vm.houtianDayunList,
      accentColor: theme.colorScheme.secondary,
      guaSource: '后天卦',
      yuantangYaoIndex: vm.houtianYuantangYaoIndex,
    );
  }

  /// 构建流运区域（通用）
  Widget _buildLiuyunSection({
    required ThemeData theme,
    required String title,
    required List<YuanTangLiunianGua> liunianList,
    required List<YuanTangDayunPeriod> dayunList,
    required Color accentColor,
    required String guaSource,
    required int yuantangYaoIndex,
  }) {
    final vm = widget.viewModel;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 4.0,
                height: 20.0,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // 按大运期展示流年卦
          ...dayunList.map((dayun) {
            final dayunLiunianList = liunianList
                .where(
                  (liunian) =>
                      liunian.dayunPeriod.yaoPosition == dayun.yaoPosition,
                )
                .toList();

            if (dayunLiunianList.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                YuanTangLiunianList(
                  dayunPeriod: dayun,
                  liunianList: dayunLiunianList,
                  guaSource: guaSource,
                  accentColor: accentColor,
                  showDayunTitle: true,
                  onLiunianTap: (age) => vm.selectLiunianAge(age),
                ),

                // 显示流月详情（如果已展开）
                if (vm.selectedLiunianAge != null) ...[
                  const SizedBox(height: 12.0),
                  _buildLiuyueDetailSection(
                    theme,
                    vm.selectedLiunianAge!,
                    vm.getLiuyueForAge(vm.selectedLiunianAge!)!,
                    accentColor,
                  ),
                ],

                const SizedBox(height: 16.0),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 构建流月详情展示区域
  Widget _buildLiuyueDetailSection(
    ThemeData theme,
    int age,
    List<YuanTangLiuyueGua> liuyueList,
    Color accentColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 关闭按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$age岁流月卦详情',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20.0),
                onPressed: () => widget.viewModel.deselectLiunianAge(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // 流月卡片网格
          YuanTangLiuyuePanel(
            liuyueList: liuyueList,
            accentColor: accentColor,
            showTitle: false,
            compact: false,
          ),
        ],
      ),
    );
  }
}

/// 流运系统紧凑型展示组件
///
/// 仅显示大运和流年卦，不支持展开流月
class YuanTangLiuyunCompactSection extends StatelessWidget {
  final YuanTangLiuyunViewModel viewModel;

  const YuanTangLiuyunCompactSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = viewModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '流运概览',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),

        // 先天卦流年概览
        _buildCompactOverview(
          theme,
          '先天卦',
          vm.xiantianLiunianList,
          theme.colorScheme.primary,
        ),

        const SizedBox(height: 8.0),

        // 后天卦流年概览
        _buildCompactOverview(
          theme,
          '后天卦',
          vm.houtianLiunianList,
          theme.colorScheme.secondary,
        ),
      ],
    );
  }

  /// 构建紧凑型概览
  Widget _buildCompactOverview(
    ThemeData theme,
    String label,
    List<YuanTangLiunianGua> liunianList,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4.0),
          Text('共${liunianList.length}个流年卦',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
