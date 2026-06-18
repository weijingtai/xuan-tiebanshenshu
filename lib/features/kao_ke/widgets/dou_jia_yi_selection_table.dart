import 'package:metaphysics_core/enums.dart';
import 'package:flutter/material.dart';
import '../../../constant/kao_ke_constants.dart';

/// 斗甲乙宫（三宫之数）选择表格
///
/// 展示当前宫的四支（刻）× 每支 1-5 条目
/// 单元格显示条文内容（并附带编号），点击进行选择
class DouJiaYiSelectionTable extends StatefulWidget {
  final Map<DiZhi, List<DouJiaYiNumber>> douData;

  final DiZhi birthShiChen;

  final void Function(DouJiaYiNumber) onItemSelected;

  final Map<int, String>? contentMap;

  const DouJiaYiSelectionTable({
    super.key,
    required this.douData,
    required this.birthShiChen,
    required this.onItemSelected,
    this.contentMap,
  });

  @override
  State<DouJiaYiSelectionTable> createState() => _DouJiaYiSelectionTableState();
}

class _DouJiaYiSelectionTableState extends State<DouJiaYiSelectionTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(child: _buildTable(context)),
    );
  }

  Widget _buildTable(BuildContext context) {
    final orders = [1, 2, 3, 4, 5];

    final keys = widget.douData.keys.toSet();
    final possibleOrders = const [
      [DiZhi.ZI, DiZhi.WU, DiZhi.MAO, DiZhi.YOU],
      [DiZhi.CHEN, DiZhi.XU, DiZhi.CHOU, DiZhi.WEI],
      [DiZhi.YIN, DiZhi.SHEN, DiZhi.SI, DiZhi.HAI],
    ];
    List<DiZhi> rowOrder = possibleOrders.firstWhere(
      (o) => o.every(keys.contains),
      orElse: () => keys.toList(),
    );

    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.primaryContainer,
      ),
      columnSpacing: 16,
      horizontalMargin: 16,
      columns: [
        const DataColumn(
          label: Text('刻（地支）', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...orders.map(
          (ord) => const DataColumn(
            label: Text('序', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
      rows: rowOrder.map((zhi) {
        final rowColor = Colors.black87;
        final items = widget.douData[zhi] ?? const [];

        return DataRow(
          color: WidgetStateProperty.all(
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.12),
          ),
          cells: [
            DataCell(
              Text(
                '${zhi.name}刻',
                style: TextStyle(color: rowColor, fontWeight: FontWeight.w600),
              ),
            ),
            ...orders.map((ord) {
              final item = items
                  .where((e) => e.order == ord)
                  .cast<DouJiaYiNumber?>()
                  .firstWhere((e) => e != null, orElse: () => null);

              return DataCell(
                InkWell(
                  onTap: item == null
                      ? null
                      : () => widget.onItemSelected(item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: item == null
                        ? Text(
                            '-',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '条文内容',
                                style: TextStyle(
                                  color: rowColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _displayContent(item.tiaoWenNumber),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: rowColor, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '编号 ${item.tiaoWenNumber}',
                                style: TextStyle(
                                  color: rowColor.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  String _displayContent(int number) {
    if (widget.contentMap == null) {
      return '加载中…';
    }
    final content = widget.contentMap![number];
    return content ?? '未找到内容';
  }
}
