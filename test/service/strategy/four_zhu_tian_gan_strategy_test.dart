import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';

import 'package:tiebanshenshu/service/strategy/four_zhu_tian_gan_strategy.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';

/// 四柱天干取数法 Strategy 测试 — case_3 可信案例
///
/// 参考源：real_cases_intermediate.md case_3
/// 测试数据：癸巳 甲子 丁酉 癸卯
///
/// 天干配数规则（甲1 乙6 丙2 丁7 戊3 己8 庚4 辛9 壬5 癸0）：
/// - 月甲 = 1
/// - 日丁 = 7
/// - 时癸 = 0
/// - 年癸 = 0
/// - 排列顺序：月日时年 → 基础数 1700
/// - 条文：1700 + 96×n, n ∈ [0..7]
void main() {
  late FourZhuTianGanStrategy strategy;
  late EightChars testEightChars;

  setUp(() {
    strategy = FourZhuTianGanStrategy();

    // 癸巳 甲子 丁酉 癸卯
    testEightChars = EightChars(
      year: JiaZi.GUI_SI,
      month: JiaZi.JIA_ZI,
      day: JiaZi.DING_YOU,
      time: JiaZi.GUI_MAO,
    );
  });

  group('FourZhuTianGanStrategy - 基础验证', () {
    test('Strategy基本信息', () {
      expect(strategy.name, equals('四柱天干取数法'));
      expect(strategy.description, contains('排四柱只取天干'));
      expect(strategy.school, equals('四柱天干流派'));
    });

    test('应该返回1个基础数结果', () {
      final params = FourZhuTianGanStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      expect(result.baseNumbers.length, equals(1));
      expect(result.baseNumbers[0], isA<BaseNumberModel>());
    });
  });

  group('FourZhuTianGanStrategy - case_3 天干配数验证', () {
    test('癸巳 甲子 丁酉 癸卯 → 月1 日7 时0 年0', () {
      final params = FourZhuTianGanStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final eightCharsData =
          result.sourceData['eightChars'] as Map<String, dynamic>;

      // 月柱天干 = 甲 → 1
      expect(
        (eightCharsData['month'] as Map)['gan'],
        equals('甲'),
      );
      expect((eightCharsData['month'] as Map)['number'], equals(1));

      // 日柱天干 = 丁 → 7
      expect(
        (eightCharsData['day'] as Map)['gan'],
        equals('丁'),
      );
      expect((eightCharsData['day'] as Map)['number'], equals(7));

      // 时柱天干 = 癸 → 0
      expect(
        (eightCharsData['time'] as Map)['gan'],
        equals('癸'),
      );
      expect((eightCharsData['time'] as Map)['number'], equals(0));

      // 年柱天干 = 癸 → 0
      expect(
        (eightCharsData['year'] as Map)['gan'],
        equals('癸'),
      );
      expect((eightCharsData['year'] as Map)['number'], equals(0));
    });
  });

  group('FourZhuTianGanStrategy - case_3 基础数验证', () {
    test('排列顺序为月日时年 → 基础数 = 1700', () {
      final params = FourZhuTianGanStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(
        result.sourceData['calculation'],
        contains('month(1)'),
      );
      expect(
        result.sourceData['calculation'],
        contains('day(7)'),
      );
      expect(
        result.sourceData['calculation'],
        contains('time(0)'),
      );
      expect(
        result.sourceData['calculation'],
        contains('year(0)'),
      );
      expect(result.sourceData['calculation'],
          equals('month(1) * 1000 + day(7) * 100 + time(0) * 10 + year(0)'));

      expect(result.baseNumbers[0].baseNumber, equals(1700));
      expect(result.sourceData['baseNumber'], equals(1700));
    });

    test('基础数模型描述包含干支信息', () {
      final params = FourZhuTianGanStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.baseNumbers[0].name, equals('四柱天干组合数'));
      expect(result.baseNumbers[0].description, contains('甲'));
      expect(result.baseNumbers[0].description, contains('丁'));
      expect(result.baseNumbers[0].description, contains('癸'));
      expect(result.baseNumbers[0].description, contains('1700'));
    });
  });

  group('FourZhuTianGanStrategy - case_3 条文数验证', () {
    test('defaultTiaoWenCalculationConfig 生成8个条文', () {
      final config = strategy.defaultTiaoWenCalculationConfig;
      expect(config.name, contains('四柱天干'));
      // 配置含 0 + 7个递增值 = 8 条
      expect(config.calculateTiaoWenList(1700, {}).length, equals(8));
    });

    test('基础数1700 + 96×0..7 = 8个条文', () {
      final params = FourZhuTianGanStrategyParams(eightChars: testEightChars);
      final config = strategy.defaultTiaoWenCalculationConfig;

      final tiaoWenList = strategy.calculateTiaoWenListWithConfig(
        1700,
        params,
        config,
      );

      expect(tiaoWenList, equals([
        1700, // +0
        1796, // +96
        1892, // +192
        1988, // +288
        2084, // +384
        2180, // +480
        2276, // +576
        2372, // +672
      ]));
    });
  });

  group('FourZhuTianGanStrategy - 不同八字验证', () {
    test('相同的八字应该产生相同结果', () {
      final params1 = FourZhuTianGanStrategyParams(
        eightChars: testEightChars,
      );
      final params2 = FourZhuTianGanStrategyParams(
        eightChars: testEightChars,
      );

      final result1 = strategy.calculate(params1);
      final result2 = strategy.calculate(params2);

      expect(result1.baseNumbers[0].baseNumber,
          equals(result2.baseNumbers[0].baseNumber));
    });

    test('不同的天干组合应该产生不同的基础数', () {
      // 甲子 甲子 甲子 甲子 → 1111
      final allJia = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI,
        time: JiaZi.JIA_ZI,
      );
      final result = strategy.calculate(
        FourZhuTianGanStrategyParams(eightChars: allJia),
      );

      expect(result.baseNumbers[0].baseNumber, equals(1111));
    });

    test('排列顺序确认：月日时年不同于年月日时', () {
      // 如果按年月日时排列，癸巳甲子丁酉癸卯 → 年0 月1 日7 时0 = 0170 ≠ 1700
      // 当前策略按月日时年排列 → 1700
      final params = FourZhuTianGanStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.baseNumbers[0].baseNumber, equals(1700));
      // 确认不是按年月日时排列（那样会是 0170 即 170）
      expect(result.baseNumbers[0].baseNumber, isNot(equals(170)));
    });
  });
}
