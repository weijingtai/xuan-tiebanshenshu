/// 邵子数会话数据模型
///
/// 对标 kao_ke_session_models.dart，定义邵子数会话的所有枚举、记录、快照和聚合根。
/// 邵子数为纯演绎流程（无交互选择），阶段比考刻更简单。
library;

import 'package:json_annotation/json_annotation.dart';
import 'package:metaphysics_core/models/eight_chars.dart';

part 'shao_zi_shu_session_models.g.dart';

// =============================================================================
// 枚举定义
// =============================================================================

/// 邵子数会话阶段（纯计算流程，无交互选择）
enum ShaoZiShuSessionPhase {
  @JsonValue('initialized')
  initialized,        // 已初始化，等待开始计算

  @JsonValue('calculating')
  calculating,        // 正在计算中

  @JsonValue('calculated')
  calculated,         // 计算完成（条文已得）

  @JsonValue('resultReady')
  resultReady;        // 结果就绪（可展示）

  const ShaoZiShuSessionPhase();
}

/// 邵子数会话状态
enum ShaoZiShuSessionStatus {
  @JsonValue('notStarted')
  notStarted,

  @JsonValue('inProgress')
  inProgress,

  @JsonValue('completed')
  completed,

  @JsonValue('cancelled')
  cancelled,

  @JsonValue('error')
  error;

  const ShaoZiShuSessionStatus();
}

// =============================================================================
// 计算记录（值对象）
// =============================================================================

/// 邵子数计算记录
///
/// 对标 [KeSelectionRecord]，但邵子数为一次性计算结果，非分步交互。
/// 记录完整的计算输入、中间值与最终条文。
@JsonSerializable()
class ShaoZiShuCalculationRecord {
  /// 输入八字
  final EightChars eightChars;

  /// 12 个数（4天干 + 8地支河图数）
  final List<int> twelveNumbers;

  /// 天数（奇数之和取模25，0→25）
  final int tianShu;

  /// 地数（偶数之和取模30，0→30）
  final int diShu;

  /// 本命基数（天数×8 + 地数）
  final int benMingJiShu;

  /// 条文编号（1~6144）
  final int tiaoWenNumber;

  /// 加一倍法展开后的条文列表（9个编号）
  final List<int> expandedTiaoWenNumbers;

  /// 计算过程描述
  final String calculationDetail;

  /// 计算时间
  final DateTime calculatedAt;

  const ShaoZiShuCalculationRecord({
    required this.eightChars,
    required this.twelveNumbers,
    required this.tianShu,
    required this.diShu,
    required this.benMingJiShu,
    required this.tiaoWenNumber,
    required this.expandedTiaoWenNumbers,
    required this.calculationDetail,
    required this.calculatedAt,
  });

  factory ShaoZiShuCalculationRecord.fromJson(Map<String, dynamic> json) =>
      _$ShaoZiShuCalculationRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ShaoZiShuCalculationRecordToJson(this);
}

// =============================================================================
// 快照模型
// =============================================================================

/// 邵子数会话阶段快照
///
/// 对标 [KaoKeSessionSnapshot]，记录某一时刻的完整会话状态，
/// 用于阶段回滚。
@JsonSerializable()
class ShaoZiShuSessionSnapshot {
  /// 快照唯一 ID
  final String snapshotId;

  /// 当时所处阶段
  final ShaoZiShuSessionPhase phase;

  /// 快照时间戳
  final DateTime timestamp;

  /// 完整会话状态（session.toJson()）
  final Map<String, dynamic> state;

  const ShaoZiShuSessionSnapshot({
    required this.snapshotId,
    required this.phase,
    required this.timestamp,
    required this.state,
  });

  factory ShaoZiShuSessionSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ShaoZiShuSessionSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$ShaoZiShuSessionSnapshotToJson(this);
}

// =============================================================================
// 聚合根：ShaoZiShuSession
// =============================================================================

/// 邵子数会话聚合根
///
/// 对标 [KaoKeSession]，使用 copyWith 不可变更新 + phaseHistory 快照链。
/// 邵子数为纯演绎，不含刻选择、斗甲乙宫选择等交互记录。
@JsonSerializable()
class ShaoZiShuSession {
  /// 会话唯一 ID
  final String sessionId;

  /// 会话名称
  final String sessionName;

  /// 计算结果记录（计算完成后非空）
  @JsonKey(
    fromJson: _calculationRecordFromJson,
    toJson: _calculationRecordToJson,
  )
  final ShaoZiShuCalculationRecord? calculationRecord;

  /// 当前阶段
  final ShaoZiShuSessionPhase currentPhase;

  /// 阶段快照链（用于回滚）
  @JsonKey(
    fromJson: _snapshotsFromJson,
    toJson: _snapshotsToJson,
  )
  final List<ShaoZiShuSessionSnapshot> phaseHistory;

  /// 会话状态
  final ShaoZiShuSessionStatus status;

  /// 会话开始时间
  final DateTime startTime;

  /// 最后活动时间
  final DateTime lastActivityAt;

  /// 会话结束时间
  final DateTime? endTime;

  /// 错误信息
  final String? errorMessage;

  const ShaoZiShuSession({
    required this.sessionId,
    required this.sessionName,
    this.calculationRecord,
    this.currentPhase = ShaoZiShuSessionPhase.initialized,
    this.phaseHistory = const [],
    this.status = ShaoZiShuSessionStatus.notStarted,
    required this.startTime,
    required this.lastActivityAt,
    this.endTime,
    this.errorMessage,
  });

  // ===========================================================================
  // 工厂方法
  // ===========================================================================

  /// 创建新会话
  factory ShaoZiShuSession.create({
    required String sessionId,
    required String sessionName,
  }) {
    final now = DateTime.now();
    return ShaoZiShuSession(
      sessionId: sessionId,
      sessionName: sessionName,
      startTime: now,
      lastActivityAt: now,
    );
  }

  // ===========================================================================
  // JSON 序列化
  // ===========================================================================

  factory ShaoZiShuSession.fromJson(Map<String, dynamic> json) =>
      _$ShaoZiShuSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ShaoZiShuSessionToJson(this);

  // ===========================================================================
  // copyWith 不可变更新
  // ===========================================================================

  ShaoZiShuSession copyWith({
    String? sessionId,
    String? sessionName,
    ShaoZiShuCalculationRecord? calculationRecord,
    ShaoZiShuSessionPhase? currentPhase,
    List<ShaoZiShuSessionSnapshot>? phaseHistory,
    ShaoZiShuSessionStatus? status,
    DateTime? startTime,
    DateTime? lastActivityAt,
    DateTime? endTime,
    String? errorMessage,
  }) {
    return ShaoZiShuSession(
      sessionId: sessionId ?? this.sessionId,
      sessionName: sessionName ?? this.sessionName,
      calculationRecord: calculationRecord ?? this.calculationRecord,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseHistory: phaseHistory ?? this.phaseHistory,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ===========================================================================
  // 派生 getter
  // ===========================================================================

  /// 是否可以回滚（有历史快照）
  bool get canRollback => phaseHistory.isNotEmpty;

  /// 是否已完成
  bool get isCompleted => status == ShaoZiShuSessionStatus.completed;

  /// 是否计算中
  bool get isInProgress => status == ShaoZiShuSessionStatus.inProgress;

  // ===========================================================================
  // 自定义 JSON 序列化辅助方法
  // ===========================================================================

  static ShaoZiShuCalculationRecord? _calculationRecordFromJson(
    Map<String, dynamic>? json,
  ) {
    return json != null
        ? ShaoZiShuCalculationRecord.fromJson(json)
        : null;
  }

  static Map<String, dynamic>? _calculationRecordToJson(
    ShaoZiShuCalculationRecord? record,
  ) {
    return record?.toJson();
  }

  static List<ShaoZiShuSessionSnapshot> _snapshotsFromJson(
    List<dynamic> json,
  ) {
    return json
        .map((e) =>
            ShaoZiShuSessionSnapshot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _snapshotsToJson(
    List<ShaoZiShuSessionSnapshot> snapshots,
  ) {
    return snapshots.map((e) => e.toJson()).toList();
  }
}
