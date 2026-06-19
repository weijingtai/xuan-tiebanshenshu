// 主题治理测试 — 确保迁移不引入违规依赖
//
// Phase 0a 门禁：
// 1. lib/ 不得直接 import package:xuan_config（仅允许通过 package:theme 间接使用）
// 2. lib/presentation/widgets/ + lib/presentation/components/ 中 A 类 Widget
//    可直接使用 package:theme/theme.dart
// 3. C 类 Widget 必须先解耦再迁移
// 4. 所有 A 类 Widget 的组件 ID 必须存在于 a_class_tokens.dart 的程序化定义中

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/presentation/theme/a_class_tokens.dart';
import 'package:tiebanshenshu/presentation/theme/app_theme_data.dart';

void main() {
  group('Theme 准入门禁', () {
    final libDir = Directory('lib');
    final widgetsDir = Directory('lib/presentation/widgets');
    final componentsDir = Directory('lib/presentation/components');

    /// A 类 Widget 清单（首批可迁移的纯展示 / 仅样式耦合组件）。
    /// widgets/ 目录 7 个 + components/ 目录 4 个。
    const aClassWidgets = [
      // widgets/
      'loading_widget.dart',
      'empty_state_widget.dart',
      'error_widget.dart',
      'tiao_wen_item.dart',
      'tiao_wen_list_view.dart',
      'calculation_summary.dart',
      'strategy_header.dart',
      'interactive_step_indicator.dart',
      // components/
      'section_header.dart',
      'gradient_card.dart',
      'animated_button.dart',
    ];

    test('lib/ 不得直接 import package:xuan_config', () {
      final hits = <String>[];
      _walkFiles(libDir, (path) {
        try {
          final content = File(path).readAsStringSync();
          if (content.contains("import 'package:xuan_config/")) {
            hits.add(path);
          }
        } catch (_) {}
      });
      expect(hits, isEmpty,
          reason:
              'lib/ 不得直接 import package:xuan_config，应只通过 package:theme 间接使用。'
              ' 发现: $hits');
    });

    test('A 类 Widget 清单已固定', () {
      for (final w in aClassWidgets) {
        final exists =
            File('${widgetsDir.path}/$w').existsSync() ||
            File('${componentsDir.path}/$w').existsSync();
        expect(exists, isTrue,
            reason: 'A 类 Widget $w 应在 $widgetsDir 或 $componentsDir 中');
      }
    });

    test('C 类 Widget 清单已固定', () {
      const cClassWidgets = [
        'gua_zhong_card.dart',
        'yuan_tang_liuyun_section.dart',
        'yuan_tang_card.dart',
        'kao_ding_liu_qin_card.dart',
      ];
      for (final w in cClassWidgets) {
        expect(File('${widgetsDir.path}/$w').existsSync(), isTrue,
            reason: 'C 类 Widget $w 应在 $widgetsDir 中');
      }
    });

    test('所有 A + C 类 Widget 不重复', () {
      const a = <String>{
        'loading_widget.dart',
        'empty_state_widget.dart',
        'error_widget.dart',
        'tiao_wen_item.dart',
        'tiao_wen_list_view.dart',
        'calculation_summary.dart',
        'strategy_header.dart',
        'interactive_step_indicator.dart',
        'section_header.dart',
        'gradient_card.dart',
        'animated_button.dart',
      };
      const c = <String>{
        'gua_zhong_card.dart',
        'yuan_tang_liuyun_section.dart',
        'yuan_tang_card.dart',
        'kao_ding_liu_qin_card.dart',
      };
      final intersection = a.intersection(c);
      expect(intersection, isEmpty, reason: 'A 类和 C 类 Widget 不应重叠');
    });

    test('A 类 Widget 组件 ID 在 a_class_tokens 中有定义', () {
      const aClassIds = [
        'loading',
        'empty_state',
        'error',
        'tiao_wen_item',
        'tiao_wen_list_view',
        'calculation_summary',
        'strategy_header',
        'interactive_step_indicator',
        'section_header',
        'gradient_card',
        'animated_button',
      ];

      final styles = buildATokenStyles(AppThemeData.moYu);

      for (final id in aClassIds) {
        expect(styles.containsKey(id), isTrue,
            reason: 'a_class_tokens.dart 缺少组件 ID "$id"');
        expect(styles[id], isNotNull,
            reason: 'a_class_tokens.dart 中组件 ID "$id" 的值为 null');
      }
    });
  });
}

void _walkFiles(Directory dir, void Function(String path) callback) {
  if (!dir.existsSync()) return;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      callback(entity.path);
    }
  }
}
