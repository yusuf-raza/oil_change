import 'package:flutter/foundation.dart';

import 'app_logger.dart';
import 'offline_oil_repository.dart';
import 'offline_tour_repository.dart';

class OfflineSyncService extends ChangeNotifier {
  OfflineSyncService({
    required OfflineOilRepository oilRepository,
    required OfflineTourRepository tourRepository,
  })  : _oilRepository = oilRepository,
        _tourRepository = tourRepository;

  final OfflineOilRepository _oilRepository;
  final OfflineTourRepository _tourRepository;
  final _logger = AppLogger.logger;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  String? _lastError;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;
  String? get lastError => _lastError;

  Future<void> syncAll() async {
    // Best-effort sync for offline-first repositories.
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;
    _lastError = null;
    notifyListeners();
    _logger.i('OfflineSyncService.syncAll: start sync');
    try {
      await _oilRepository.syncPending();
      await _tourRepository.syncPending();
      _lastSyncAt = DateTime.now();
      _logger.i('OfflineSyncService.syncAll: finish sync');
    } catch (error) {
      _lastError = error.toString();
      _logger.i('OfflineSyncService.syncAll: sync failed');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
