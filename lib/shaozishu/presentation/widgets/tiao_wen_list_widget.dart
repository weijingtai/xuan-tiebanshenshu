/// 条文列表组件
///
/// 显示邵子数条文列表，每条含编号 + 地支 + 内容。
/// 点击弹出详情对话框（编号 + 完整内容 + 年龄信息）。
library;

import 'package:flutter/material.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

/// 条文列表组件
///
/// [tiaoWenList] 条文数据列表
/// [expandedMap] 扩展条文映射（编号 → 内容），用于区分主条文和扩展条文
class TiaoWenListWidget extends StatelessWidget {
  final List<TiaoWenDataModel> tiaoWenList;
  final Map<int, TiaoWenDataModel>? expandedMap;

  const TiaoWenListWidget({
    super.key,
    required this.tiaoWenList,
    this.expandedMap,
  });

  @override
  Widget build(BuildContext context) {
    if (tiaoWenList.isEmpty) {
      return const Center(child: Text('暂无条文'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.menu_book,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '条文列表（共 ${tiaoWenList.length} 条）',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: tiaoWenList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = tiaoWenList[index];
              final isExpanded = expandedMap != null &&
                  expandedMap!.containsKey(item.id);
              // 基础条文（编号 == expandedMap 中的第一个）标记为主条文
              final isPrimary =
                  expandedMap != null && index == 0;

              return _TiaoWenListTile(
                item: item,
                isPrimary: isPrimary,
                isExpanded: isExpanded && !isPrimary,
                onTap: () => _showDetailDialog(context, item, isPrimary),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 显示条文详情对话框
  void _showDetailDialog(
    BuildContext context,
    TiaoWenDataModel item,
    bool isPrimary,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (isPrimary)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '主条文',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('条文 #${item.id}'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 编号 + 地支
              _buildDetailRow(
                context,
                '编号',
                '${item.id}',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                '地支',
                item.setName.name,
              ),
              const SizedBox(height: 16),

              // 条文内容
              Text(
                '条文内容',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: SelectableText(
                  item.content1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
              ),

              // 年龄信息
              if (item.ageSet1 != null && item.ageSet1!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '对应年龄',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.ageSet1!
                      .map((age) => Chip(
                            label: Text('$age岁'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

/// 单条条文列表项
class _TiaoWenListTile extends StatelessWidget {
  final TiaoWenDataModel item;
  final bool isPrimary;
  final bool isExpanded;
  final VoidCallback onTap;

  const _TiaoWenListTile({
    required this.item,
    required this.isPrimary,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isPrimary
            ? theme.colorScheme.primary
            : theme.colorScheme.secondaryContainer,
        radius: 18,
        child: Text(
          '${item.id}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.content1,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '主',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '扩',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${item.setName.name} · 条文 #${item.id}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
