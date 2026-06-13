import 'package:flutter/material.dart';

/// App Theme Data requiring a primary color and brightness
///
/// This class encapsulates the color palette for the application,
/// providing curated "New Chinese" aesthetics.
class AppThemeData {
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color backgroundColor;
  final Color textColor;
  final LinearGradient primaryGradient;
  final LinearGradient cardGradient;

  const AppThemeData({
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.textColor,
    required this.primaryGradient,
    required this.cardGradient,
  });

  /// 预设主题列表 - 新中式色系
  static List<AppThemeData> get presets => [
    tianQing, // 天青
    zhuSha, // 朱砂
    moYu, // 墨玉
    tengHuang, // 藤黄
    ziTan, // 紫檀
  ];

  // 1. 天青 (Tian Qing) - Ru Kiln Blue (Serene, Wisdom)
  // "雨过天青云破处，这般颜色做将来"
  static const tianQing = AppThemeData(
    name: '天青',
    description: '雨过天青，温润如玉',
    primaryColor: Color(0xFF7D9BB3), // Cyan-Blue
    secondaryColor: Color(0xFFE0C38C), // Pale Gold
    surfaceColor: Color(0xFF1E2732), // Dark Slate
    backgroundColor: Color(0xFF0F141A), // Deep Night Blue
    textColor: Color(0xFFEBF5F0), // Off-white
    primaryGradient: LinearGradient(
      colors: [Color(0xFF7D9BB3), Color(0xFF4A687F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x337D9BB3), // 20%
        Color(0x1A4A687F), // 10%
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 2. 朱砂 (Zhu Sha) - Cinnabar Red (Classic, Auspicious)
  // 辟邪纳福，正统之色
  static const zhuSha = AppThemeData(
    name: '朱砂',
    description: '丹砂红艳，辟邪纳福',
    primaryColor: Color(0xFFC04851), // Cinnabar Red
    secondaryColor: Color(0xFFFFD700), // Gold
    surfaceColor: Color(0xFF2B1214), // Dark Reddish Brown
    backgroundColor: Color(0xFF1A0A0B), // Deep Maroon
    textColor: Color(0xFFF2E6E6),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFC04851), Color(0xFF8B2329)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0x33C04851), Color(0x1A8B2329)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 3. 墨玉 (Mo Yu) - Ink Jade/Black (Deep, Mystic)
  // 玄之又玄，众妙之门
  static const moYu = AppThemeData(
    name: '墨玉',
    description: '玄黑深邃，温润内敛',
    primaryColor: Color(0xFF4B5C5E), // Jade Black/Green
    secondaryColor: Color(0xFFA6A6A6), // Silver
    surfaceColor: Color(0xFF1C1C1C), // Obsidian
    backgroundColor: Color(0xFF0A0A0A), // Pure Black
    textColor: Color(0xFFE0E0E0),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF4B5C5E), Color(0xFF2F3A3B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0x334B5C5E), Color(0x1A2F3A3B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 4. 藤黄 (Teng Huang) - Gamboge Yellow (Royal, Bright)
  // 正大光明，皇家风范
  static const tengHuang = AppThemeData(
    name: '藤黄',
    description: '明亮尊贵，正大光明',
    primaryColor: Color(0xFFFFB61E), // Imperial Yellow
    secondaryColor: Color(0xFF8B0000), // Dark Red highlight
    surfaceColor: Color(0xFF262014), // Dark Brown
    backgroundColor: Color(0xFF14100A), // Deep Brown
    textColor: Color(0xFFFFF8E1),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFFFB61E), Color(0xFFC58E00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0x33FFB61E), Color(0x1AC58E00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 5. 紫檀 (Zi Tan) - Sandalwood Purple (Elegant, Noble)
  // 紫气东来，祥瑞隐隐
  static const ziTan = AppThemeData(
    name: '紫檀',
    description: '紫气东来，高贵典雅',
    primaryColor: Color(0xFF6A4C9C), // Purple
    secondaryColor: Color(0xFFE0C38C), // Pale Gold
    surfaceColor: Color(0xFF1D162B), // Deep Purple
    backgroundColor: Color(0xFF0F0B1E), // Dark Theme Base
    textColor: Color(0xFFF3E5F5),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF6A4C9C), Color(0xFF4A148C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0x336A4C9C), Color(0x1A4A148C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
