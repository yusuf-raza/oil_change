import 'dart:async';

import 'package:flutter/foundation.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/enums.dart';
import '../models/oil_change_entry.dart';
import '../models/oil_state.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/oil_repository.dart';
import '../services/oil_storage.dart';
import '../services/theme_storage.dart';

class OilViewModel extends ChangeNotifier {
  OilViewModel(
    this._notifications,
    this._repository, {
    ThemeStorage? themeStorage,
    AppThemeMode? initialThemeMode,
    DateTime Function()? nowProvider,
    LocationServiceBase? locationService,
  })  : _themeStorage = themeStorage ?? ThemeStorage(),
        _themeMode = initialThemeMode ?? AppThemeMode.light,
        _themeLoaded = initialThemeMode != null,
        _now = nowProvider ?? DateTime.now,
        _locationService = locationService ?? LocationService() {
    if (!_themeLoaded) {
      _loadThemeMode();
    }
  }

  final NotificationService _notifications;
  final OilRepositoryBase _repository;
  final ThemeStorage _themeStorage;
  final DateTime Function() _now;
  final LocationServiceBase _locationService;

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDisposed = false;
  Timer? _dailyNotifyTimer;
  bool _themeLoaded;
  OilState _state = const OilState();
  List<OilChangeEntry> _history = [];
  int? _lastNotifiedDueMileage;
  int? _lastNotifiedThreshold;
  int? _lastNotifiedDate;
  OilUnit _unit = OilUnit.kilometers;
  AppThemeMode _themeMode;
  int _notificationLeadKm = 50;
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
  int get notificationLeadKm => _notificationLeadKm;
  bool get notificationsEnabled => _notificationsEnabled;
  String? get lastError => _lastError;
  List<OilChangeEntry> get history => List.unmodifiable(_history);

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
    if (_isInitialized || _isLoading) {
      return;
    }

    _isLoading = true;
    _notifyListeners();

    try {
      final data = await _repository.fetchState();
      _applyLoadedData(data);
    } catch (error) {
      _lastError = error.toString();
    }

    await _notifications.initialize();
    await _notifications.requestPermissions();

    _isInitialized = true;
    _isLoading = false;
    _notifyListeners();

    // Check immediately and then daily while the app is open.
    await _safeNotify();
    _scheduleDailyNotify();
  }

  Future<void> refreshState() async {
    if (_isLoading) {
      return;
    }
    if (!_isInitialized) {
      await load();
      return;
    }
    _isLoading = true;
    _notifyListeners();
    try {
      final data = await _repository.fetchState();
      _applyLoadedData(data);
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  Future<void> updateCurrentMileage(int value) async {
    _state = _state.copyWith(currentMileage: value);
    await _safePersist();
    await _safeNotify();
    _notifyListeners();
  }

  Future<void> updateIntervalKm(int value) async {
    _state = _state.copyWith(intervalKm: value);
    await _safePersist();
    await _safeNotify();
    _notifyListeners();
  }

  Future<void> updateLastChangeMileage(int value) async {
    _state = _state.copyWith(lastChangeMileage: value);
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    _lastNotifiedDate = null;
    await _safePersist();
    await _safeNotify();
    _notifyListeners();
  }

  Future<void> markOilChanged() async {
    if (_state.currentMileage == null) {
      return;
    }
    String? location;
    try {
      location = await _locationService.getLocationLabel();
    } catch (_) {
      location = null;
    }
    _state = _state.copyWith(lastChangeMileage: _state.currentMileage);
    _history = [
      OilChangeEntry(
        date: _now(),
        mileage: _state.currentMileage!,
        location: location,
      ),
      ..._history,
    ];
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    _lastNotifiedDate = null;
    await _safePersist();
    _notifyListeners();
  }

  Future<void> resetAll() async {
    _state = const OilState();
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    _lastNotifiedDate = null;
    _unit = OilUnit.kilometers;
    _notificationLeadKm = 50;
    _notificationsEnabled = true;
    _history = [];

    try {
      await _repository.clearState();
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    }

    _notifyListeners();
  }

  Future<void> clearHistory() async {
    _history = [];
    await _safePersist();
    _notifyListeners();
  }

  Future<void> deleteHistoryAt(int index) async {
    if (index < 0 || index >= _history.length) {
      return;
    }
    _history.removeAt(index);
    await _safePersist();
    _notifyListeners();
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
    _history = _history
        .map(
          (entry) => OilChangeEntry(
            date: entry.date,
            mileage: _convertMileage(entry.mileage, unit) ?? entry.mileage,
            location: entry.location,
          ),
        )
        .toList();
    _lastNotifiedDueMileage = null;
    _lastNotifiedThreshold = null;
    _unit = unit;
    await _safePersist();
    _notifyListeners();
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    if (themeMode == _themeMode) {
      return;
    }
    _themeLoaded = true;
    _themeMode = themeMode;
    _notifyListeners();
    try {
      await _themeStorage.writeThemeMode(themeMode);
    } catch (_) {
      // Local storage failure should not block UI.
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _safePersist();
    _notifyListeners();
  }

  Future<void> updateNotificationLeadKm(int value) async {
    if (value == _notificationLeadKm) {
      return;
    }
    _notificationLeadKm = value;
    _lastNotifiedThreshold = null;
    _lastNotifiedDate = null;
    await _safePersist();
    _notifyListeners();
  }

  Future<void> _safePersist() async {
    _isSaving = true;
    _notifyListeners();
    try {
      await _repository.saveState(
        OilRepository.buildUpdateMap(
          currentMileage: _state.currentMileage,
          intervalKm: _state.intervalKm,
          lastChangeMileage: _state.lastChangeMileage,
          lastNotifiedDueMileage: _lastNotifiedDueMileage,
          lastNotifiedThreshold: _lastNotifiedThreshold,
          lastNotifiedDate: _lastNotifiedDate,
          unit: _unit.name,
          notificationLeadKm: _notificationLeadKm,
          notificationsEnabled: _notificationsEnabled,
          oilChangeHistory:
              _history.map((entry) => entry.toMap()).toList(),
        ),
      );
      _lastError = null;
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _isSaving = false;
      _notifyListeners();
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
    if (!_isNotificationHour()) {
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
      _lastNotifiedDate = null;
    }

    final current = _state.currentMileage!;
    final remaining = dueMileage - current;
    final remainingDisplay = remaining < 0 ? 0 : remaining;
    final unit = unitLabel;

    int? threshold;
    String? title;
    String? body;
    int? color;

    // Only emit the most urgent applicable notification.
    if (remaining <= 0) {
      threshold = 0;
      title = AppStrings.notificationDueTitle;
      body = 'Remaining: $remainingDisplay $unit.';
      color = AppColors.danger;
    } else if (remaining <= _notificationLeadKm) {
      threshold = _notificationLeadKm;
      title = AppStrings.notificationSoonTitle;
      body = 'Remaining: $remainingDisplay $unit.';
      color = AppColors.warning;
    }

    if (threshold == null || color == null) {
      return;
    }

    final today = _todayStamp();
    if (_lastNotifiedDueMileage == dueMileage &&
        _lastNotifiedThreshold == threshold &&
        _lastNotifiedDate == today) {
      return;
    }

    await _notifications.showReminderNotification(
      title: title!,
      body: body!,
      color: color,
    );
    _lastNotifiedDueMileage = dueMileage;
    _lastNotifiedThreshold = threshold;
    _lastNotifiedDate = today;
    await _safePersist();
  }

  OilUnit _readUnit(String? stored) {
    if (stored == OilUnit.miles.name) {
      return OilUnit.miles;
    }
    return OilUnit.kilometers;
  }

  Future<void> _loadThemeMode() async {
    if (_themeLoaded) {
      return;
    }
    try {
      final stored = await _themeStorage.readThemeMode();
      if (_themeLoaded) {
        return;
      }
      if (stored != null && stored != _themeMode) {
        _themeMode = stored;
        _notifyListeners();
      }
    } catch (_) {
      // Local storage failure should not block UI.
    } finally {
      _themeLoaded = true;
    }
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

  void _applyLoadedData(Map<String, dynamic>? data) {
    final current = _readInt(data, OilStorageKeys.currentMileage);
    final interval = _readInt(data, OilStorageKeys.intervalKm);
    final lastChange = _readInt(data, OilStorageKeys.lastChangeMileage);
    _lastNotifiedDueMileage =
        _readInt(data, OilStorageKeys.lastNotifiedDueMileage);
    _lastNotifiedThreshold =
        _readInt(data, OilStorageKeys.lastNotifiedThreshold);
    _lastNotifiedDate = _readInt(data, OilStorageKeys.lastNotifiedDate);
    _unit = _readUnit(_readString(data, OilStorageKeys.unit));
    _notificationLeadKm =
        _readInt(data, OilStorageKeys.notificationLeadKm) ?? 50;
    _notificationsEnabled =
        _readBool(data, OilStorageKeys.notificationsEnabled) ?? true;
    _history = _readHistory(data);

    _state = _state.copyWith(
      currentMileage: current,
      intervalKm: interval,
      lastChangeMileage: lastChange ?? current,
    );
    _lastError = null;
  }

  List<OilChangeEntry> _readHistory(Map<String, dynamic>? data) {
    if (data == null || !data.containsKey(OilStorageKeys.oilChangeHistory)) {
      return [];
    }
    final raw = data[OilStorageKeys.oilChangeHistory];
    if (raw is! List) {
      return [];
    }
    final entries = <OilChangeEntry>[];
    for (final item in raw) {
      if (item is Map) {
        final entry = OilChangeEntry.fromMap(
          Map<String, dynamic>.from(item),
        );
        if (entry != null) {
          entries.add(entry);
        }
      }
    }
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  int _todayStamp() {
    final now = _now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  bool _isNotificationHour() {
    // Limit daily reminders to 10am local time.
    return _now().hour == 10;
  }

  void _notifyListeners() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  void _scheduleDailyNotify() {
    _dailyNotifyTimer?.cancel();
    final now = _now();
    var next = DateTime(now.year, now.month, now.day, 10);
    if (!now.isBefore(next)) {
      next = next.add(const Duration(days: 1));
    }
    final initialDelay = next.difference(now);
    _dailyNotifyTimer = Timer(initialDelay, () {
      _safeNotify();
      _dailyNotifyTimer = Timer.periodic(
        const Duration(hours: 24),
        (_) => _safeNotify(),
      );
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _dailyNotifyTimer?.cancel();
    super.dispose();
  }
}
