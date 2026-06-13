/// 邵子先天推演 ViewModel
///
/// 管理推演页面的 UI 状态，通过 ChangeNotifier 通知视图更新。
library;

import 'package:flutter/material.dart';
import 'models/shaozi_tuibian_models.dart';
import 'shaozi_tuibian_use_case.dart';

/// 邵子先天推演 ViewModel
///
/// 继承 [ChangeNotifier]，负责管理推演全过程的 UI 状态。
class ShaoziTuibianViewModel extends ChangeNotifier {
  final ShaoziTuibianUseCase _useCase;

  /// 当前推演会话
  ShaoziTuibianSession? _session;
  ShaoziTuibianSession? get session => _session;

  /// 是否正在计算中
  bool _isCalculating = false;
  bool get isCalculating => _isCalculating;

  /// 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ShaoziTuibianViewModel({required ShaoziTuibianUseCase useCase})
      : _useCase = useCase;

  /// 当前阶段
  ShaoziTuibianPhase get currentPhase =>
      _session?.phase ?? ShaoziTuibianPhase.initialized;

  // TODO: 添加 startTuibian、advancePhase 等状态变更方法

  @override
  void dispose() {
    super.dispose();
  }
}
