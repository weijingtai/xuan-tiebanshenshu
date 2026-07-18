import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';

import 'package:tiebanshenshu/service/strategy/tai_xuan_four_zhu_strategy.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';
import 'package:tiebanshenshu/domain/models/tai_xuan_base_number_model.dart';

/// 太玄取数法Strategy测试
///
/// 测试数据：癸巳 甲子 丁酉 癸卯
/// - 年柱癸巳 -> 坤离
/// - 月柱甲子 -> 乾坎
/// - 日柱丁酉 -> 兑乾
/// - 时柱癸卯 -> 坤乾
///
/// 预期太玄数（根据年干阴阳纳甲）：
/// 年柱：4245
/// 月柱：4826
/// 日柱：2648
/// 时柱：4248
void main() {
  late TaiXuanFourZhuStrategy strategy;
  late EightChars testEightChars;

  setUp(() {
    strategy = TaiXuanFourZhuStrategy();

    // 构造测试八字：癸巳 甲子 丁酉 癸卯
    testEightChars = EightChars(
      year: JiaZi.GUI_SI, // 癸巳
      month: JiaZi.JIA_ZI, // 甲子
      day: JiaZi.DING_YOU, // 丁酉
      time: JiaZi.GUI_MAO, // 癸卯
    );
  });

  group('TaiXuanFourZhuStrategy - 基础验证', () {
    test('Strategy基本信息验证', () {
      expect(strategy.name, equals('太玄取数法（1）'));
      expect(strategy.description, contains('排四柱天干地支分别配卦'));
      expect(strategy.school, equals('太玄取数流派'));
    });

    test('应该返回4个基础数结果（四柱）', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      expect(result.baseNumbers.length, equals(4));
    });

    test('每个基础数应该是BaseNumberModel类型', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      for (final baseNumber in result.baseNumbers) {
        expect(baseNumber, isA<BaseNumberModel>());
      }
    });
  });

  group('TaiXuanFourZhuStrategy - 干支配卦验证', () {
    test('年柱癸巳应配为坤离卦', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      final yearModel = result.baseNumbers[0] as TaiXuanBaseNumberModel;
      expect(yearModel.upperGua, equals(Enum8Gua.Kun),
          reason: '癸 -> 坤（上卦）');
      expect(yearModel.lowerGua, equals(Enum8Gua.Li),
          reason: '巳 -> 离（下卦）');
    });

    test('月柱甲子应配为乾坎卦', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      final monthModel = result.baseNumbers[1] as TaiXuanBaseNumberModel;
      expect(monthModel.upperGua, equals(Enum8Gua.Qian),
          reason: '甲 -> 乾（上卦）');
      expect(monthModel.lowerGua, equals(Enum8Gua.Kan),
          reason: '子 -> 坎（下卦）');
    });

    test('日柱丁酉应配为兑乾卦', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      final dayModel = result.baseNumbers[2] as TaiXuanBaseNumberModel;
      expect(dayModel.upperGua, equals(Enum8Gua.Dui),
          reason: '丁 -> 兑（上卦）');
      expect(dayModel.lowerGua, equals(Enum8Gua.Qian),
          reason: '酉 -> 乾（下卦）');
    });

    test('时柱癸卯应配为坤乾卦', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      final timeModel = result.baseNumbers[3] as TaiXuanBaseNumberModel;
      expect(timeModel.upperGua, equals(Enum8Gua.Kun),
          reason: '癸 -> 坤（上卦）');
      expect(timeModel.lowerGua, equals(Enum8Gua.Qian),
          reason: '卯 -> 乾（下卦）');
    });
  });

  group('TaiXuanFourZhuStrategy - 纳甲/太玄中间过程验证', () {
    // ⚠️ real_cases_intermediate.md 的纳甲爻位顺序与当前实现相反。
    //    参考源：0-2（初二三）来自天干配卦（topGua），3-5（四五上）来自地支配卦（bottomGua）
    //    当前实现：0-2 来自 bottomGua，3-5 来自 topGua
    //    上下卦 sum 值和 baseNumber 一致，但 yaoDetails 中每爻的纳甲位置不同。
    //    本测试暂不锁定 yaoDetails 的爻位顺序，避免把可能错误的实现固化。
    //    只锁定不会误导的：yaoDetails 数量、sum 值、过滤数量、baseNumber。

    test('年柱坤离：sum值正确，baseNumber=4245', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final yearModel = result.baseNumbers[0] as TaiXuanBaseNumberModel;
      expect(yearModel.yaoDetails.length, equals(6));

      // 上下卦sum值：upperSum=42（坤卦三爻纳乙，14+12+16），lowerSum=45（离卦三爻纳己，15+17+13）
      expect(yearModel.lowerGuaSum, equals(45));
      expect(yearModel.upperGuaSum, equals(42));
      expect(yearModel.baseNumber, equals(4245));
      expect(yearModel.filteredYaos.length, equals(0));
    });

    test('月柱乾坎：有1个过滤爻(和=10)，sum值正确，baseNumber=4826', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final monthModel = result.baseNumbers[1] as TaiXuanBaseNumberModel;
      expect(monthModel.yaoDetails.length, equals(6));

      // 存在1个和=10的爻（戊辰，5+5=10），应被过滤
      expect(monthModel.filteredYaos.length, equals(1));
      expect(monthModel.activeYaos.length, equals(5));

      // 验证被过滤爻的数值 = 10
      final filteredYao = monthModel.filteredYaos.first;
      expect(filteredYao.taiXuanNumber, equals(10));
      expect(filteredYao.taiXuanGanNumber, equals(5));
      expect(filteredYao.taiXuanZhiNumber, equals(5));
      expect(filteredYao.isFiltered, isTrue);

      // 上下卦sum值
      expect(monthModel.lowerGuaSum, equals(26));
      expect(monthModel.upperGuaSum, equals(48));
      expect(monthModel.baseNumber, equals(4826));
    });

    test('日柱兑乾：有1个过滤爻(和=10)，sum值正确，baseNumber=2648', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final dayModel = result.baseNumbers[2] as TaiXuanBaseNumberModel;
      expect(dayModel.yaoDetails.length, equals(6));

      expect(dayModel.filteredYaos.length, equals(1));
      expect(dayModel.activeYaos.length, equals(5));

      final filteredYao = dayModel.filteredYaos.first;
      expect(filteredYao.taiXuanNumber, equals(10));
      expect(filteredYao.taiXuanGanNumber, equals(6));
      expect(filteredYao.taiXuanZhiNumber, equals(4));
      expect(filteredYao.isFiltered, isTrue);

      expect(dayModel.lowerGuaSum, equals(48));
      expect(dayModel.upperGuaSum, equals(26));
      expect(dayModel.baseNumber, equals(2648));
    });

    test('时柱坤乾：无过滤爻，sum值正确，baseNumber=4248', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final timeModel = result.baseNumbers[3] as TaiXuanBaseNumberModel;
      expect(timeModel.yaoDetails.length, equals(6));
      expect(timeModel.baseNumber, equals(4248));
      expect(timeModel.pillarName, equals('时柱'));

      expect(timeModel.filteredYaos.length, equals(0));
      expect(timeModel.activeYaos.length, equals(6));

      expect(timeModel.lowerGuaSum, equals(48));
      expect(timeModel.upperGuaSum, equals(42));
    });
  });

  group('TaiXuanFourZhuStrategy - 太玄数计算验证', () {
    test('年柱癸巳太玄数：4245', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final yearModel = result.baseNumbers[0];
      expect(yearModel.baseNumber, equals(4245));
      expect(yearModel.name, equals('年柱太玄数'));
      expect(yearModel.description, contains('癸巳'));
    });

    test('月柱甲子太玄数：4826', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final monthModel = result.baseNumbers[1];
      expect(monthModel.baseNumber, equals(4826));
      expect(monthModel.name, equals('月柱太玄数'));
      expect(monthModel.description, contains('甲子'));
    });

    test('日柱丁酉太玄数：2648', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final dayModel = result.baseNumbers[2];
      expect(dayModel.baseNumber, equals(2648));
      expect(dayModel.name, equals('日柱太玄数'));
      expect(dayModel.description, contains('丁酉'));
    });

    test('时柱癸卯太玄数：4248', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final timeModel = result.baseNumbers[3];
      expect(timeModel.baseNumber, equals(4248));
      expect(timeModel.name, equals('时柱太玄数'));
      expect(timeModel.description, contains('癸卯'));
    });
  });

  group('TaiXuanFourZhuStrategy - 完整结果验证', () {
    test('所有4个基础数应该符合预期值', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final baseNumbers = result.baseNumbers.map((m) => m.baseNumber).toList();

      expect(baseNumbers, equals([4245, 4826, 2648, 4248]));
    });

    test('结果应该按照年月日时顺序排列', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.baseNumbers[0].source, equals(BaseNumberSource.yearZhu));
      expect(result.baseNumbers[1].source, equals(BaseNumberSource.monthZhu));
      expect(result.baseNumbers[2].source, equals(BaseNumberSource.dayZhu));
      expect(result.baseNumbers[3].source, equals(BaseNumberSource.timeZhu));
    });

    test('sourceData应该包含完整的计算信息', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.sourceData['isYangYear'], isFalse); // 癸年是阴年
      expect(result.sourceData['baseNumbers'], isA<List>());
      expect((result.sourceData['baseNumbers'] as List).length, equals(4));
    });

    test('四柱基础数应展示，但32条文由每柱基础数分别±96四次得到', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final baseNumbers = result.baseNumbers;
      expect(baseNumbers.map((m) => m.baseNumber).toList(), [
        4245,
        4826,
        2648,
        4248,
      ]);

      final expanded = result.sourceData['expandedTiaoWenNumbers'];
      expect(expanded, isA<Map<String, List<int>>>());

      final expandedByPillar = expanded as Map<String, List<int>>;
      expect(expandedByPillar['年柱'], [
        4341,
        4437,
        4533,
        4629,
        4149,
        4053,
        3957,
        3861,
      ]);
      expect(expandedByPillar['月柱'], [
        4922,
        5018,
        5114,
        5210,
        4730,
        4634,
        4538,
        4442,
      ]);
      expect(expandedByPillar['日柱'], [
        2744,
        2840,
        2936,
        3032,
        2552,
        2456,
        2360,
        2264,
      ]);
      expect(expandedByPillar['时柱'], [
        4344,
        4440,
        4536,
        4632,
        4152,
        4056,
        3960,
        3864,
      ]);
      expect(
        expandedByPillar.values.fold<int>(
          0,
          (count, numbers) => count + numbers.length,
        ),
        equals(32),
        reason: '四组各8条，共32条；基础四数只展示，不计入32条文',
      );
      expect(
        result.sourceData['expandedTiaoWenExplanation'],
        contains('基础四数只展示'),
      );
    });

    test('四柱基础数本身不在expandedTiaoWenNumbers中', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final expanded = result.sourceData['expandedTiaoWenNumbers']
          as Map<String, List<int>>;

      final baseNumbersList = [
        4245,
        4826,
        2648,
        4248,
      ];

      for (final pillarName in ['年柱', '月柱', '日柱', '时柱']) {
        final pillarExpanded = expanded[pillarName]!;
        for (final baseNum in baseNumbersList) {
          expect(
            pillarExpanded.contains(baseNum), isFalse,
            reason: '$pillarName 基础数 $baseNum 不应出现在expandedTiaoWenNumbers中',
          );
        }
      }
    });
  });

  group('TaiXuanFourZhuStrategy - 边界情况测试', () {
    test('不同的八字应该产生不同的结果', () {
      final eightChars1 = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI,
        time: JiaZi.JIA_ZI,
      );

      final eightChars2 = EightChars(
        year: JiaZi.GUI_HAI,
        month: JiaZi.GUI_HAI,
        day: JiaZi.GUI_HAI,
        time: JiaZi.GUI_HAI,
      );

      final result1 = strategy.calculate(
        TaiXuanFourZhuStrategyParams(eightChars: eightChars1),
      );
      final result2 = strategy.calculate(
        TaiXuanFourZhuStrategyParams(eightChars: eightChars2),
      );

      expect(result1.hasError, isFalse);
      expect(result2.hasError, isFalse);

      final baseNumbers1 = result1.baseNumbers
          .map((m) => m.baseNumber)
          .toList();
      final baseNumbers2 = result2.baseNumbers
          .map((m) => m.baseNumber)
          .toList();

      expect(baseNumbers1, isNot(equals(baseNumbers2)));
    });

    test('相同的八字应该产生相同的结果', () {
      final params1 = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final params2 = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);

      final result1 = strategy.calculate(params1);
      final result2 = strategy.calculate(params2);

      expect(result1.hasError, isFalse);
      expect(result2.hasError, isFalse);

      final baseNumbers1 = result1.baseNumbers
          .map((m) => m.baseNumber)
          .toList();
      final baseNumbers2 = result2.baseNumbers
          .map((m) => m.baseNumber)
          .toList();

      expect(baseNumbers1, equals(baseNumbers2));
    });
  });

  group('TaiXuanFourZhuStrategy - 年干阴阳影响测试', () {
    test('阳年和阴年应该产生不同的纳甲结果', () {
      // 阳年：甲子
      final yangYearEightChars = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI,
        time: JiaZi.JIA_ZI,
      );

      // 阴年：癸亥
      final yinYearEightChars = EightChars(
        year: JiaZi.GUI_HAI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI,
        time: JiaZi.JIA_ZI,
      );

      final yangResult = strategy.calculate(
        TaiXuanFourZhuStrategyParams(eightChars: yangYearEightChars),
      );
      final yinResult = strategy.calculate(
        TaiXuanFourZhuStrategyParams(eightChars: yinYearEightChars),
      );

      expect(yangResult.hasError, isFalse);
      expect(yinResult.hasError, isFalse);

      // 年柱应该不同（因为年干不同）
      expect(
        yangResult.baseNumbers[0].baseNumber,
        isNot(equals(yinResult.baseNumbers[0].baseNumber)),
      );

      // 验证年干阴阳标记正确
      expect(yangResult.sourceData['isYangYear'], isTrue);
      expect(yinResult.sourceData['isYangYear'], isFalse);
    });
  });
}
