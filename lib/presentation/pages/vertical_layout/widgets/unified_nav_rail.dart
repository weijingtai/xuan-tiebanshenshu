import 'package:flutter/material.dart';
import '../models/base_18_models.dart';

class UnifiedNavRail extends StatelessWidget {
  final Function(int) onTap;
  final bool isTinyMode;

  const UnifiedNavRail({
    super.key,
    required this.onTap,
    required this.isTinyMode,
  });

  @override
  Widget build(BuildContext context) {
    // In Base 18, rail is visible in both modes, but styles might differ slightly
    // actually, in CSS .mode-tiny .nav-rail { opacity: 1 } so it's always there.
    // The dots target specific groups.

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0, "皇极经世", Base18Theme.huangjiPurple),
        const SizedBox(height: 12),
        _buildDot(
          2,
          "太玄数",
          Base18Theme.taixuanRed,
        ), // Index 2 based on page list
        const SizedBox(height: 12),
        _buildDot(3, "河洛数", Base18Theme.heluoGreen),
      ],
    );
  }

  Widget _buildDot(int index, String label, Color color) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Tooltip(
        message: label,
        preferBelow: false,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 10),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.transparent,
              width: 2,
            ), // Invisible border for sizing
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
