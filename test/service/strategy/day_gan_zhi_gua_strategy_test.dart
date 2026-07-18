import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';

import 'package:tiebanshenshu/service/strategy/day_gan_zhi_gua_strategy.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';

/// 日柱变卦取数法 Strategy 测试 — case_4 可信案例
///
/// 参考源：real_cases_intermediate.md case_4
/// 输入八字：癸巳 甲子 丁酉 癸卯
/// 日柱：丁酉
///
/// 可信断言：
/// - 丁→兑，酉→乾 → 卜卦乾兑（支上干下）
/// - 互卦：巽离
/// - 本卦上/下用后天数：乾=6，兑=7
/// - 互卦上/下用先天数：巽=5，離=3
/// - 基础数：6753
/// - 条文：6753 ± 96×1..4（含基础数）= 9 条
void main() {
  late DayGanZhiGuaStrategy strategy;
  late JiaZi dayGanZhi;

  setUp(() {
    strategy = DayGanZhiGuaStrategy();
    // 日柱：丁酉
    dayGanZhi = JiaZi.DING_YOU;
  });

  group('DayGanZhiGuaStrategy - 基础验证', () {
    test('Strategy基本信息', () {
      expect(strategy.name, equals('日柱变卦取数法'));
      expect(strategy.description, contains('日干为下卦'));
      expect(strategy.school, equals('日柱变卦流派'));
    });

    test('应该返回1个基础数结果', () {
      final params = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      expect(result.baseNumbers.length, equals(1));
      expect(result.baseNumbers[0], isA<BaseNumberModel>());
    });
  });

  group('DayGanZhiGuaStrategy - case_4 干支配卦验证', () {
    test('丁→兑（下卦），酉→乾（上卦）', () {
      final params = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);
      final result = strategy.calculate(params);

      expect(result.sourceData['dayGan'], equals('丁'));
      expect(result.sourceData['dayZhi'], equals('酉'));
      expect(result.sourceData['dayDownGua'], equals('兑'));
      expect(result.sourceData['dayUpGua'], equals('乾'));
    });

    test('sourceData 暴露基本卦和互卦名称', () {
      final params = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);
      final result = strategy.calculate(params);

      expect(result.sourceData['baseGua'], isNotNull);
      expect(result.sourceData['huGua'], isNotNull);
    });
  });

  group('DayGanZhiGuaStrategy - case_4 取数与基础数验证', () {
    test('取数规则：本卦上下用后天数，互卦上下用先天数', () {
      final params = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);
      final result = strategy.calculate(params);

      final calc = result.sourceData['calculation'] as Map<String, dynamic>;

      // 本卦上卦(乾)后天数 → 6
      expect(calc['firstUp'], equals(6),
          reason: '乾后天数 = 6');
      // 本卦下卦(兑)后天数 → 7
      expect(calc['firstDown'], equals(7),
          reason: '兑后天数 = 7');
      // 互卦上卦(巽)先天数 → 5
      expect(calc['secondUp'], equals(5),
          reason: '巽先天数 = 5');
      // 互卦下卦(離)先天数 → 3
      expect(calc['secondDown'], equals(3),
          reason: '離先天数 = 3');
    });

    test('基础数 = 6753', () {
      final params = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);
      final result = strategy.calculate(params);

      expect(result.sourceData['baseNumber'], equals(6753));
      expect(result.baseNumbers[0].baseNumber, equals(6753));
    });

    test('基础数模型描述包含日柱和基础数信息', () {
      final params = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);
      final result = strategy.calculate(params);

      expect(result.baseNumbers[0].name, equals('日柱变卦数'));
      expect(result.baseNumbers[0].description, contains('丁酉'));
      expect(result.baseNumbers[0].description, contains('6753'));
    });
  });

  group('DayGanZhiGuaStrategy - case_4 条文展开验证', () {
    test('默认配置生成 基础数6753 ± 96×1..4 = 9条条文', () {
      final params = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);

      final config = strategy.defaultTiaoWenCalculationConfig;
      final tiaoWenList = strategy.calculateTiaoWenListWithConfig(
        6753,
        params,
        config,
      );

      expect(tiaoWenList, equals([
        6369,
        6465,
        6561,
        6657,
        6753,
        6849,
        6945,
        7041,
        7137,
      ]));
    });
  });

  group('DayGanZhiGuaStrategy - 边界与幂等', () {
    test('相同日柱产生相同结果', () {
      final params1 = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);
      final params2 = DayGanZhiGuaStrategyParams(dayGanZhi: dayGanZhi);

      final result1 = strategy.calculate(params1);
      final result2 = strategy.calculate(params2);

      expect(result1.sourceData['baseNumber'],
          equals(result2.sourceData['baseNumber']));
    });

    test('不同日柱产生不同结果', () {
      final paramsDingYou = DayGanZhiGuaStrategyParams(
        dayGanZhi: JiaZi.DING_YOU,
      );
      final paramsJiaZi = DayGanZhiGuaStrategyParams(
        dayGanZhi: JiaZi.JIA_ZI,
      );

      final result1 = strategy.calculate(paramsDingYou);
      final result2 = strategy.calculate(paramsJiaZi);

      expect(result1.sourceData['baseNumber'],
          isNot(equals(result2.sourceData['baseNumber'])));
    });
  });
}
