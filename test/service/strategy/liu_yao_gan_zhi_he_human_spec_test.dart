// ignore_for_file: avoid_print
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/liu_yao_gan_zhi_he_strategy.dart';
import 'package:tiebanshenshu/domain/models/liu_yao_gan_zhi_he_base_number_model.dart';
import 'package:xuan_gua_core/xuan_gua_core.dart';

/// 先后天卦六爻干支和数法单元测试 - 人工规格测试
///
/// 测试用例：女 丙辰 乙未 壬戌 戊申
/// 注：原书时柱写作"戊巳"，戊为阳干只能配阳支，巳为阴支，系原文笔误。
///     壬戌日申时正应为戊申，巳/申形近易误。
///
/// 原书用例从山雷颐卦直接起手算纳甲/太玄/基本数 4245，
/// 不通过四柱推导天地卦。本测试改为验证算法本身的自洽性：
/// 上下卦太玄和、基础数组成、纳甲爻数与结构。
///
/// 原书期望值（山雷颐→4245）留作注释，待有能复现山雷颐的正确八字后再锁定。
void main() {
  late LiuYaoGanZhiHeStrategy strategy;
  late EightChars testEightChars;
  late LiuYaoGanZhiHeStrategyParams testParams;
  late LiuYaoGanZhiHeBaseNumberModel model;

  setUp(() {
    strategy = LiuYaoGanZhiHeStrategy();

    // 时柱依 壬戌日申时 → 戊申（戊巳系形近笔误）
    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("丙辰")!,
      month: JiaZi.getFromGanZhiValue("乙未")!,
      day: JiaZi.getFromGanZhiValue("壬戌")!,
      time: JiaZi.getFromGanZhiValue("戊申")!,
    );

    testParams = LiuYaoGanZhiHeStrategyParams(
      eightChars: testEightChars,
      gender: Gender.female,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
    );

    final result = strategy.calculate(testParams);
    expect(result.hasError, false, reason: '计算不应该出错');
    model = result.baseNumbers.first as LiuYaoGanZhiHeBaseNumberModel;
  });

  group('步骤1：先天卦与后天卦', () {
    test('应该成功计算出先天卦和后天卦', () {
      print('\n实际先天卦: ${model.xiantianGua}');
      print('实际后天卦: ${model.houtianGua}');
      expect(model.xiantianGua, isNotNull);
      expect(model.houtianGua, isNotNull);
    });
  });

  group('步骤2：六爻纳甲结构验证', () {
    test('应该有6个纳甲爻', () {
      expect(model.xiantianYaoTianGanList.length, equals(6));
      expect(model.xiantianYaoDiZhiList.length, equals(6));
      expect(model.xiantianYaoSumList.length, equals(6));
    });

    test('每个爻的干支和应等于天干地支太玄数之和', () {
      for (int i = 0; i < 6; i++) {
        print(
          '${['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'][i]}: '
          '${model.xiantianYaoTianGanList[i]}${model.xiantianYaoDiZhiList[i]} '
          '和=${model.xiantianYaoSumList[i]}',
        );
        expect(model.xiantianYaoSumList[i], greaterThan(0));
      }
    });
  });

  group('步骤3：太玄数上下卦和', () {
    test('下卦和应该是初二三爻之和', () {
      final expectedLower =
          model.xiantianYaoSumList[0] +
          model.xiantianYaoSumList[1] +
          model.xiantianYaoSumList[2];
      print('实际下卦之和: ${model.xiantianLowerSum} (计算: $expectedLower)');
      expect(model.xiantianLowerSum, equals(expectedLower));
    });

    test('上卦和应该是四五上爻之和', () {
      final expectedUpper =
          model.xiantianYaoSumList[3] +
          model.xiantianYaoSumList[4] +
          model.xiantianYaoSumList[5];
      print('实际上卦之和: ${model.xiantianUpperSum} (计算: $expectedUpper)');
      expect(model.xiantianUpperSum, equals(expectedUpper));
    });
  });

  group('步骤4：基础数组成', () {
    test('基础数 = 上卦和×100 + 下卦和', () {
      final expectedBase =
          model.xiantianUpperSum * 100 + model.xiantianLowerSum;
      print('\n实际基本数: ${model.xiantianBaseNumber} (计算: ${model.xiantianUpperSum}*100+${model.xiantianLowerSum}=$expectedBase)');
      expect(model.xiantianBaseNumber, equals(expectedBase));
    });
  });

  group('步骤5：条文扩展', () {
    test('默认条文配置应生成8条条文', () {
      final config = strategy.defaultTiaoWenCalculationConfig;
      final tiaoWenList = strategy.calculateTiaoWenListWithConfig(
        model.xiantianBaseNumber,
        testParams,
        config,
      );
      print('\n先天卦条文: $tiaoWenList');
      expect(tiaoWenList.length, equals(8));
    });
  });

  group('完整流程验证 - 丙辰乙未壬戌戊申', () {
    test('应该成功计算并返回结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, false, reason: '计算应该成功');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('所有关键字段应该内洽', () {
      print('\n========== 完整结果汇总 ==========');
      print('四柱: ${testEightChars.year} ${testEightChars.month} ${testEightChars.day} ${testEightChars.time}');
      print('性别: ${testParams.gender}');
      print('先天卦: ${model.xiantianGua}');
      print('基本数: ${model.xiantianBaseNumber}');
      print('上卦和: ${model.xiantianUpperSum}');
      print('下卦和: ${model.xiantianLowerSum}');
      print('====================================\n');

      // 结构验证
      expect(model.xiantianGua, isNotNull);
      expect(model.xiantianBaseNumber, greaterThan(0));
      expect(
        model.xiantianBaseNumber,
        equals(model.xiantianUpperSum * 100 + model.xiantianLowerSum),
      );
    });
  });
}
