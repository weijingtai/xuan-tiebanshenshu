import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:tiebanshenshu/domain/pipeline/tieban_chart_calculator.dart';
import 'package:tiebanshenshu/domain/pipeline/tieban_chart_params.dart';

final _moment = ResolvedMoment(
  source: DivinationMoment(
    instantUtc: DateTime.utc(1990, 6, 21, 4),
    place: const GeoPoint(latitude: 31.2304, longitude: 121.4737),
    reckoning: EnumDatetimeType.standard,
  ),
  nominalTime: DateTime(1990, 6, 21, 12),
  eightChars: EightChars(
    year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI,
    day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI,
  ),
  lunar: const LunarDate(month: 5, day: 1, isLeapMonth: false),
  jieQi: JieQiInfo(
    jieQi: TwentyFourJieQi.XIA_ZHI,
    startAt: DateTime(1990, 6, 21),
    endAt: DateTime(1990, 7, 7),
  ),
);

final _params = const TiebanChartParams(
  latitude: 31.2304,
  longitude: 121.4737,
  altitude: 0,
  timezone: 'Asia/Shanghai',
  isMale: true,
);

final _calculator = const TiebanChartCalculator();

void main() {
  group('TiebanChartCalculator', () {
    test('module 返回 tiebanshenshu', () {
      expect(_calculator.module, equals('tiebanshenshu'));
    });

    test('是纯函数 — 相同输入两次产出相等', () {
      final a = _calculator.calculate(_moment, _params);
      final b = _calculator.calculate(_moment, _params);
      expect(a, equals(b));
    });

    test('Contract 的 uuid 为空字符串（管线阶段暂留）', () {
      final contract = _calculator.calculate(_moment, _params);
      expect(contract.uuid, isEmpty);
    });

    test('Contract 的 question 为默认占位', () {
      final contract = _calculator.calculate(_moment, _params);
      expect(contract.question, equals('铁板神数排盘'));
    });

    test('Contract 的 createdAt 等于 moment.nominalTime', () {
      final contract = _calculator.calculate(_moment, _params);
      expect(contract.createdAt, equals(_moment.nominalTime));
    });

    test('calculationResultJson 可解码且包含预期键', () {
      final contract = _calculator.calculate(_moment, _params);
      expect(contract.calculationResultJson, isNotNull);
      final result = jsonDecode(contract.calculationResultJson!) as Map<String, dynamic>;
      expect(result.containsKey('xiantianGua'), isTrue);
      expect(result.containsKey('houTianGua'), isTrue);
      expect(result.containsKey('yuanTangYaoIndex'), isTrue);
      expect(result.containsKey('yaoList'), isTrue);
      expect(result['yaoList'], isA<List>());
    });

    test('paramsJson 包含 isMale 与地理参数', () {
      final contract = _calculator.calculate(_moment, _params);
      expect(contract.paramsJson, isNotNull);
      final payload = jsonDecode(contract.paramsJson!) as Map<String, dynamic>;
      expect(payload['isMale'], isTrue);
      expect(payload['latitude'], equals(31.2304));
      expect(payload['longitude'], equals(121.4737));
      expect(payload['altitude'], equals(0));
      expect(payload['timezone'], equals('Asia/Shanghai'));
      expect(payload.containsKey('eightChars'), isTrue);
      expect(payload.containsKey('gender'), isTrue);
    });

    test('未填字段保持为 null', () {
      final contract = _calculator.calculate(_moment, _params);
      expect(contract.birthDatetimeJson, isNull);
      expect(contract.birthGanZhiJson, isNull);
      expect(contract.matchedTiaoWenIdsJson, isNull);
      expect(contract.updatedAt, isNull);
      expect(contract.deletedAt, isNull);
    });

    test('不同 isMale 参数产出不同 calculationResult', () {
      final maleParams = const TiebanChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 0,
        timezone: 'Asia/Shanghai',
        isMale: true,
      );
      final femaleParams = const TiebanChartParams(
        latitude: 31.2304,
        longitude: 121.4737,
        altitude: 0,
        timezone: 'Asia/Shanghai',
        isMale: false,
      );
      final maleResult = jsonDecode(_calculator.calculate(_moment, maleParams).calculationResultJson!) as Map<String, dynamic>;
      final femaleResult = jsonDecode(_calculator.calculate(_moment, femaleParams).calculationResultJson!) as Map<String, dynamic>;
      expect(maleResult, isNot(equals(femaleResult)));
    });
  });
}
