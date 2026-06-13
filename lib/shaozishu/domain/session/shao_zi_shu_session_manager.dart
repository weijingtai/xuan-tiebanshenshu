/// 邵子数会话管理器
///
/// 对标 kao_ke_session_manager.dart，负责会话的生命周期管理和状态机推进。
/// 邵子数为纯演绎流程，阶段转换规则比考刻更简单，无交互选择分支。
library;

import 'shao_zi_shu_session_models.dart';

/// 异常类 — 无效的阶段转换
class InvalidShaoZiShuPhaseTransitionException implements Exception {
  final ShaoZiShuSessionPhase currentPhase;
  final ShaoZiShuSessionPhase targetPhase;

  const InvalidShaoZiShuPhaseTransitionException(
    this.currentPhase,
    this.targetPhase,
  );

  @override
  String toString() =>
      'Invalid ShaoZiShu phase transition: $currentPhase -> $targetPhase';
}

/// 邵子数会话管理器
///
/// 职责：
/// - 内存存储所有活跃会话（Map<String, ShaoZiShuSession>）
/// - 创建 / 恢复 / 保存会话
/// - 推进阶段 + 自动创建快照
/// - 阶段回滚（到指定快照 / 到上一阶段）
/// - 校验阶段转换合法性（硬编码状态机规则）
///
/// 状态机规则（纯演绎，无交互）：
/// ```
/// initialized  →  calculating   (开始计算)
/// calculating  →  calculated    (计算完成)
/// calculated   →  resultReady   (结果就绪)
/// ```
class ShaoZiShuSessionManager {
  /// 内存存储
  final Map<String, ShaoZiShuSession> _sessions = {};

  ShaoZiShuSessionManager();

  // ===========================================================================
  // 会话生命周期
  // ===========================================================================

  /// 创建新会话
  ///
  /// [sessionName] 会话名称，不传则自动生成。
  Future<ShaoZiShuSession> createSession({
    String? sessionName,
  }) async {
    final sessionId = _generateSessionId();
    final name = sessionName ??
        'ShaoZiShu_Session_${DateTime.now().millisecondsSinceEpoch}';

    final session = ShaoZiShuSession.create(
      sessionId: sessionId,
      sessionName: name,
    );

    _sessions[session.sessionId] = session;
    return session;
  }

  /// 恢复会话
  Future<ShaoZiShuSession?> restoreSession(String sessionId) async {
    return _sessions[sessionId];
  }

  /// 保存会话（更新内存中的会话）
  Future<void> saveSession(ShaoZiShuSession session) async {
    _sessions[session.sessionId] = session;
  }

  // ===========================================================================
  // 阶段推进
  // ===========================================================================

  /// 推进到指定阶段
  ///
  /// 执行流程：校验阶段转换合法性 → 创建当前状态快照 → 更新 session。
  ///
  /// [session] 当前会话
  /// [targetPhase] 目标阶段
  ///
  /// 返回更新后的会话（已写入内存）。
  /// 若目标阶段非法，抛出 [InvalidShaoZiShuPhaseTransitionException]。
  Future<ShaoZiShuSession> advanceToPhase({
    required ShaoZiShuSession session,
    required ShaoZiShuSessionPhase targetPhase,
  }) async {
    // 1. 校验阶段转换
    _validatePhaseTransition(session.currentPhase, targetPhase);

    // 2. 创建快照（记录当前状态）
    final snapshot = createSnapshot(session);

    // 3. 不可变更新
    final updatedSession = session.copyWith(
      currentPhase: targetPhase,
      phaseHistory: [...session.phaseHistory, snapshot],
      lastActivityAt: DateTime.now(),
      status: ShaoZiShuSessionStatus.inProgress,
    );

    _sessions[updatedSession.sessionId] = updatedSession;
    return updatedSession;
  }

  // ===========================================================================
  // 快照管理
  // ===========================================================================

  /// 创建当前阶段快照
  ///
  /// 将当前 session 的完整状态序列化为 Map，嵌入快照对象。
  ShaoZiShuSessionSnapshot createSnapshot(ShaoZiShuSession session) {
    return ShaoZiShuSessionSnapshot(
      snapshotId: 'snapshot_${DateTime.now().millisecondsSinceEpoch}',
      phase: session.currentPhase,
      timestamp: DateTime.now(),
      state: session.toJson(),
    );
  }

  // ===========================================================================
  // 回滚
  // ===========================================================================

  /// 回滚到指定快照
  ///
  /// [session] 当前会话
  /// [snapshotId] 目标快照 ID
  ///
  /// 执行流程：查找快照 → 从快照恢复 session → 截断历史到该快照。
  Future<ShaoZiShuSession> rollbackToSnapshot({
    required ShaoZiShuSession session,
    required String snapshotId,
  }) async {
    // 查找快照索引
    final snapshotIndex = session.phaseHistory.indexWhere(
      (s) => s.snapshotId == snapshotId,
    );

    if (snapshotIndex == -1) {
      throw Exception('Snapshot not found: $snapshotId');
    }

    final snapshot = session.phaseHistory[snapshotIndex];

    // 从快照恢复
    final restoredSession = ShaoZiShuSession.fromJson(snapshot.state);

    // 截断历史到该快照（包含该快照）
    final truncatedHistory =
        session.phaseHistory.sublist(0, snapshotIndex + 1);

    final finalSession = restoredSession.copyWith(
      phaseHistory: truncatedHistory,
      lastActivityAt: DateTime.now(),
    );

    _sessions[finalSession.sessionId] = finalSession;
    return finalSession;
  }

  /// 回滚到上一阶段
  ///
  /// 等价于 rollbackToSnapshot(最后一个快照的 snapshotId)。
  Future<ShaoZiShuSession> rollbackToPreviousPhase(
    ShaoZiShuSession session,
  ) async {
    if (!session.canRollback) {
      throw Exception('No previous phase to rollback to');
    }

    final lastSnapshot = session.phaseHistory.last;
    return await rollbackToSnapshot(
      session: session,
      snapshotId: lastSnapshot.snapshotId,
    );
  }

  // ===========================================================================
  // 状态机校验（纯演绎，无交互分支）
  // ===========================================================================

  void _validatePhaseTransition(
    ShaoZiShuSessionPhase current,
    ShaoZiShuSessionPhase target,
  ) {
    const validTransitions =
        <ShaoZiShuSessionPhase, List<ShaoZiShuSessionPhase>>{
      ShaoZiShuSessionPhase.initialized: [
        ShaoZiShuSessionPhase.calculating,
      ],
      ShaoZiShuSessionPhase.calculating: [
        ShaoZiShuSessionPhase.calculated,
      ],
      ShaoZiShuSessionPhase.calculated: [
        ShaoZiShuSessionPhase.resultReady,
      ],
    };

    final allowed = validTransitions[current];
    if (allowed == null || !allowed.contains(target)) {
      throw InvalidShaoZiShuPhaseTransitionException(current, target);
    }
  }

  // ===========================================================================
  // 内部工具
  // ===========================================================================

  /// 生成会话 ID
  String _generateSessionId() {
    return 'shao_zi_shu_session_${DateTime.now().millisecondsSinceEpoch}';
  }
}
