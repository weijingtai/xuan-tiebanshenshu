import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/geo_location.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:provider/provider.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:tiebanshenshu/domain/pipeline/tieban_chart_params.dart';
import 'package:tiebanshenshu/domain/pipeline/tieban_pipeline_executor.dart';
import 'package:tiebanshenshu/domain/pipeline/pipeline_evidence.dart';
import 'package:tiebanshenshu/presentation/pages/chart_input_page.dart';
import 'package:tiebanshenshu/presentation/viewmodels/theme_view_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:xuan_time_location/xuan_time_location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  // 与产品 main.dart / module_manifest 一致：注册产品时区标识 Asia/Beijing 别名，
  // 否则 dropdown 找不到 chinaTimeZoneId 选项。
  ensureChinaTimeZoneAlias();


  testWidgets('A: 排盘按钮路径真实执行 Pipeline，落库走 Record', (tester) async {
    final recordRepo = _InMemoryTiebanRecordRepository();
    final executor = TiebanPipelineExecutor(
      momentResolver: _FixedMomentResolver(),
    );

    await tester.pumpWidget(
      _wrap(executor: executor, recordRepo: recordRepo),
    );

    final state = tester.state<State<ChartInputPage>>(find.byType(ChartInputPage)) as dynamic;
    await state.runPipelineWith(dateTime: DateTime(1990, 6, 21, 12));

    final record = state.lastPipelineRecord as TiebanDivinationRecordContract?;
    expect(record, isNotNull);
    expect(record!.uuid, 'tieban-${DateTime(1990, 6, 21, 12).millisecondsSinceEpoch}');
    expect(state.lastPipelineError, isNull);

    final saved = await recordRepo.getAllRecords();
    expect(saved, hasLength(1));
    expect(saved.single.uuid, record.uuid);

    // ── 执行证据：executor 真实执行 + 落库 uuid 同源 ──
    final evidence = state.lastPipelineEvidence as PipelineEvidence?;
    expect(evidence, isNotNull, reason: 'pipeline 路径必须产出执行证据');
    expect(evidence!.callCount, 1, reason: 'executor 恰好执行一次');
    expect(evidence.requestId, record.uuid, reason: 'requestId 取 Record uuid');
    expect(evidence.resultUuid, record.uuid,
        reason: 'resultUuid 与落库 Record uuid 同源');
    expect(evidence.module, 'tiebanshenshu');
    expect(evidence.error, isNull, reason: '成功执行无异常');
    expect(evidence.keyResult, isNotNull, reason: '先天/后天卦是页面可观察结果');
    // 落库的 Record 就是 lastPipelineRecord（同 uuid）
    expect(saved.single.uuid, record.uuid,
        reason: '落库 Record uuid 与排盘 uuid 同源');
  });

  testWidgets('B: 未选时间不崩、不落库', (tester) async {
    final recordRepo = _InMemoryTiebanRecordRepository();
    final executor = TiebanPipelineExecutor(
      momentResolver: _FixedMomentResolver(),
    );

    await tester.pumpWidget(
      _wrap(executor: executor, recordRepo: recordRepo),
    );

    final state = tester.state<State<ChartInputPage>>(find.byType(ChartInputPage)) as dynamic;
    await state.runPipelineWith(dateTime: null);

    expect(state.lastPipelineError, '未选择时间');
    expect(state.lastPipelineRecord, isNull);
    expect(await recordRepo.getAllRecords(), isEmpty);
  });

  testWidgets('B2: Pipeline 抛错时不崩、不落库、错误被记录', (tester) async {
    final recordRepo = _InMemoryTiebanRecordRepository();
    final executor = TiebanPipelineExecutor(
      momentResolver: _ThrowingMomentResolver(),
    );

    await tester.pumpWidget(
      _wrap(executor: executor, recordRepo: recordRepo),
    );

    final state = tester.state<State<ChartInputPage>>(find.byType(ChartInputPage)) as dynamic;
    await state.runPipelineWith(dateTime: DateTime(1990, 6, 21, 12));

    expect(state.lastPipelineRecord, isNull);
    expect(state.lastPipelineError, isNotNull);
    expect(await recordRepo.getAllRecords(), isEmpty);
  });

  test('C: TiebanChartParams toJson/fromJson 互逆 round-trip', () {
    const params = TiebanChartParams(
      latitude: 31.2304,
      longitude: 121.4737,
      altitude: 4.0,
      timezone: 'Asia/Shanghai',
      isMale: true,
      uuid: 'tieban-test-001',
    );
    final decoded = TiebanChartParams.fromJson(params.toJson());
    expect(decoded, params);
  });

  test('C2: fromJson 缺字段套默认不抛', () {
    final decoded = TiebanChartParams.fromJson(const {});
    expect(decoded.latitude, 0.0);
    expect(decoded.longitude, 0.0);
    expect(decoded.altitude, 0.0);
    expect(decoded.timezone, chinaTimeZoneId);
    expect(decoded.isMale, false);
    expect(decoded.uuid, '');
  });

  test('C3: fromJson 类型不合法抛 FormatException，不静默兜底', () {
    expect(
      () => TiebanChartParams.fromJson(const {'latitude': '39.9'}),
      throwsFormatException,
    );
    expect(
      () => TiebanChartParams.fromJson(const {'timezone': 42}),
      throwsFormatException,
    );
    expect(
      () => TiebanChartParams.fromJson(const {'isMale': 'yes'}),
      throwsFormatException,
    );
    expect(
      () => TiebanChartParams.fromJson(const {'uuid': 123}),
      throwsFormatException,
    );
  });

  testWidgets('D: 时区来自地点携带值，不落回 chinaTimeZoneId 兜底', (tester) async {
    final recordRepo = _InMemoryTiebanRecordRepository();
    final executor = TiebanPipelineExecutor(
      momentResolver: _FixedMomentResolver(),
    );

    await tester.pumpWidget(
      _wrap(executor: executor, recordRepo: recordRepo),
    );

    final state = tester.state<State<ChartInputPage>>(find.byType(ChartInputPage)) as dynamic;
    final location = Location(
      address: Address(
        countryName: '美国',
        countryId: 1,
        regionId: 1,
        province: GeoLocation(
          name: '纽约',
          latitude: 40.7128,
          longitude: -74.0060,
          level: GeoLevel.province,
          code: 'US-NY',
          parentCode: '0',
        ),
        timezone: 'America/New_York',
      ),
    );
    await state.runPipelineWith(
      dateTime: DateTime(1990, 6, 21, 12),
      location: location,
    );

    final record = state.lastPipelineRecord as TiebanDivinationRecordContract?;
    expect(record, isNotNull, reason: '地点携带时区必须能正常排盘');
    final paramsJson =
        jsonDecode(record!.paramsJson!) as Map<String, dynamic>;
    expect(paramsJson['timezone'], equals('America/New_York'));
  });
}

Widget _wrap({
  required TiebanPipelineExecutor executor,
  required TiebanRecordRepository recordRepo,
}) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel(),
        ),
        Provider<TiebanPipelineExecutor>.value(value: executor),
        Provider<TiebanRecordRepository>.value(value: recordRepo),
      ],
      child: const ChartInputPage(),
    ),
  );
}

class _InMemoryTiebanRecordRepository implements TiebanRecordRepository {
  final List<TiebanDivinationRecordContract> _records = [];

  @override
  Future<String> saveRecord(TiebanDivinationRecordContract record) async {
    _records.add(record);
    return record.uuid;
  }

  @override
  Future<List<TiebanDivinationRecordContract>> getAllRecords() async {
    return List.of(_records);
  }

  @override
  Future<TiebanDivinationRecordContract?> getRecordByUuid(String uuid) async {
    for (final r in _records) {
      if (r.uuid == uuid) return r;
    }
    return null;
  }

  @override
  Future<bool> softDeleteRecord(String uuid) async {
    _records.removeWhere((r) => r.uuid == uuid);
    return true;
  }

  @override
  Stream<List<TiebanDivinationRecordContract>> watchAllRecords() async* {
    yield List.of(_records);
  }
}

/// 固定 ResolvedMoment，隔离真实历法计算。
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

/// 模拟新路径失败，验证错误被记录。
class _ThrowingMomentResolver implements MomentResolver {
  const _ThrowingMomentResolver();

  @override
  ResolvedMoment resolve(DivinationMoment moment) {
    throw StateError('模拟新路径失败');
  }

  @override
  List<ResolvedMoment> resolveCandidates(
    DivinationMoment moment,
    CandidateSpec spec,
  ) => [];
}
