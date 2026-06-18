/// 邵子神数 — 河洛天地数法 Phase 1 单元测试
///
/// 测试范围：
/// - 天干→邵子数 / 地支→河图数 基础映射
/// - 八字的12个数生成
/// - 天数/地数计算（含边界值 0→25/30）
/// - 本命基数 / 条文编号
/// - 加一倍法展开
/// - 完整流程端到端验证
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:tiebanshenshu/shaozishu/constants/shao_zi_shu_constants.dart';
import 'package:tiebanshenshu/shaozishu/helper/shao_zi_shu_calculation_helper.dart';

void main() {
  // ===========================================================================
  // 测试组 1：基础映射函数
  // ===========================================================================
  group('基础映射函数', () {
    test('天干→邵子数映射正确性', () {
      // 口诀：戊一乙癸二，庚三辛四同，壬甲从六数，丁七丙八宫，己九无差别
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.WU),
        1,
        reason: '戊=1',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.YI),
        2,
        reason: '乙=2',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.GUI),
        2,
        reason: '癸=2',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.GENG),
        3,
        reason: '庚=3',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.XIN),
        4,
        reason: '辛=4',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.REN),
        6,
        reason: '壬=6',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.JIA),
        6,
        reason: '甲=6',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.DING),
        7,
        reason: '丁=7',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.BING),
        8,
        reason: '丙=8',
      );
      expect(
        ShaoZiShuCalculationHelper.ganToShaoZiNumber(TianGan.JI),
        9,
        reason: '己=9',
      );
    });

    test('天干→邵子数 — 全部10天干均有映射', () {
      for (final gan in tenTianGanList) {
        final value = ShaoZiShuCalculationHelper.ganToShaoZiNumber(gan);
        expect(value, greaterThan(0), reason: '${gan.value}应有非零数值');
      }
    });

    test('地支→河图数映射正确性', () {
      // 口诀：亥子一六水，寅卯三八木，巳午二七火，申酉四九金，辰戌丑未五十土
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.ZI),
        [1, 6],
        reason: '子=1,6',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.HAI),
        [1, 6],
        reason: '亥=1,6',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.YIN),
        [3, 8],
        reason: '寅=3,8',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.MAO),
        [3, 8],
        reason: '卯=3,8',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.SI),
        [2, 7],
        reason: '巳=2,7',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.WU),
        [2, 7],
        reason: '午=2,7',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.SHEN),
        [4, 9],
        reason: '申=4,9',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.YOU),
        [4, 9],
        reason: '酉=4,9',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.CHEN),
        [5, 10],
        reason: '辰=5,10',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.XU),
        [5, 10],
        reason: '戌=5,10',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.CHOU),
        [5, 10],
        reason: '丑=5,10',
      );
      expect(
        ShaoZiShuCalculationHelper.zhiToHeTuNumbers(DiZhi.WEI),
        [5, 10],
        reason: '未=5,10',
      );
    });
  });

  // ===========================================================================
  // 测试组 2：12 个数生成
  // ===========================================================================
  group('12个数生成', () {
    test('标准八字生成 12 个数', () {
      // 构造八字：甲子年 乙丑月 丙寅日 丁卯时
      // 天干邵子数：甲=6, 乙=2, 丙=8, 丁=7
      // 地支河图数：子[1,6], 丑[5,10], 寅[3,8], 卯[3,8]
      final eightChars = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.YI_CHOU,
        day: JiaZi.BING_YIN,
        time: JiaZi.DING_MAO,
      );

      final twelveNumbers =
          ShaoZiShuCalculationHelper.calculateTwelveNumbers(eightChars);

      expect(twelveNumbers.length, 12, reason: '必须生成恰好 12 个数');
      expect(
        twelveNumbers,
        [6, 2, 8, 7, 1, 6, 5, 10, 3, 8, 3, 8],
        reason: '甲6乙2丙8丁7 → 子1/6 丑5/10 寅3/8 卯3/8',
      );
    });

    test('八字生成数量恒定为 12', () {
      // 测试多种八字确保始终 12 个数
      final testCases = [
        EightChars(
          year: JiaZi.JIA_ZI,
          month: JiaZi.JIA_ZI,
          day: JiaZi.JIA_ZI,
          time: JiaZi.JIA_ZI,
        ), // 全甲子
        EightChars(
          year: JiaZi.GUI_HAI,
          month: JiaZi.REN_XU,
          day: JiaZi.XIN_YOU,
          time: JiaZi.GENG_SHEN,
        ),
        EightChars(
          year: JiaZi.JI_WEI,
          month: JiaZi.WU_WU,
          day: JiaZi.DING_SI,
          time: JiaZi.BING_CHEN,
        ),
      ];

      for (final baZi in testCases) {
        final numbers = ShaoZiShuCalculationHelper.calculateTwelveNumbers(baZi);
        expect(numbers.length, 12, reason: '$baZi 应生成12个数');
      }
    });
  });

  // ===========================================================================
  // 测试组 3：天数/地数计算
  // ===========================================================================
  group('天数/地数计算', () {
    test('标准计算 — 天数余数正确', () {
      // 12个数：[6,2,8,7,1,6,5,10,3,8,3,8]
      // 奇数：7+1+5+3+3 = 19
      // 偶数：6+2+8+6+10+8+8 = 48
      // 天数 = 19 % 25 = 19
      final numbers = [6, 2, 8, 7, 1, 6, 5, 10, 3, 8, 3, 8];
      expect(ShaoZiShuCalculationHelper.calculateTianShu(numbers), 19);
    });

    test('标准计算 — 地数余数正确', () {
      // 偶数：6+2+8+6+10+8+8 = 48
      // 地数 = 48 % 30 = 18
      final numbers = [6, 2, 8, 7, 1, 6, 5, 10, 3, 8, 3, 8];
      expect(ShaoZiShuCalculationHelper.calculateDiShu(numbers), 18);
    });

    test('边界：天数余 0 时返回 25', () {
      // 构造恰好能被 25 整除的奇数组合
      // [25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] → 奇数:25, 25%25=0 → 25
      final numbers = [25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      expect(
        ShaoZiShuCalculationHelper.calculateTianShu(numbers),
        25,
        reason: '余0 → 应返回天数基准值 25',
      );

      // 50 % 25 = 0
      final numbers2 = [50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      expect(ShaoZiShuCalculationHelper.calculateTianShu(numbers2), 25);
    });

    test('边界：地数余 0 时返回 30', () {
      // 构造恰好能被 30 整除的偶数组合
      final numbers = [30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      expect(
        ShaoZiShuCalculationHelper.calculateDiShu(numbers),
        30,
        reason: '余0 → 应返回地数基准值 30',
      );

      // 60 % 30 = 0
      final numbers2 = [60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      expect(ShaoZiShuCalculationHelper.calculateDiShu(numbers2), 30);
    });

    test('原始和（未取模）计算正确', () {
      final numbers = [6, 2, 8, 7, 1, 6, 5, 10, 3, 8, 3, 8];
      expect(ShaoZiShuCalculationHelper.calculateTianShuSum(numbers), 19);
      expect(ShaoZiShuCalculationHelper.calculateDiShuSum(numbers), 48);
    });
  });

  // ===========================================================================
  // 测试组 4：本命基数计算
  // ===========================================================================
  group('本命基数计算', () {
    test('常规值：天数×8 + 地数', () {
      // 天数=19, 地数=18 → 19×8+18 = 170
      expect(ShaoZiShuCalculationHelper.calculateBenMingJiShu(19, 18), 170);
    });

    test('边界：天数=25, 地数=30', () {
      // 25 × 8 + 30 = 230
      expect(ShaoZiShuCalculationHelper.calculateBenMingJiShu(25, 30), 230);
    });

    test('边界：天数=1, 地数=1', () {
      // 1 × 8 + 1 = 9
      expect(ShaoZiShuCalculationHelper.calculateBenMingJiShu(1, 1), 9);
    });

    test('极值：天数=25, 地数=30', () {
      // 天数最大 25，地数最大 30 → 25×8+30 = 230
      expect(ShaoZiShuCalculationHelper.calculateBenMingJiShu(25, 30), 230);
    });
  });

  // ===========================================================================
  // 测试组 5：条文编号计算
  // ===========================================================================
  group('条文编号计算', () {
    test('常规值映射', () {
      // 本命基数=230 → 230×24 % 6144 = 5520
      expect(
        ShaoZiShuCalculationHelper.calculateTiaoWenNumber(230),
        5520,
      );
    });

    test('边界：结果为 0 时返回 6144', () {
      // n×24 是 6144 的倍数 → 6144 / 24 = 256
      // n=256: 256×24=6144, 6144%6144=0 → 6144
      expect(
        ShaoZiShuCalculationHelper.calculateTiaoWenNumber(256),
        6144,
        reason: '256×24=6144 → %6144=0 → 应返回6144',
      );

      // n=512: 512×24=12288, 12288%6144=0 → 6144
      expect(
        ShaoZiShuCalculationHelper.calculateTiaoWenNumber(512),
        6144,
      );
    });

    test('条文编号始终在 1~6144 范围内', () {
      for (int base = 0; base < 5000; base += 13) {
        final number =
            ShaoZiShuCalculationHelper.calculateTiaoWenNumber(base);
        expect(number, greaterThanOrEqualTo(1));
        expect(number, lessThanOrEqualTo(6144));
      }
    });
  });

  // ===========================================================================
  // 测试组 6：加一倍法展开
  // ===========================================================================
  group('加一倍法展开', () {
    test('基础数=100 → 展开为 9 个数', () {
      final expanded =
          ShaoZiShuCalculationHelper.expandByJiaYiBei(100);
      expect(expanded.length, 9);
      // 100, 100+96=196, 100-96=4, 100+192=292, 100-192(<0→+6144)=6052,
      // 100+384=484, 100-384(<0→+6144)=5860, 100+768=868, 100-768(<0→+6144)=5476
      expect(expanded, contains(100));
      expect(expanded, contains(196));
      expect(expanded, contains(4));
      expect(expanded, contains(292));
      expect(expanded, contains(6052));
      expect(expanded, contains(484));
      expect(expanded, contains(5860));
      expect(expanded, contains(868));
      expect(expanded, contains(5476));
    });

    test('展开结果均在 1~6144 范围内', () {
      for (int base = 1; base <= 6144; base += 337) {
        final expanded =
            ShaoZiShuCalculationHelper.expandByJiaYiBei(base);
        for (final num in expanded) {
          expect(num, greaterThanOrEqualTo(1),
              reason: 'base=$base → $num 应在有效范围');
          expect(num, lessThanOrEqualTo(6144));
        }
      }
    });

    test('基础数=1 时边界展开', () {
      final expanded = ShaoZiShuCalculationHelper.expandByJiaYiBei(1);
      // 1-96 = -95 + 6144 = 6049
      expect(expanded, contains(6049));
    });

    test('基础数=6144 时边界展开', () {
      final expanded = ShaoZiShuCalculationHelper.expandByJiaYiBei(6144);
      // 6144+96 = 6240 - 6144 = 96
      expect(expanded, contains(96));
    });
  });

  // ===========================================================================
  // 测试组 7：端到端完整流程
  // ===========================================================================
  group('端到端完整流程', () {
    test('标准八字 → 完整结果', () {
      // 戊子年 癸丑月 甲午日 乙卯时
      // 干:戊=1,癸=2,甲=6,乙=2 → 支:子[1,6],丑[5,10],午[2,7],卯[3,8]
      final eightChars = EightChars(
        year: JiaZi.WU_ZI,
        month: JiaZi.GUI_CHOU,
        day: JiaZi.JIA_WU,
        time: JiaZi.YI_MAO,
      );

      final result = ShaoZiShuCalculationHelper.calculate(eightChars);

      // 12 个数：[1, 2, 6, 2, 1, 6, 5, 10, 2, 7, 3, 8]
      expect(result.twelveNumbers, [1, 2, 6, 2, 1, 6, 5, 10, 2, 7, 3, 8]);

      // 天数：奇数 1+1+5+7+3 = 17；17%25=17
      // 地数：偶数 2+6+2+6+10+2+8 = 36；36%30=6
      expect(result.tianShuSum, 17);
      expect(result.diShuSum, 36);
      expect(result.tianShu, 17);
      expect(result.diShu, 6);

      // 本命基数：17×8+6 = 142
      expect(result.benMingJiShu, 142);

      // 条文编号：142×24=3408, 3408%6144=3408
      expect(result.tiaoWenNumber, 3408);

      // 计算过程字符串非空
      expect(result.calculationDetail, isNotEmpty);
    });

    test('全甲子八字 → 结果', () {
      // 甲子 甲子 甲子 甲子 → 干:6,6,6,6 → 支:[1,6]×4
      final eightChars = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI,
        time: JiaZi.JIA_ZI,
      );

      final result = ShaoZiShuCalculationHelper.calculate(eightChars);

      // 12个数: [6,6,6,6, 1,6,1,6,1,6,1,6]
      expect(result.twelveNumbers, [6, 6, 6, 6, 1, 6, 1, 6, 1, 6, 1, 6]);

      // 奇数: 1+1+1+1 = 4；4%25=4
      // 偶数: 6+6+6+6+6+6+6+6 = 48；48%30=18
      expect(result.tianShu, 4);
      expect(result.diShu, 18);

      // 本命基数: 4×8+18 = 50
      expect(result.benMingJiShu, 50);

      // 条文: 50×24=1200, 1200%6144=1200
      expect(result.tiaoWenNumber, 1200);
    });

    test('ShaoZiShuResult toString 可读', () {
      final result = ShaoZiShuResult(
        twelveNumbers: [],
        tianShuSum: 10,
        diShuSum: 20,
        tianShu: 10,
        diShu: 20,
        benMingJiShu: 100,
        tiaoWenNumber: 2400,
        expandedTiaoWenNumbers: [],
        calculationDetail: '',
      );
      expect(result.toString(), isNotEmpty);
      expect(result.toString(), contains('ShaoZiShuResult'));
    });
  });
}
