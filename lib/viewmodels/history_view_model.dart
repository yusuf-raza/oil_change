import 'package:flutter/foundation.dart';

import '../constants/app_strings.dart';
import '../models/oil_change_entry.dart';
import 'oil_view_model.dart';

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel(this._oilViewModel) {
    _oilViewModel.addListener(_onOilUpdated);
  }

  final OilViewModel _oilViewModel;
  bool _isRefreshing = false;
  String? _lastError;

  List<OilChangeEntry> get history => _oilViewModel.history;
  String get unitLabel => _oilViewModel.unitLabel;
  bool get hasHistory => history.isNotEmpty;
  bool get isRefreshing => _isRefreshing;
  String? get lastError => _lastError;

  String locationLabelFor(OilChangeEntry entry) {
    return entry.location ?? AppStrings.historyLocationUnknown;
  }

  int? intervalFor(int index) {
    if (index + 1 >= history.length) {
      return null;
    }
    final current = history[index];
    final previous = history[index + 1];
    return (current.mileage - previous.mileage).abs();
  }

  Future<void> clearHistory() async {
    await _oilViewModel.clearHistory();
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    _lastError = null;
    notifyListeners();
    await _oilViewModel.refreshState();
    _lastError = _oilViewModel.lastError;
    _isRefreshing = false;
    notifyListeners();
  }

  void _onOilUpdated() {
    notifyListeners();
  }

  @override
  void dispose() {
    _oilViewModel.removeListener(_onOilUpdated);
    super.dispose();
  }
}
