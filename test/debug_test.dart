import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/enums.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';

void main() {
  test('debug yuan tang strategy', () {
    final strategy = YuanTangStrategy();
    
    final testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("己酉")!,
      month: JiaZi.getFromGanZhiValue("丙子")!,
      day: JiaZi.getFromGanZhiValue("辛巳")!,
      time: JiaZi.getFromGanZhiValue("戊子")!,
    );
    
    final testParams = YuanTangStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      birthMonth: 8,
    );
    
    try {
      final result = strategy.calculate(testParams);
      print('Result: ${result.toString()}');
      print('Has error: ${result.hasError}');
      print('Error message: ${result.errorMessage}');
      print('Base numbers length: ${result.baseNumbers.length}');
    } catch (e, stackTrace) {
      print('Exception: $e');
      print('Stack trace (first 100 lines):');
      final lines = stackTrace.toString().split('\n');
      for (var i = 0; i < lines.length && i < 100; i++) {
        print(lines[i]);
      }
    }
  });
}
