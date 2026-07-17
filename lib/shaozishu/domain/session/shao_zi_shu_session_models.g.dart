// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shao_zi_shu_session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShaoZiShuCalculationRecord _$ShaoZiShuCalculationRecordFromJson(
  Map<String, dynamic> json,
) => ShaoZiShuCalculationRecord(
  eightChars: EightChars.fromJson(json['eightChars'] as Map<String, dynamic>),
  twelveNumbers: (json['twelveNumbers'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  tianShu: (json['tianShu'] as num).toInt(),
  diShu: (json['diShu'] as num).toInt(),
  benMingJiShu: (json['benMingJiShu'] as num).toInt(),
  tiaoWenNumber: (json['tiaoWenNumber'] as num).toInt(),
  expandedTiaoWenNumbers: (json['expandedTiaoWenNumbers'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  calculationDetail: json['calculationDetail'] as String,
  calculatedAt: DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$ShaoZiShuCalculationRecordToJson(
  ShaoZiShuCalculationRecord instance,
) => <String, dynamic>{
  'eightChars': instance.eightChars,
  'twelveNumbers': instance.twelveNumbers,
  'tianShu': instance.tianShu,
  'diShu': instance.diShu,
  'benMingJiShu': instance.benMingJiShu,
  'tiaoWenNumber': instance.tiaoWenNumber,
  'expandedTiaoWenNumbers': instance.expandedTiaoWenNumbers,
  'calculationDetail': instance.calculationDetail,
  'calculatedAt': instance.calculatedAt.toIso8601String(),
};

ShaoZiShuSessionSnapshot _$ShaoZiShuSessionSnapshotFromJson(
  Map<String, dynamic> json,
) => ShaoZiShuSessionSnapshot(
  snapshotId: json['snapshotId'] as String,
  phase: $enumDecode(_$ShaoZiShuSessionPhaseEnumMap, json['phase']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  state: json['state'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ShaoZiShuSessionSnapshotToJson(
  ShaoZiShuSessionSnapshot instance,
) => <String, dynamic>{
  'snapshotId': instance.snapshotId,
  'phase': _$ShaoZiShuSessionPhaseEnumMap[instance.phase]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'state': instance.state,
};

const _$ShaoZiShuSessionPhaseEnumMap = {
  ShaoZiShuSessionPhase.initialized: 'initialized',
  ShaoZiShuSessionPhase.calculating: 'calculating',
  ShaoZiShuSessionPhase.calculated: 'calculated',
  ShaoZiShuSessionPhase.resultReady: 'resultReady',
};

ShaoZiShuSession _$ShaoZiShuSessionFromJson(Map<String, dynamic> json) =>
    ShaoZiShuSession(
      sessionId: json['sessionId'] as String,
      sessionName: json['sessionName'] as String,
      calculationRecord: ShaoZiShuSession._calculationRecordFromJson(
        json['calculationRecord'] as Map<String, dynamic>?,
      ),
      currentPhase:
          $enumDecodeNullable(
            _$ShaoZiShuSessionPhaseEnumMap,
            json['currentPhase'],
          ) ??
          ShaoZiShuSessionPhase.initialized,
      phaseHistory: json['phaseHistory'] == null
          ? const []
          : ShaoZiShuSession._snapshotsFromJson(json['phaseHistory'] as List),
      status:
          $enumDecodeNullable(
            _$ShaoZiShuSessionStatusEnumMap,
            json['status'],
          ) ??
          ShaoZiShuSessionStatus.notStarted,
      startTime: DateTime.parse(json['startTime'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$ShaoZiShuSessionToJson(ShaoZiShuSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'sessionName': instance.sessionName,
      'calculationRecord': ShaoZiShuSession._calculationRecordToJson(
        instance.calculationRecord,
      ),
      'currentPhase': _$ShaoZiShuSessionPhaseEnumMap[instance.currentPhase]!,
      'phaseHistory': ShaoZiShuSession._snapshotsToJson(instance.phaseHistory),
      'status': _$ShaoZiShuSessionStatusEnumMap[instance.status]!,
      'startTime': instance.startTime.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

const _$ShaoZiShuSessionStatusEnumMap = {
  ShaoZiShuSessionStatus.notStarted: 'notStarted',
  ShaoZiShuSessionStatus.inProgress: 'inProgress',
  ShaoZiShuSessionStatus.completed: 'completed',
  ShaoZiShuSessionStatus.cancelled: 'cancelled',
  ShaoZiShuSessionStatus.error: 'error',
};
