// Phase 0a 首批 A 类 Widget 主题 token 定义。
//
// 程序化地从 [AppThemeData] 提取颜色值构建 [ComponentStyle]。
// 不依赖 YAML 文件 / ConfigRepository，规避 Phase 0a 的加载层依赖。
//
// 各 widget 的组件 ID 与 [buildATokenStyles] 返回的 key 一一对应。
// 消费方统一使用 [XuanThemeData.of(context).component(id)] 模式。

import 'package:flutter/material.dart';
import 'package:theme/theme.dart';
import 'app_theme_data.dart';

/// 根据 [theme] 构建 A 类 widget 的完整 [ComponentStyle] 字典。
/// 仅定义 container 级属性（background / border / shadow / radius / padding），
/// text_color / spinner_color 等暂由 [Theme.of(context)] 兜底。
Map<String, ComponentStyle> buildATokenStyles(AppThemeData theme) {
  final p = theme.primaryColor;
  final surf = theme.surfaceColor;

  return {
    // ── loading_widget ──────────────────────────────────────────────
    'loading': ComponentStyle(
      radius: 8.0,
      background: surf.withValues(alpha: 0.5),
    ),

    // ── empty_state_widget ──────────────────────────────────────────
    'empty_state': ComponentStyle(
      // container 属性暂缺，text/icon color 由 Theme.of 兜底
    ),

    // ── error_widget ────────────────────────────────────────────────
    'error': ComponentStyle(
      radius: 8.0,
      background: surf.withValues(alpha: 0.5),
      border: BorderSide(color: p.withValues(alpha: 0.3)),
    ),

    // ── tiao_wen_item ───────────────────────────────────────────────
    'tiao_wen_item': ComponentStyle(
      radius: 12.0,
      padding: const EdgeInsets.all(16.0),
    ),

    // ── tiao_wen_list_view ──────────────────────────────────────────
    'tiao_wen_list_view': ComponentStyle(
      background: p.withValues(alpha: 0.3),
      border: BorderSide(color: p.withValues(alpha: 0.3)),
    ),

    // ── calculation_summary ─────────────────────────────────────────
    'calculation_summary': ComponentStyle(
      background: surf.withValues(alpha: 0.3),
    ),

    // ── strategy_header ─────────────────────────────────────────────
    'strategy_header': ComponentStyle(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),

    // ── section_header ──────────────────────────────────────────────
    'section_header': ComponentStyle(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
    ),

    // ── gradient_card ───────────────────────────────────────────────
    'gradient_card': ComponentStyle(
      radius: 20.0,
    ),

    // ── animated_button ─────────────────────────────────────────────
    'animated_button': ComponentStyle(
      radius: 12.0,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      shadow: BoxShadow(
        color: p.withValues(alpha: 0.4),
        blurRadius: 10.0,
        offset: const Offset(0, 4),
      ),
    ),

    // ── interactive_step_indicator ──────────────────────────────────
    'interactive_step_indicator': ComponentStyle(
      radius: 8.0,
      background: surf.withValues(alpha: 0.1),
      border: BorderSide(color: p.withValues(alpha: 0.3)),
    ),
  };
}
