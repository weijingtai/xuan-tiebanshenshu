import 'package:flutter/material.dart';

class Base18Theme {
  // Colors from base_18.html :root
  static const bgColor = Color(0xFFE8E4DD);
  static const paper = Color(0xFFFAF8F5);
  static const taixuanRed = Color(0xFFA62B1F);
  static const huangjiPurple = Color(0xFF512E5F);
  static const heluoGreen = Color(0xFF145A32);
  static const neutralBlack = Color(0xFF1A1A1B);
  static const inkText = Color(0xFF2B2B2B);
  static const idWatermarkColor = Color(0xFFB71C1C);
  static const idTextColor = Color(0xFF424242);
  static const idBg = Color(0xFFEEEEEE); // Light grey for ID background
  static const lineLight = Color(0xFFD7CCC8); // Dashed line color
  static const idText = Color(0xFF616161);

  // Seal Colors
  static const sealGreatGood = Color(0xFF1B5E20);
  static const sealGood = Color(0xFF43A047);
  static const sealNeutral = Color(0xFF757575);
  static const sealBad = Color(0xFFE53935);

  // Fonts
  static const fontSerif = ["Noto Serif SC", "Songti SC", "serif"];
  static const fontMono = ["JetBrains Mono", "monospace"];

  // Animation
  static const animDuration = Duration(milliseconds: 500);
  static const animCurve = Cubic(0.25, 0.46, 0.45, 0.94);
}

class VerseData {
  final String id;
  final String watermark;
  final String text;
  final List<String> tags;
  final String seal;
  final Color sealColor;
  final List<VerseVersion>? versions;

  const VerseData({
    required this.id,
    required this.watermark,
    required this.text,
    required this.tags,
    required this.seal,
    required this.sealColor,
    this.versions,
  });
}

class VerseVersion {
  final String source;
  final String content;
  final bool isPrimary;

  const VerseVersion({
    required this.source,
    required this.content,
    this.isPrimary = false,
  });
}
