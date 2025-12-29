import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/enums.dart';
import '../models/oil_state.dart';
import '../services/notification_service.dart';
import '../services/oil_storage.dart';

class OilViewModel extends ChangeNotifier {
  OilViewModel(this._notifications);

  final NotificationService _notifications;

  bool _isInitialized = false;
  OilState _state = const OilState();
  int? _lastNotifiedDueMileage;
  int? _lastNotifiedThreshold;
  OilUnit _unit = OilUnit.kilometers;
  AppThemeMode _themeMode = AppThemeMode.light;
  bool _notificationsEnabled = true;

  bool get isInitialized => _isInitialized;
  int? get currentMileage => _state.currentMileage;
  int? get intervalKm => _state.intervalKm;
  int? get lastChangeMileage => _state.lastChangeMileage;
  OilUnit get unit => _unit;
  AppThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;

  String get unitLabel => _unit == OilUnit.kilometers
      ? AppStrings.unitKmShort
      : AppStrings.unitMiShort;

  int? get nextDueMileage {
    if (_state.lastChangeMileage == null || _state.intervalKm == null) {
      return null;
    }
    return _state.lastChangeMileage! + _state.intervalKm!;
  }

  int? get remainingKm {
    if (nextDueMileage == null || _state.currentMileage == null) {
      return null;
    }
    return nextDueMileage! - _state.currentMileage!;
  }

  bool get isDue {
    final remaining = remainingKm;
    if (remaining == null) {
      return false;
    }
    return remaining <= 0;
  }

  Future<void> load() async {
    if (_isInitialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(OilStorageKeys.currentMileage);
    final interval = prefs.getInt(OilStorageKeys.intervalKm);
    final lastChange = prefs.getInt(OilStorageKeys.lastChangeMileage);
    _lastNotifiedDueMileage =
        prefs.getInt(OilStorageKeys.lastNotifiedDueMileage);
    _lastNotifiedThreshold =
        prefs.getInt(OilStorageKeys.lastNotifiedThreshold);
    _unit = _readUnit(prefs.getString(OilStorageKeys.unit));
    _themeMode = _readThemeMode(prefs.getString(OilStorageKeys.themeMode));
    _notificationsEnabled =
        prefs.getBool(OilStorageKeys.notificationsEnabled) ?? true;

    _state = _state.copyWith(
      currentMileage: current,
      intervalKm: interval,
      lastChangeMileage: lastChange ?? current,
    );

    // Ensure a baseline exists for due calculations.
    if (_state.lastChangeMileage != null) {
      await prefs.setInt(
        OilStorageKeys.lastChangeMileage,
        _state.lastChangeMileage!,
      );
    }

    await _notifications.initialize();
    await _notifications.requestPermissions();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateCurrentMileage(int value) async {
    _state = _state.copyWith(currentMileage: value);
    await _persist();
    await _maybeNotify();
    notifyListeners();
  }

  Future<void> updateIntervalKm(int value) async {
    _state = _state.copyWith(intervalKm: value);
    await _persist();
    await _maybeNotify();
    notifyListeners();
  }

  Future<void> updateLastChangeMileage(int value) async {
    _state = _state.copyWith(lastChangeMileage: value);
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    await _persist();
    await _maybeNotify();
    notifyListeners();
  }

  Future<void> markOilChanged() async {
    if (_state.currentMileage == null) {
      return;
    }
    _state = _state.copyWith(lastChangeMileage: _state.currentMileage);
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    await _persist();
    notifyListeners();
  }

  Future<void> resetAll() async {
    _state = const OilState();
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    _unit = OilUnit.kilometers;
    _themeMode = AppThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(OilStorageKeys.currentMileage);
    await prefs.remove(OilStorageKeys.intervalKm);
    await prefs.remove(OilStorageKeys.lastChangeMileage);
    await prefs.remove(OilStorageKeys.lastNotifiedDueMileage);
    await prefs.remove(OilStorageKeys.lastNotifiedThreshold);
    await prefs.remove(OilStorageKeys.unit);
    await prefs.remove(OilStorageKeys.themeMode);

    notifyListeners();
  }

  Future<void> updateUnit(OilUnit unit) async {
    if (unit == _unit) {
      return;
    }
    // Convert stored values when switching units to keep derived metrics stable.
    _state = _state.copyWith(
      currentMileage: _convertMileage(_state.currentMileage, unit),
      intervalKm: _convertMileage(_state.intervalKm, unit),
      lastChangeMileage: _convertMileage(_state.lastChangeMileage, unit),
    );
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    _unit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OilStorageKeys.unit, unit.name);
    await _persist();
    notifyListeners();
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    _themeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OilStorageKeys.themeMode, themeMode.name);
    notifyListeners();
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OilStorageKeys.notificationsEnabled, enabled);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_state.currentMileage != null) {
      await prefs.setInt(
        OilStorageKeys.currentMileage,
        _state.currentMileage!,
      );
    }
    if (_state.intervalKm != null) {
      await prefs.setInt(OilStorageKeys.intervalKm, _state.intervalKm!);
    }
    if (_state.lastChangeMileage != null) {
      await prefs.setInt(
        OilStorageKeys.lastChangeMileage,
        _state.lastChangeMileage!,
      );
    }
    if (_lastNotifiedDueMileage != null) {
      await prefs.setInt(
        OilStorageKeys.lastNotifiedDueMileage,
        _lastNotifiedDueMileage!,
      );
    }
    if (_lastNotifiedThreshold != null) {
      await prefs.setInt(
        OilStorageKeys.lastNotifiedThreshold,
        _lastNotifiedThreshold!,
      );
    }
    await prefs.setBool(
      OilStorageKeys.notificationsEnabled,
      _notificationsEnabled,
    );
  }

  Future<void> _maybeNotify() async {
    if (!_notificationsEnabled) {
      return;
    }
    final dueMileage = nextDueMileage;
    if (dueMileage == null || _state.currentMileage == null) {
      return;
    }

    // Reset thresholds when a new oil change cycle begins.
    if (_lastNotifiedDueMileage != null &&
        _lastNotifiedDueMileage != dueMileage) {
      _lastNotifiedThreshold = null;
    }

    final current = _state.currentMileage!;
    final remaining = dueMileage - current;
    final unit = unitLabel;

    int? threshold;
    String? title;
    String? body;
    int? color;

    // Only emit the most urgent applicable notification.
    if (remaining <= 0) {
      threshold = 0;
      title = AppStrings.notificationDueTitle;
      body =
          '${AppStrings.notificationDueBody} ${_state.intervalKm} $unit.';
      color = AppColors.danger;
    } else if (remaining <= 50) {
      threshold = 50;
      title = AppStrings.notificationSoonTitle;
      body = '${AppStrings.notificationSoonBody50} $unit ${AppStrings.notificationSoonSuffix}';
      color = AppColors.warning;
    } else if (remaining <= 100) {
      threshold = 100;
      title = AppStrings.notificationSoonTitle;
      body = '${AppStrings.notificationSoonBody100} $unit ${AppStrings.notificationSoonSuffix}';
      color = AppColors.warning;
    } else if (remaining <= 150) {
      threshold = 150;
      title = AppStrings.notificationSoonTitle;
      body = '${AppStrings.notificationSoonBody150} $unit ${AppStrings.notificationSoonSuffix}';
      color = AppColors.warning;
    }

    if (threshold == null || color == null) {
      return;
    }

    if (_lastNotifiedDueMileage == dueMileage &&
        _lastNotifiedThreshold == threshold) {
      return;
    }

    await _notifications.showReminderNotification(
      title: title!,
      body: body!,
      color: color,
    );
    _lastNotifiedDueMileage = dueMileage;
    _lastNotifiedThreshold = threshold;
    await _persist();
  }

  OilUnit _readUnit(String? stored) {
    if (stored == OilUnit.miles.name) {
      return OilUnit.miles;
    }
    return OilUnit.kilometers;
  }

  AppThemeMode _readThemeMode(String? stored) {
    if (stored == AppThemeMode.dark.name) {
      return AppThemeMode.dark;
    }
    return AppThemeMode.light;
  }

  int? _convertMileage(int? value, OilUnit targetUnit) {
    if (value == null) {
      return null;
    }
    final isToMiles = targetUnit == OilUnit.miles;
    final factor = 0.621371;
    final converted = isToMiles ? value * factor : value / factor;
    return converted.round();
  }
}
