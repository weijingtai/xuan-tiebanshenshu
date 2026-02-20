import 'package:flutter/material.dart';
import '../../presentation/theme/app_colors.dart';
import '../../presentation/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          ?trailing,
        ],
      ),
    );
  }
}
