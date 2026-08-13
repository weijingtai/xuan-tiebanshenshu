import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:tiebanshenshu/domain/pipeline/tieban_chart_params.dart';
import 'package:tiebanshenshu/domain/pipeline/tieban_pipeline_executor.dart';

final _moment = ResolvedMoment(
  source: DivinationMoment(
    instantUtc: DateTime.utc(1990, 6, 21, 4),
    place: const GeoPoint(latitude: 31.2304, longitude: 121.4737),
    reckoning: EnumDatetimeType.standard,
  ),
  nominalTime: DateTime(1990, 6, 21, 12),
  eightChars: EightChars(
    year: JiaZi.JIA_ZI,
    month: JiaZi.JIA_ZI,
    day: JiaZi.JIA_ZI,
    time: JiaZi.JIA_ZI,
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

void main() {
  group('TiebanPipelineExecutor', () {
    final executor = TiebanPipelineExecutor(momentResolver: _FixedMomentResolver());

    test('execute() 跑通完整排盘，返回 TiebanDivinationRecordContract 且关键字段具具体值', () async {
      final contract = await executor.execute(
        ChartRequest<TiebanChartParams>(
          moment: _moment.source,
          params: _params,
        ),
      );

      expect(contract.uuid, equals(''));
      expect(contract.question, equals('铁板神数排盘'));
      expect(contract.createdAt, equals(DateTime(1990, 6, 21, 12)));

      final calculationResult = jsonDecode(contract.calculationResultJson!) as Map<String, dynamic>;
      expect(calculationResult['xiantianGua'], equals('渐'));
      expect(calculationResult['houTianGua'], equals('升'));
      expect(calculationResult['yuanTangYaoIndex'], equals(2));

      final paramsJson = jsonDecode(contract.paramsJson!) as Map<String, dynamic>;
      expect(paramsJson['isMale'], equals(true));
      expect(paramsJson['latitude'], equals(31.2304));
      expect(paramsJson['longitude'], equals(121.4737));
      expect(paramsJson['timezone'], equals('Asia/Shanghai'));
    });

    test('产出的 contract 满足 Chart 契约：toJson() 返回非空 Map，可 jsonDecode 往返', () async {
      final contract = await executor.execute(
        ChartRequest<TiebanChartParams>(
          moment: _moment.source,
          params: _params,
        ),
      );
      final jsonMap = contract.toJson();

      expect(jsonMap.isEmpty, equals(false));
      expect(jsonMap['uuid'], equals(''));
      expect(jsonMap['question'], equals('铁板神数排盘'));
      expect(jsonMap['createdAt'], equals('1990-06-21T12:00:00.000'));

      final encodedString = jsonEncode(jsonMap);
      final decodedMap = jsonDecode(encodedString) as Map<String, dynamic>;
      expect(decodedMap['uuid'], equals(''));
      expect(decodedMap['question'], equals('铁板神数排盘'));
      expect(decodedMap['createdAt'], equals('1990-06-21T12:00:00.000'));
      expect(decodedMap['calculationResultJson'], equals(contract.calculationResultJson));
      expect(decodedMap['paramsJson'], equals(contract.paramsJson));
    });

    test('相同输入产出稳定结果（同一 moment + params 调两次，关键字段一致）', () async {
      final req = ChartRequest<TiebanChartParams>(
        moment: _moment.source,
        params: _params,
      );
      final result1 = await executor.execute(req);
      final result2 = await executor.execute(req);

      expect(result1.question, equals(result2.question));
      expect(result1.createdAt, equals(result2.createdAt));
      expect(result1.calculationResultJson, equals(result2.calculationResultJson));
      expect(result1.paramsJson, equals(result2.paramsJson));
      expect(result1, equals(result2));
    });
  });
}

/// 固定 ResolvedMoment，隔离真实历法计算，专注验证接线与入参透传。
class _FixedMomentResolver implements MomentResolver {
  const _FixedMomentResolver();

  @override
  ResolvedMoment resolve(DivinationMoment moment) => ResolvedMoment(
    source: moment,
    nominalTime: DateTime(1990, 6, 21, 12),
    eightChars: EightChars(
      year: JiaZi.JIA_ZI,
      month: JiaZi.JIA_ZI,
      day: JiaZi.JIA_ZI,
      time: JiaZi.JIA_ZI,
    ),
    lunar: const LunarDate(month: 5, day: 1, isLeapMonth: false),
    jieQi: JieQiInfo(
      jieQi: TwentyFourJieQi.XIA_ZHI,
      startAt: DateTime(1990, 6, 21),
      endAt: DateTime(1990, 7, 7),
    ),
  );

  @override
  List<ResolvedMoment> resolveCandidates(
    DivinationMoment moment,
    CandidateSpec spec,
  ) => [];
}
