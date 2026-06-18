import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../../service/strategy/yuan_tang_strategy.dart';

class YuanTangLiuyunViewModel extends ChangeNotifier {
  YuanTangBaseNumberModel? _model;
  int? _birthYear;
  YuanTangStrategy? _strategy;

  List<YuanTangLiunianGua> _allLiunianList = [];
  final Map<int, List<YuanTangLiuyueGua>> _liuyueCache = {};
  int? _selectedLiunianAge;

  bool get isInitialized => _model != null && _strategy != null;

  YuanTangBaseNumberModel get model => _model!;
  int get birthYear => _birthYear!;

  List<YuanTangLiunianGua> get allLiunianList => _allLiunianList;
  int? get selectedLiunianAge => _selectedLiunianAge;

  List<YuanTangLiunianGua> get xiantianLiunianList =>
      _allLiunianList.where((g) => g.guaSource == '先天卦').toList();

  List<YuanTangLiunianGua> get houtianLiunianList =>
      _allLiunianList.where((g) => g.guaSource == '后天卦').toList();

  int get xiantianYuantangYaoIndex => _model?.yuantangYaoIndex ?? 0;

  int get houtianYuantangYaoIndex => _model?.houtianYuantangYaoIndex ?? 0;

  List<YuanTangDayunPeriod> get xiantianDayunList =>
      _model?.xiantianDayunList ?? [];

  List<YuanTangDayunPeriod> get houtianDayunList =>
      _model?.houtianDayunList ?? [];

  void initialize({
    required YuanTangBaseNumberModel model,
    required int birthYear,
    required BuildContext context,
  }) {
    _model = model;
    _birthYear = birthYear;
    _strategy = context.read<YuanTangStrategy>();
    _allLiunianList = _strategy!.calculateAllLiunianGua(model, birthYear);

    if (_allLiunianList.isNotEmpty) {
      final defaultLiunian = _allLiunianList.firstWhere(
        (g) => g.guaSource == '先天卦',
        orElse: () => _allLiunianList.first,
      );
      selectLiunianAge(defaultLiunian.age);
    }

    notifyListeners();
  }

  List<YuanTangLiuyueGua>? getLiuyueForAge(int age) => _liuyueCache[age];

  void selectLiunianAge(int age) {
    if (_selectedLiunianAge == age) {
      _selectedLiunianAge = null;
      notifyListeners();
      return;
    }

    if (!_liuyueCache.containsKey(age) && _strategy != null) {
      final liunianGua = _allLiunianList.firstWhere(
        (g) => g.age == age,
        orElse: () => _allLiunianList.first,
      );
      final yuantangYaoIndex = liunianGua.guaSource == '先天卦'
          ? (_model?.yuantangYaoIndex ?? 0)
          : (_model?.houtianYuantangYaoIndex ?? 0);

      final liuyueList = _strategy!.calculateLiuyueForAge(
        age,
        liunianGua.gua,
        yuantangYaoIndex,
      );
      _liuyueCache[age] = liuyueList;
    }

    _selectedLiunianAge = age;
    notifyListeners();
  }

  void deselectLiunianAge() {
    _selectedLiunianAge = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _model = null;
    _birthYear = null;
    _strategy = null;
    _allLiunianList.clear();
    _liuyueCache.clear();
    super.dispose();
  }
}
