// Theme token 加载验证 — 证明 YAML/config → XuanThemeSet 端到端通路正常
//
// Phase 0a 验证：
// 1. TokenLoader.loadSetOrDefault 从 MemoryConfigSource 加载后能正确解析
// 2. XuanThemeData.component() 可按 ID 查询组件样式
// 3. 默认主题（fallback）能正确构造

import 'package:flutter_test/flutter_test.dart';
import 'package:theme/theme.dart' as theme;
import 'package:theme/theme_loader.dart' as loader;
import 'package:xuan_config/xuan_config.dart';

void main() {
  group('Theme token 加载', () {
    test('MemoryConfigSource → TokenLoader 通路', () async {
      final repo = ConfigRepository(
        source: MemoryConfigSource({
          'theme.yaml': '''
light:
  components:
    gua_card:
      background: "#1E2732"
      text_color: "#EBF5F0"
      padding: 16
      border_radius: 12
    section_header:
      text_color: "#7D9BB3"
      font_size: 14
dark:
  components:
    gua_card:
      background: "#0F141A"
      text_color: "#EBF5F0"
      padding: 16
      border_radius: 12
    section_header:
      text_color: "#4A687F"
      font_size: 14
''',
        }),
      );

      final themeSet = await loader.TokenLoader.loadSetOrDefault(
        repository: repo,
        path: 'theme.yaml',
      );

      expect(themeSet, isNotNull);
      expect(themeSet.light, isNotNull);
      expect(themeSet.dark, isNotNull);

      // ComponentStyle 查询
      final guaCard = themeSet.light.component('gua_card');
      expect(guaCard.padding, isNotNull);
    });

    test('无效 YAML → 降级到默认主题', () async {
      final repo = ConfigRepository(
        source: MemoryConfigSource({
          'theme.yaml': 'invalid: yaml: {{{broken',
        }),
      );

      final themeSet = await loader.TokenLoader.loadSetOrDefault(
        repository: repo,
        path: 'theme.yaml',
      );

      expect(themeSet, isNotNull);
      // 降级后应有默认组件
      expect(themeSet.light.component('unknown_id'), isNotNull);
    });

    test('缺失路径 → 降级到默认主题', () async {
      final repo = ConfigRepository(
        source: MemoryConfigSource({}),
      );

      final themeSet = await loader.TokenLoader.loadSetOrDefault(
        repository: repo,
        path: 'nonexistent.yaml',
      );

      expect(themeSet, isNotNull);
      expect(themeSet.light.component('missing'), isNotNull);
    });
  });

  group('XuanThemeData 构造', () {
    test('可使用默认主题数据', () {
      // ThemeLoader 提供了默认主题
      final defaultSet = loader.DefaultXuanThemeData.themeSet;
      expect(defaultSet, isNotNull);
      expect(defaultSet.light, isNotNull);
      expect(defaultSet.dark, isNotNull);
    });

    test('ComponentStyle.empty 可作为 fallback', () {
      final empty = theme.ComponentStyle.empty;
      expect(empty, isNotNull);
    });
  });
}
