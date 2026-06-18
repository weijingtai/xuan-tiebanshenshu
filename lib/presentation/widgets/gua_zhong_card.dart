import 'package:flutter/material.dart';
import '../viewmodels/gua_zhong_view_model.dart';
import '../components/gradient_card.dart';
import '../styles/tie_ban_semantic_colors.dart';

/// 卦中取数法展示卡片
///
/// 显示卦中取数法的计算结果和条文内容
class GuaZhongCard extends StatelessWidget {
  final GuaZhongViewModel viewModel;

  const GuaZhongCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GradientCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  const Icon(Icons.calculate, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    '卦中取数法',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // 四柱信息
              _buildInfoRow(
                context,
                '四柱',
                viewModel.fourZhuDisplayText,
                Icons.calendar_today,
              ),
              const SizedBox(height: 16),

              // 方案选择区域
              _buildPlanSelector(context),
              const SizedBox(height: 16),

              // 状态显示
              if (viewModel.isLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (viewModel.hasError) ...[
                _buildErrorView(context, viewModel.errorMessage!),
              ] else if (viewModel.hasResult) ...[
                // 年月卦
                _buildGuaSection(
                  context,
                  '年月卦',
                  viewModel.nianYueGuaDisplayText,
                  viewModel.nianYueUpperGuaDisplayText,
                  viewModel.nianYueLowerGuaDisplayText,
                  viewModel.nianYueGuaDescription,
                  viewModel.nianYueTiaoWenNumbers,
                  TieBanSemanticColors.plan1,
                ),
                const SizedBox(height: 16),

                // 日时卦
                _buildGuaSection(
                  context,
                  '日时卦',
                  viewModel.riShiGuaDisplayText,
                  viewModel.riShiUpperGuaDisplayText,
                  viewModel.riShiLowerGuaDisplayText,
                  viewModel.riShiGuaDescription,
                  viewModel.riShiTiaoWenNumbers,
                  TieBanSemanticColors.plan2,
                ),
                const SizedBox(height: 16),

                // 条文统计
                _buildTiaoWenStats(context),
                const SizedBox(height: 16),

                // 条文列表
                if (viewModel.result != null &&
                    viewModel.result!.tiaoWenEntities.isNotEmpty) ...[
                  _buildTiaoWenList(context),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  /// 构建方案选择器
  Widget _buildPlanSelector(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        '千位计算方案选择',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '已选 ${viewModel.selectedPlans.length} 个方案',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      initiallyExpanded: true,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 方案说明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '关于千位计算',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当上卦先天数为4（震卦）时，(4+6)=10，%10=0会导致三位数条文。\n提供三种解决方案供选择：',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 方案1: 蓝色
              CheckboxListTile(
                value: viewModel.isPlan1Selected,
                onChanged: (_) => viewModel.togglePlan(1),
                title: const Text(
                  '方案1：取1代替0（推荐）',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  '示例：震卦(4) → 千位=1 → 1484\n保持四位数格式，符合铁板神数规范',
                  style: TextStyle(fontSize: 11),
                ),
                secondary: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: TieBanSemanticColors.plan1,
                    shape: BoxShape.circle,
                  ),
                ),
                activeColor: TieBanSemanticColors.plan1,
              ),

              // 方案2: 绿色
              CheckboxListTile(
                value: viewModel.isPlan2Selected,
                onChanged: (_) => viewModel.togglePlan(2),
                title: const Text(
                  '方案2：取卦先天数',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  '示例：震卦(4) → 千位=4 → 4484\n保留卦象数字特征',
                  style: TextStyle(fontSize: 11),
                ),
                secondary: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: TieBanSemanticColors.plan2,
                    shape: BoxShape.circle,
                  ),
                ),
                activeColor: TieBanSemanticColors.plan2,
              ),

              // 方案3: 橙色
              CheckboxListTile(
                value: viewModel.isPlan3Selected,
                onChanged: (_) => viewModel.togglePlan(3),
                title: const Text(
                  '方案3：保留10（五位数）',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  '示例：震卦(4) → 千位=10 → 10484\n完全按照原始算法，但打破四位数规范',
                  style: TextStyle(fontSize: 11),
                ),
                secondary: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: TieBanSemanticColors.plan3,
                    shape: BoxShape.circle,
                  ),
                ),
                activeColor: TieBanSemanticColors.plan3,
              ),

              const SizedBox(height: 8),
              // 重置按钮
              Center(
                child: TextButton.icon(
                  onPressed: viewModel.resetPlans,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('重置为全部方案'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建卦象区域（年月卦或日时卦）
  Widget _buildGuaSection(
    BuildContext context,
    String title,
    String guaDisplay,
    String upperGua,
    String lowerGua,
    String description,
    List<int> tiaoWenNumbers,
    Color color,
  ) {
    final numbersWithLabel = viewModel.getFilteredNumbersForSection(title);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(Icons.hexagon_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 卦象信息
          Text(guaDisplay, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            '上卦: $upperGua',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          Text(
            '下卦: $lowerGua',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),

          // 计算说明
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 8),

          // 按方案分组显示条文编号
          if (numbersWithLabel.isNotEmpty) ...[
            const Text(
              '条文编号（按方案）：',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...List.generate(3, (index) {
              final planNumber = index + 1;
              if (!viewModel.selectedPlans.contains(planNumber)) {
                return const SizedBox.shrink();
              }

              // 筛选该方案的条文
              final planNumbers = numbersWithLabel
                  .where((item) => item.$2 == planNumber)
                  .toList();

              if (planNumbers.isEmpty) {
                return const SizedBox.shrink();
              }

              // 方案颜色
              final planColor = _getPlanColor(planNumber);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: planColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '方案$planNumber',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: planColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: planNumbers.map((item) {
                        final number = item.$1;
                        final position = item.$3;
                        final isZhuGua = position.contains('主卦');

                        return Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                number.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isZhuGua
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isZhuGua ? '主' : '互',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: planColor.withOpacity(0.2),
                          side: BorderSide(color: planColor.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// 获取方案颜色
  Color _getPlanColor(int planNumber) => switch (planNumber) {
    1 => TieBanSemanticColors.plan1,
    2 => TieBanSemanticColors.plan2,
    3 => TieBanSemanticColors.plan3,
    _ => TieBanSemanticColors.planUnknown,
  };

  /// 构建条文统计
  Widget _buildTiaoWenStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            '总条文数',
            viewModel.allTiaoWenNumbers.length.toString(),
            Colors.grey[700]!,
          ),
          _buildStatItem(
            context,
            '年月卦',
            viewModel.nianYueTiaoWenNumbers.length.toString(),
            Colors.blueGrey,
          ),
          _buildStatItem(
            context,
            '日时卦',
            viewModel.riShiTiaoWenNumbers.length.toString(),
            Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// 构建条文列表
  Widget _buildTiaoWenList(BuildContext context) {
    final tiaoWenEntities = viewModel.result!.tiaoWenEntities;

    return ExpansionTile(
      title: const Text('条文内容'),
      initiallyExpanded: false,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiaoWenEntities.length,
          itemBuilder: (context, index) {
            final tiaoWen = tiaoWenEntities[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    (tiaoWen.id - 1000).toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
                title: Text(
                  tiaoWen.content1,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '地支: ${tiaoWen.setName.name}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
