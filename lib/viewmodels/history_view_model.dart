import 'package:flutter/material.dart';

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
  bool get canClearHistory => hasHistory;

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

  HistoryEntryDisplayData buildEntryDisplay(
    int index,
    MaterialLocalizations localizations,
  ) {
    final entry = history[index];
    final interval = intervalFor(index);
    final intervalText = interval == null
        ? AppStrings.historyIntervalUnknown
        : '$interval $unitLabel';
    final dateText = localizations.formatFullDate(entry.date);
    final timeText = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(entry.date),
    );
    return HistoryEntryDisplayData(
      mileageText: '${entry.mileage} $unitLabel',
      intervalText: intervalText,
      dateText: dateText,
      timeText: timeText,
      locationText: locationLabelFor(entry),
    );
  }

  Future<void> confirmClearHistory({
    required Future<bool?> Function() confirm,
  }) async {
    final confirmed = await confirm();
    if (confirmed != true) {
      return;
    }
    await clearHistory();
  }

  Future<void> clearHistory() async {
    await _oilViewModel.clearHistory();
  }

  Future<void> deleteEntry(int index) async {
    await _oilViewModel.deleteHistoryAt(index);
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

class HistoryEntryDisplayData {
  const HistoryEntryDisplayData({
    required this.mileageText,
    required this.intervalText,
    required this.dateText,
    required this.timeText,
    required this.locationText,
  });

  final String mileageText;
  final String intervalText;
  final String dateText;
  final String timeText;
  final String locationText;
}
