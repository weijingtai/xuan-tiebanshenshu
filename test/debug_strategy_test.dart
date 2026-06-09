import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/enums.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_calculator.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info_ext.dart';
import 'package:tiebanshenshu/utils/tiao_wen_calculator.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';

void main() {
  test('debug yuan tang strategy', () {
    final testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("己酉")!,
      month: JiaZi.getFromGanZhiValue("丙子")!,
      day: JiaZi.getFromGanZhiValue("辛巳")!,
      time: JiaZi.getFromGanZhiValue("戊子")!,
    );
    
    final calculator = YuanTangCalculator();
    
    // Step 1
    final yuanTangInfo = calculator.calculate(
      eightChars: testEightChars,
      yearYinYang: testEightChars.yearTianGan.yinYang,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthJieQi: TwentyFourJieQi.XIA_ZHI,
      monthType: YuanTangMonthType.monthYinYan,
      calanderType: CalanderType.solar,
      birthMonth: 8,
    );
    print('Step 1 OK: ${yuanTangInfo.xianTanGua.gua.name}');
    
    // Step 2
    final (tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal, tianGuaNum, diGuaNum, usedThreeYuanWuGong) = 
      YuanTangCalculator.generateTianDiGua(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
      );
    print('Step 2 OK: tianGua=${tianGua.name}');
    
    // Step 3
    final tianDiGuaData = TianDiGuaData(
      ganNumList: ganNumList,
      zhiNumList: zhiNumList,
      oddNumTotal: oddNumTotal,
      evenNumTotal: evenNumTotal,
      tianGuaNum: tianGuaNum,
      diGuaNum: diGuaNum,
      tianGua: tianGua,
      diGua: diGua,
      usedThreeYuanWuGong: usedThreeYuanWuGong,
    );
    print('Step 3 OK');
    
    // Step 4
    final jiazeXiantian = TiaowenCalculator.getTiaowenNumberByJiaZe(yuanTangInfo.xianTanGua.gua);
    print('Step 4 OK: jiazeXiantian=$jiazeXiantian');
    
    // Step 5
    final tiaowenNumbers = TiaowenNumbers(
      jiazeXiantian: jiazeXiantian,
      jiazeHoutian: TiaowenCalculator.getTiaowenNumberByJiaZe(yuanTangInfo.houTianGua.gua),
      najiaTaixuanXiantian: TiaowenCalculator.getTiaowenNumberByTaixuan(yuanTangInfo.xianTanGua.gua),
      najiaTaixuanHoutian: TiaowenCalculator.getTiaowenNumberByTaixuan(yuanTangInfo.houTianGua.gua),
      benhuXiantian: 0,
      benhuHoutian: 0,
      guahuListXiantian: [],
      guahuListHoutian: [],
    );
    print('Step 5 OK');
    
    // Step 6 - toBaseNumberModel
    try {
      final model = yuanTangInfo.toBaseNumberModel(
        tianDiGuaData: tianDiGuaData,
        tiaowenNumbers: tiaowenNumbers,
        baseNumber: jiazeXiantian,
        name: "test",
        description: "test",
        source: BaseNumberSource.combined,
      );
      print('Step 6 OK: ${model.name}');
    } catch (e, stackTrace) {
      print('Step 6 FAILED: $e');
      print('Stack trace (first 50 lines):');
      final lines = stackTrace.toString().split('\n');
      for (var i = 0; i < lines.length && i < 50; i++) {
        print(lines[i]);
      }
    }
  });
}
