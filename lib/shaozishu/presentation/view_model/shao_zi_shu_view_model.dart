/// 邵子数 ViewModel
///
/// 对标 kao_ke_view_model.dart，使用 ChangeNotifier + _executeWithLoading 模式。
/// 从 _session 单一可信源派生所有状态。
library;

import 'package:flutter/material.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

import '../../domain/session/shao_zi_shu_session_models.dart';
import '../../helper/shao_zi_shu_calculation_helper.dart';
import '../../application/shao_zi_shu_use_case.dart';

/// 邵子数状态管理 ViewModel
///
/// 职责：
/// - 封装 UseCase 调用，管理加载/错误状态
/// - 从 _session 派生所有只读 getter（单一可信源）
/// - 缓存条文查询结果
class ShaoZiShuViewModel extends ChangeNotifier {
  final ShaoZiShuUseCase _useCase;

  /// 当前会话（单一可信源）
  ShaoZiShuSession? _session;

  /// 加载状态
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 缓存的 ShaoZiShuResult（从 calculationRecord 重建，供 Widget 展示）
  ShaoZiShuResult? _shaoZiShuResult;

  /// 缓存的条文列表
  List<TiaoWenDataModel>? _tiaoWenResults;

  /// 缓存的扩展条文（加一倍法）
  Map<int, TiaoWenDataModel>? _expandedTiaoWenResults;

  ShaoZiShuViewModel({
    required ShaoZiShuUseCase useCase,
  }) : _useCase = useCase;

  // ==================== Getters ====================

  ShaoZiShuSession? get session => _session;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 当前阶段
  ShaoZiShuSessionPhase? get currentPhase => _session?.currentPhase;

  /// 是否可以回滚
  bool get canRollback => _session?.canRollback ?? false;

  /// 计算记录
  ShaoZiShuCalculationRecord? get calculationRecord =>
      _session?.calculationRecord;

  /// 计算结果
  ShaoZiShuResult? get shaoZiShuResult => _shaoZiShuResult;

  /// 条文列表
  List<TiaoWenDataModel>? get tiaoWenResults => _tiaoWenResults;

  /// 扩展条文（编号 → 内容）
  Map<int, TiaoWenDataModel>? get expandedTiaoWenResults =>
      _expandedTiaoWenResults;

  /// 输入八字
  EightChars? get eightChars {
    final id = _session?.sessionId;
    return id != null ? _useCase.getEightChars(id) : null;
  }

  // ==================== Actions ====================

  /// 初始化会话
  ///
  /// [eightChars] 用户八字
  /// [sessionName] 会话名称（可选）
  Future<void> initialize({
    required EightChars eightChars,
    String? sessionName,
  }) async {
    await _executeWithLoading(() async {
      _session = await _useCase.initializeSession(
        eightChars: eightChars,
        sessionName: sessionName,
      );
    });
  }

  /// 开始计算（初始化 + 计算连续两步）
  ///
  /// 前置条件：[_session] 处于 initialized 阶段。
  Future<void> startCalculation() async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    await _executeWithLoading(() async {
      _session = await _useCase.calculate(session: _session!);

      // 从 calculationRecord 重建 ShaoZiShuResult 供 Widget 展示
      final record = _session!.calculationRecord;
      if (record != null) {
        _shaoZiShuResult = ShaoZiShuResult(
          twelveNumbers: record.twelveNumbers,
          tianShuSum:
              record.twelveNumbers.where((n) => n.isOdd).fold<int>(0, (a, b) => a + b),
          diShuSum:
              record.twelveNumbers.where((n) => n.isEven).fold<int>(0, (a, b) => a + b),
          tianShu: record.tianShu,
          diShu: record.diShu,
          benMingJiShu: record.benMingJiShu,
          tiaoWenNumber: record.tiaoWenNumber,
          expandedTiaoWenNumbers: record.expandedTiaoWenNumbers,
          calculationDetail: record.calculationDetail,
        );
      }
    });
  }

  /// 获取条文内容
  ///
  /// 前置条件：[_session] 处于 calculated 阶段。
  Future<void> loadTiaoWenContent() async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    await _executeWithLoading(() async {
      _session = await _useCase.fetchTiaoWenContent(session: _session!);

      // 从 UseCase 缓存获取条文
      final expanded = _useCase.lastExpandedTiaoWenContent;
      if (expanded != null) {
        _expandedTiaoWenResults = expanded;
        _tiaoWenResults = expanded.values.toList();
      }
    });
  }

  /// 回滚到上一阶段
  Future<void> rollback() async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    await _executeWithLoading(() async {
      // 回滚到上一阶段
      _session = await _useCase.rollbackToPhase(
        session: _session!,
        phase: _getPreviousRollbackPhase(_session!.currentPhase),
      );

      // 清除下游缓存
      if (_session!.currentPhase == ShaoZiShuSessionPhase.initialized) {
        _shaoZiShuResult = null;
        _tiaoWenResults = null;
        _expandedTiaoWenResults = null;
      } else if (_session!.currentPhase == ShaoZiShuSessionPhase.calculated) {
        _tiaoWenResults = null;
        _expandedTiaoWenResults = null;
      }
    });
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== Private Methods ====================

  /// 统一加载封装（对标 _executeWithLoading）
  ///
  /// 设置/清除 isLoading 和 error，异常时自动捕获。
  Future<void> _executeWithLoading(Future<void> Function() action) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await action();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 获取当前阶段可回滚到的上一阶段
  ShaoZiShuSessionPhase _getPreviousRollbackPhase(
    ShaoZiShuSessionPhase current,
  ) {
    switch (current) {
      case ShaoZiShuSessionPhase.resultReady:
        return ShaoZiShuSessionPhase.calculated;
      case ShaoZiShuSessionPhase.calculated:
        return ShaoZiShuSessionPhase.calculating;
      case ShaoZiShuSessionPhase.calculating:
        return ShaoZiShuSessionPhase.initialized;
      case ShaoZiShuSessionPhase.initialized:
        throw Exception('已是最早阶段，无法回滚');
    }
  }
}
