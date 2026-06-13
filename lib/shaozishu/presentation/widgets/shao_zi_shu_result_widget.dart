/// 邵子数计算结果展示组件
///
/// 展示 12 个数表格、天数/地数/本命基数/条文编号、计算过程、加一倍法展开。
/// Material Design 风格，支持紧凑模式（摘要卡片）。
library;

import 'package:flutter/material.dart';

import '../../helper/shao_zi_shu_calculation_helper.dart';

/// 邵子数计算结果展示组件
///
/// [result] 计算完整结果
/// [compact] 是否为紧凑摘要模式（默认 false，展示全部细节）
class ShaoZiShuResultWidget extends StatelessWidget {
  final ShaoZiShuResult result;
  final bool compact;

  const ShaoZiShuResultWidget({
    super.key,
    required this.result,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  compact ? '计算结果' : '邵子数计算结果',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 十二数表格
            _buildTwelveNumbersTable(context),
            const SizedBox(height: 16),

            // 关键数值
            _buildKeyNumbers(context),

            // 非紧凑模式展示完整细节
            if (!compact) ...[
              const Divider(height: 24),

              // 加一倍法展开
              _buildExpandedNumbers(context),
              const SizedBox(height: 16),

              // 计算过程
              _buildCalculationDetail(context),
            ],
          ],
        ),
      ),
    );
  }

  /// 十二数表格（4干 + 8支）
  Widget _buildTwelveNumbersTable(BuildContext context) {
    final theme = Theme.of(context);
    final numbers = result.twelveNumbers;

    // 天干名和地支名
    const ganNames = ['年干', '月干', '日干', '时干'];
    const zhiNames = ['年支', '月支', '日支', '时支'];

    return Table(
      border: TableBorder.all(
        color: theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1),
      },
      children: [
        // 表头
        TableRow(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          ),
          children: [
            _tableHeader('天干', context),
            _tableHeader('邵子数', context),
            _tableHeader('地支', context),
            _tableHeader('河图数', context),
          ],
        ),
        // 数据行
        for (var i = 0; i < 4; i++)
          TableRow(
            children: [
              _tableCell(ganNames[i], context, bold: true),
              _tableCell('${numbers[i]}', context),
              _tableCell(zhiNames[i], context, bold: true),
              _tableCell('${numbers[i + 4]}', context),
            ],
          ),
      ],
    );
  }

  /// 关键数值卡片
  Widget _buildKeyNumbers(BuildContext context) {
    final theme = Theme.of(context);

    final items = <_NumberItem>[
      _NumberItem('天数', '${result.tianShu}', '奇数和取模25'),
      _NumberItem('地数', '${result.diShu}', '偶数和取模30'),
      _NumberItem('本命基数', '${result.benMingJiShu}', '天数×8+地数'),
      _NumberItem('条文编号', '${result.tiaoWenNumber}', '本命基数×24%6144'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          width: (compact)
              ? (MediaQuery.of(context).size.width - 48) / 2
              : (MediaQuery.of(context).size.width - 48) / 2 - 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                item.hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 加一倍法展开
  Widget _buildExpandedNumbers(BuildContext context) {
    final theme = Theme.of(context);
    final expanded = result.expandedTiaoWenNumbers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '加一倍法展开（共 ${expanded.length} 个）',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: expanded.asMap().entries.map((entry) {
            final index = entry.key;
            final number = entry.value;
            final offset = [0, 96, -96, 192, -192, 384, -384, 768, -768];

            return Chip(
              avatar: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                radius: 12,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              label: Text(
                '$number${index > 0 ? ' (${offset[index] >= 0 ? "+" : ""}${offset[index]})' : ' (基础)'}',
                style: theme.textTheme.bodySmall,
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 计算过程描述
  Widget _buildCalculationDetail(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '计算过程',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: SelectableText(
            result.calculationDetail,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(
    String text,
    BuildContext context, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 关键数值模型
class _NumberItem {
  final String label;
  final String value;
  final String hint;

  const _NumberItem(this.label, this.value, this.hint);
}
