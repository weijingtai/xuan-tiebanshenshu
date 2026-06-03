import 'package:metaphysics_core/models/datetime_details_bundle_logic_model.dart';
import 'package:flutter/foundation.dart';

class DateTimeProvider extends ChangeNotifier {
  DateTimeDetailsBundleLogicModel? _currentDateTimeBundle;

  DateTimeDetailsBundleLogicModel? get currentDateTimeBundle => _currentDateTimeBundle;

  void updateDateTime(DateTimeDetailsBundleLogicModel bundle) {
    _currentDateTimeBundle = bundle;
    notifyListeners();
  }

  void clearDateTime() {
    _currentDateTimeBundle = null;
    notifyListeners();
  }

  bool get hasDateTime => _currentDateTimeBundle != null;
}
