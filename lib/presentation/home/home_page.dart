import 'package:flutter/material.dart';
import '../../presentation/components/glass_scaffold.dart';
import '../../presentation/components/gradient_card.dart';
import '../../presentation/components/section_header.dart';
import '../../presentation/theme/app_colors.dart';
import '../../presentation/theme/app_typography.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '铁版神数',
              style: AppTypography.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withOpacity(0.5),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            Text(
              'Tie Ban Shen Shu',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),

            const SectionHeader(title: '核心功能', subtitle: 'Core Features'),
            _buildFeatureGrid(context),

            const SizedBox(height: 32),
            const SectionHeader(title: '辅助工具', subtitle: 'Utilities'),
            _buildUtilitiesList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        title: '策略演示',
        subtitle: 'Comprehensive Strategy Demo',
        icon: Icons.auto_awesome,
        route: '/tiebanshenshu/strategy_demo',
        color: AppColors.primary,
      ),
      _FeatureItem(
        title: '四门枪法',
        subtitle: 'Four Doors & Gun Fa',
        icon: Icons.explore,
        route: '/tiebanshenshu/four_doors_and_gun_fa',
        color: AppColors.secondaryDark,
      ),
      _FeatureItem(
        title: '考刻交互',
        subtitle: 'Kao Ke Interactive',
        icon: Icons.access_time,
        route: '/tiebanshenshu/kaoke',
        color: Colors.teal,
      ),
      _FeatureItem(
        title: '皇极经世',
        subtitle: 'Huang Ji V2 Demo',
        icon: Icons.history_edu,
        route: '/tiebanshenshu/huang_ji_v2_demo',
        color: Colors.indigo,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final item = features[index];
        return GradientCard(
          onTap: () => Navigator.pushNamed(context, item.route),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: Colors.white, size: 28),
              ),
              const Spacer(),
              Text(
                item.title,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUtilitiesList(BuildContext context) {
    return Column(
      children: [
        _buildUtilityItem(
          context,
          title: '六亲考刻选择',
          subtitle: 'Liu Qin Kao Ke Selection',
          icon: Icons.people_outline,
          route: '/tiebanshenshu/liuqinkaoke/selection',
        ),
        const SizedBox(height: 12),
        _buildUtilityItem(
          context,
          title: '考订六亲',
          subtitle: 'Kao Ding Liu Qin',
          icon: Icons.manage_accounts,
          route: '/tiebanshenshu/kao_ding_liu_qin',
        ),
      ],
    );
  }

  Widget _buildUtilityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return GradientCard(
      onTap: () => Navigator.pushNamed(context, route),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.textTheme.titleSmall),
                Text(subtitle, style: AppTypography.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });
}
