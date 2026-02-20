import 'package:flutter/material.dart';

/// A widget that renders text vertically (columns from right to left).
///
/// This is a simplified implementation for traditional Chinese vertical text.
/// It takes a string, splits it into lines (or characters), and arranges them
/// in a [Row] of [Column]s (if [isRightToLeft] is true) or similar custom layout.
///
/// For strict "vertical-rl" (lines flow from Right to Left), the [Row] should
/// have [TextDirection.rtl] or children should be reversed.
class VerticalTextWrapper extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double spacing;
  final double runSpacing;
  final double? minHeight;
  final TextDirection? textDirection;
  final bool allowWrapping;

  const VerticalTextWrapper({
    super.key,
    required this.text,
    this.style,
    this.spacing = 4.0,
    this.runSpacing = 8.0,
    this.minHeight,
    this.textDirection,
    this.allowWrapping = true,
  });

  @override
  Widget build(BuildContext context) {
    // If minHeight or maxHeight is provided, or we need to wrap.
    // The previous implementation splits by newline characters only.
    // For verses that are single long strings, we need to wrap them based on height.
    //
    // New Logic:
    // 1. If text has newlines, respect them (manual break).
    // 2. If a line is too long for the available height (context), wrap it to the next column.

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use provided style or default
        final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
        final fontSize = effectiveStyle.fontSize ?? 14.0;
        final lineHeight = (effectiveStyle.height ?? 1.2) * fontSize;
        final charHeight = lineHeight + spacing; // Approximate height per char

        // Calculate max chars per column based on height constraint
        // If minHeight is provided, use it. Otherwise use constraints.maxHeight.
        final height = minHeight ?? constraints.maxHeight;

        // If unbounded height, fallback to a reasonable default or don't wrap?
        // If unbounded, we can't wrap automatically.
        int charsPerCol = 100; // Default large number
        bool isUnbounded = height == double.infinity;

        if (!isUnbounded && height > 0) {
          charsPerCol = (height / charHeight).floor();
          if (charsPerCol <= 0) charsPerCol = 1;
        }

        List<String> columns = [];
        List<String> explicitLines = text.split('\n');

        for (var line in explicitLines) {
          if (line.isEmpty) {
            columns.add("");
            continue;
          }

          if (isUnbounded || !allowWrapping) {
            columns.add(line);
          } else {
            // Wrap logic
            for (int i = 0; i < line.length; i += charsPerCol) {
              int end = (i + charsPerCol < line.length)
                  ? i + charsPerCol
                  : line.length;
              columns.add(line.substring(i, end));
            }
          }
        }

        // If textDirection is not provided, default to RTL (Standard Chinese Vertical).
        final direction = textDirection ?? TextDirection.rtl;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: direction,
          children: columns.map((colText) {
            return Container(
              margin: EdgeInsets.only(
                left: direction == TextDirection.rtl ? runSpacing : 0,
                right: direction == TextDirection.ltr ? runSpacing : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: colText.split('').map((char) {
                  return Container(
                    margin: EdgeInsets.only(bottom: spacing),
                    child: Text(
                      char,
                      style: effectiveStyle.copyWith(
                        height: 1.0,
                      ), // Reset height for char container logic
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
