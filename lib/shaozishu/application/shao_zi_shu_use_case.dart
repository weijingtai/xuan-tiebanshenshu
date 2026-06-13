/// 邵子数 UseCase
///
/// 业务编排层，对标 kao_ke_use_case.dart。
/// 协调 SessionManager、CalculationStrategy，遵循四步模板：
///   校验 → 调用策略 → copyWith 更新 Session → SessionManager.advanceToPhase
library;

import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import '../domain/session/shao_zi_shu_session_manager.dart';
import '../domain/session/shao_zi_shu_session_models.dart';
import '../domain/strategy/shao_zi_shu_calculation_strategy.dart';
import '../helper/shao_zi_shu_calculation_helper.dart';

/// 邵子数业务编排 UseCase
///
/// 纯演绎流程（无交互选择）：
///   initializeSession → calculate → fetchTiaoWenContent
class ShaoZiShuUseCase {
  final ShaoZiShuSessionManager _sessionManager;
  final ShaoZiShuCalculationStrategy _calculationStrategy;

  /// 八字缓存（Session 模型不含八字，由 UseCase 持有）
  final Map<String, EightChars> _eightCharsCache = {};

  /// 上次获取的扩展条文缓存
  Map<int, TiaoWenDataModel>? _lastExpandedTiaoWenContent;

  ShaoZiShuUseCase({
    required ShaoZiShuSessionManager sessionManager,
    required ShaoZiShuCalculationStrategy calculationStrategy,
  })  : _sessionManager = sessionManager,
        _calculationStrategy = calculationStrategy;

  // ===========================================================================
  // 公开方法
  // ===========================================================================

  /// 1. 初始化会话（八字输入）→ 推进到 initialized
  ///
  /// [eightChars] 用户八字
  /// [sessionName] 会话名称（可选）
  Future<ShaoZiShuSession> initializeSession({
    required EightChars eightChars,
    String? sessionName,
  }) async {
    // 创建新会话
    final session = await _sessionManager.createSession(
      sessionName: sessionName,
    );

    // 缓存八字
    _eightCharsCache[session.sessionId] = eightChars;

    // 推进到 initialized
    final updatedSession = await _sessionManager.advanceToPhase(
      session: session,
      targetPhase: ShaoZiShuSessionPhase.initialized,
    );

    return updatedSession;
  }

  /// 2. 执行计算：initialized → calculating → calculated
  ///
  /// 四步模板：校验 → 推进到 calculating → 调用策略 → copyWith → 推进到 calculated
  ///
  /// [session] 当前会话（必须处于 initialized 阶段）
  Future<ShaoZiShuSession> calculate({
    required ShaoZiShuSession session,
  }) async {
    // --- 校验 ---
    if (session.currentPhase != ShaoZiShuSessionPhase.initialized) {
      throw Exception(
        'calculate 要求当前阶段为 initialized，实际为 ${session.currentPhase}',
      );
    }

    final eightChars = _eightCharsCache[session.sessionId];
    if (eightChars == null) {
      throw Exception('会话 ${session.sessionId} 未关联八字');
    }

    // --- 推进到 calculating ---
    var current = await _sessionManager.advanceToPhase(
      session: session,
      targetPhase: ShaoZiShuSessionPhase.calculating,
    );

    // --- 调用策略 ---
    final result = _calculationStrategy.calculateResult(eightChars);

    // --- 构建 CalculationRecord ---
    final record = ShaoZiShuCalculationRecord(
      eightChars: eightChars,
      twelveNumbers: result.twelveNumbers,
      tianShu: result.tianShu,
      diShu: result.diShu,
      benMingJiShu: result.benMingJiShu,
      tiaoWenNumber: result.tiaoWenNumber,
      expandedTiaoWenNumbers: result.expandedTiaoWenNumbers,
      calculationDetail: result.calculationDetail,
      calculatedAt: DateTime.now(),
    );

    // --- copyWith 更新 → 推进到 calculated ---
    current = current.copyWith(calculationRecord: record);
    current = await _sessionManager.advanceToPhase(
      session: current,
      targetPhase: ShaoZiShuSessionPhase.calculated,
    );

    return current;
  }

  /// 3. 获取条文内容 → calculated → resultReady
  ///
  /// 四步模板：校验 → 调用策略 → copyWith → advanceToPhase
  ///
  /// [session] 当前会话（必须处于 calculated 阶段）
  Future<ShaoZiShuSession> fetchTiaoWenContent({
    required ShaoZiShuSession session,
  }) async {
    // --- 校验 ---
    if (session.currentPhase != ShaoZiShuSessionPhase.calculated) {
      throw Exception(
        'fetchTiaoWenContent 要求当前阶段为 calculated，实际为 ${session.currentPhase}',
      );
    }

    final record = session.calculationRecord;
    if (record == null) {
      throw Exception('计算结果为空，无法获取条文内容');
    }

    // --- 调用策略 ---
    final result = ShaoZiShuResult(
      twelveNumbers: record.twelveNumbers,
      tianShuSum: record.twelveNumbers.where((n) => n.isOdd).fold<int>(0, (a, b) => a + b),
      diShuSum: record.twelveNumbers.where((n) => n.isEven).fold<int>(0, (a, b) => a + b),
      tianShu: record.tianShu,
      diShu: record.diShu,
      benMingJiShu: record.benMingJiShu,
      tiaoWenNumber: record.tiaoWenNumber,
      expandedTiaoWenNumbers: record.expandedTiaoWenNumbers,
      calculationDetail: record.calculationDetail,
    );

    _lastExpandedTiaoWenContent = await _calculationStrategy
        .getExpandedTiaoWenContent(result: result);

    // --- copyWith → 推进到 resultReady ---
    final updatedSession = session.copyWith(
      lastActivityAt: DateTime.now(),
    );

    final finalSession = await _sessionManager.advanceToPhase(
      session: updatedSession,
      targetPhase: ShaoZiShuSessionPhase.resultReady,
    );

    return finalSession;
  }

  /// 4. 回滚到指定阶段
  ///
  /// [session] 当前会话
  /// [phase] 目标阶段（必须是历史中存在的阶段）
  Future<ShaoZiShuSession> rollbackToPhase({
    required ShaoZiShuSession session,
    required ShaoZiShuSessionPhase phase,
  }) async {
    // 查找目标阶段的快照
    final targetSnapshot = session.phaseHistory.lastWhere(
      (snapshot) => snapshot.phase == phase,
      orElse: () => throw Exception('未找到目标阶段的快照: $phase'),
    );

    // 回滚到快照
    final rolledBackSession = await _sessionManager.rollbackToSnapshot(
      session: session,
      snapshotId: targetSnapshot.snapshotId,
    );

    return rolledBackSession;
  }

  /// 获取上次获取的扩展条文内容
  ///
  /// 在 [fetchTiaoWenContent] 之后调用以获取缓存的条文数据。
  Map<int, TiaoWenDataModel>? get lastExpandedTiaoWenContent =>
      _lastExpandedTiaoWenContent;

  /// 获取会话对应八字
  EightChars? getEightChars(String sessionId) => _eightCharsCache[sessionId];

  /// 清除缓存
  void disposeSession(String sessionId) {
    _eightCharsCache.remove(sessionId);
    _lastExpandedTiaoWenContent = null;
  }
}
