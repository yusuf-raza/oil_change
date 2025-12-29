import 'package:flutter/foundation.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/enums.dart';
import '../models/oil_state.dart';
import '../services/notification_service.dart';
import '../services/oil_repository.dart';
import '../services/oil_storage.dart';

class OilViewModel extends ChangeNotifier {
  OilViewModel(this._notifications, this._repository);

  final NotificationService _notifications;
  final OilRepository _repository;

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isSaving = false;
  OilState _state = const OilState();
  int? _lastNotifiedDueMileage;
  int? _lastNotifiedThreshold;
  OilUnit _unit = OilUnit.kilometers;
  AppThemeMode _themeMode = AppThemeMode.light;
  bool _notificationsEnabled = true;
  String? _lastError;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  int? get currentMileage => _state.currentMileage;
  int? get intervalKm => _state.intervalKm;
  int? get lastChangeMileage => _state.lastChangeMileage;
  OilUnit get unit => _unit;
  AppThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String? get lastError => _lastError;

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

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _repository.fetchState();
      final current = _readInt(data, OilStorageKeys.currentMileage);
      final interval = _readInt(data, OilStorageKeys.intervalKm);
      final lastChange = _readInt(data, OilStorageKeys.lastChangeMileage);
      _lastNotifiedDueMileage =
          _readInt(data, OilStorageKeys.lastNotifiedDueMileage);
      _lastNotifiedThreshold =
          _readInt(data, OilStorageKeys.lastNotifiedThreshold);
      _unit = _readUnit(_readString(data, OilStorageKeys.unit));
      _themeMode = _readThemeMode(_readString(data, OilStorageKeys.themeMode));
      _notificationsEnabled =
          _readBool(data, OilStorageKeys.notificationsEnabled) ?? true;

      _state = _state.copyWith(
        currentMileage: current,
        intervalKm: interval,
        lastChangeMileage: lastChange ?? current,
      );
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _isLoading = false;
    }

    await _notifications.initialize();
    await _notifications.requestPermissions();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateCurrentMileage(int value) async {
    _state = _state.copyWith(currentMileage: value);
    await _safePersist();
    await _safeNotify();
    notifyListeners();
  }

  Future<void> updateIntervalKm(int value) async {
    _state = _state.copyWith(intervalKm: value);
    await _safePersist();
    await _safeNotify();
    notifyListeners();
  }

  Future<void> updateLastChangeMileage(int value) async {
    _state = _state.copyWith(lastChangeMileage: value);
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    await _safePersist();
    await _safeNotify();
    notifyListeners();
  }

  Future<void> markOilChanged() async {
    if (_state.currentMileage == null) {
      return;
    }
    _state = _state.copyWith(lastChangeMileage: _state.currentMileage);
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    await _safePersist();
    notifyListeners();
  }

  Future<void> resetAll() async {
    _state = const OilState();
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    _unit = OilUnit.kilometers;
    _themeMode = AppThemeMode.light;
    _notificationsEnabled = true;

    try {
      await _repository.clearState();
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    }

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
    await _safePersist();
    notifyListeners();
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    _themeMode = themeMode;
    await _safePersist();
    notifyListeners();
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _safePersist();
    notifyListeners();
  }

  Future<void> _safePersist() async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.saveState(
        OilRepository.buildUpdateMap(
          currentMileage: _state.currentMileage,
          intervalKm: _state.intervalKm,
          lastChangeMileage: _state.lastChangeMileage,
          lastNotifiedDueMileage: _lastNotifiedDueMileage,
          lastNotifiedThreshold: _lastNotifiedThreshold,
          unit: _unit.name,
          themeMode: _themeMode.name,
          notificationsEnabled: _notificationsEnabled,
        ),
      );
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _isSaving = false;
    }
  }

  Future<void> _safeNotify() async {
    try {
      await _maybeNotify();
    } catch (_) {
      // Notifications are best-effort; ignore failures.
    }
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
    await _safePersist();
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

  int? _readInt(Map<String, dynamic>? data, String key) {
    if (data == null || !data.containsKey(key)) {
      return null;
    }
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  String? _readString(Map<String, dynamic>? data, String key) {
    if (data == null || !data.containsKey(key)) {
      return null;
    }
    final value = data[key];
    return value is String ? value : null;
  }

  bool? _readBool(Map<String, dynamic>? data, String key) {
    if (data == null || !data.containsKey(key)) {
      return null;
    }
    final value = data[key];
    return value is bool ? value : null;
  }
}
