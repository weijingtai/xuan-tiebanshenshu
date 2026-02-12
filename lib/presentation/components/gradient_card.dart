import 'dart:ui';
import 'package:flutter/material.dart';
import '../../presentation/theme/app_colors.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Prioritize color if provided, otherwise use theme's card gradient
            gradient: color == null ? AppColors.of(context).cardGradient : null,
            color: color,
            borderRadius: BorderRadius.circular(20),
            border:
                border ??
                Border.all(
                  color: AppColors.of(context).primaryColor.withOpacity(0.1),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}
