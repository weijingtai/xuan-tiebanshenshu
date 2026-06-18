// 主题治理测试 — 确保迁移不引入违规依赖
//
// Phase 0a 门禁：
// 1. lib/ 不得直接 import package:xuan_config（仅允许通过 package:theme 间接使用）
// 2. lib/presentation/widgets/ 中 A 类 Widget 可直接使用 package:theme/theme.dart
// 3. lib/presentation/widgets/ 中 C 类 Widget 必须先解耦再迁移

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme 准入门禁', () {
    final libDir = Directory('lib');
    final widgetsDir = Directory('lib/presentation/widgets');

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
      const aClassWidgets = [
        'loading_widget.dart',
        'empty_state_widget.dart',
        'error_widget.dart',
        'tiao_wen_item.dart',
        'tiao_wen_list_view.dart',
        'calculation_summary.dart',
        'strategy_header.dart',
      ];
      for (final w in aClassWidgets) {
        expect(File('${widgetsDir.path}/$w').existsSync(), isTrue,
            reason: 'A 类 Widget $w 应在 $widgetsDir 中');
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
      const a = {
        'loading_widget.dart',
        'empty_state_widget.dart',
        'error_widget.dart',
        'tiao_wen_item.dart',
        'tiao_wen_list_view.dart',
        'calculation_summary.dart',
        'strategy_header.dart',
      };
      const c = {
        'gua_zhong_card.dart',
        'yuan_tang_liuyun_section.dart',
        'yuan_tang_card.dart',
        'kao_ding_liu_qin_card.dart',
      };
      final intersection = a.intersection(c);
      expect(intersection, isEmpty, reason: 'A 类和 C 类 Widget 不应重叠');
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
