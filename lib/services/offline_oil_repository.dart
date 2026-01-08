import 'dart:async';

import '../data/local/local_oil_repository.dart';
import 'app_logger.dart';
import 'oil_repository.dart';

class OfflineOilRepository implements OilRepositoryBase {
  OfflineOilRepository(this._local, this._remote);

  final LocalOilRepository _local;
  final OilRepositoryBase _remote;
  final _logger = AppLogger.logger;

  @override
  Future<Map<String, dynamic>?> fetchState() async {
    // Prefer local cache; seed from remote when empty.
    _logger.i('OfflineOilRepository.fetchState: read local, fallback remote');
    final local = await _local.fetchState();
    if (local != null) {
      return local;
    }
    try {
      _logger.i('OfflineOilRepository.fetchState: fetch remote state');
      final remote = await _remote.fetchState();
      await _local.replaceState(remote);
      return remote;
    } catch (_) {
      _logger.i('OfflineOilRepository.fetchState: remote fetch failed');
      return local;
    }
  }

  @override
  Future<void> saveState(Map<String, dynamic> data) async {
    // Always persist locally first, then try remote sync.
    _logger.i('OfflineOilRepository.saveState: write local state');
    await _local.saveState(data);
    unawaited(_pushRemoteState(data));
  }

  @override
  Future<void> clearState() async {
    // Clear locally first, then attempt remote delete.
    _logger.i('OfflineOilRepository.clearState: clear local state');
    await _local.clearState();
    unawaited(_pushRemoteClear());
  }

  Future<void> syncPending() async {
    // Push any pending local changes to Firestore.
    _logger.i('OfflineOilRepository.syncPending: sync dirty state');
    final pending = await _local.getPendingSync();
    if (pending == null) {
      _logger.i('OfflineOilRepository.syncPending: no pending changes');
      return;
    }
    try {
      if (pending.deleted) {
        _logger.i('OfflineOilRepository.syncPending: push delete');
        await _remote.clearState().timeout(const Duration(seconds: 5));
        await _local.markSyncedClear();
      } else if (pending.data != null) {
        _logger.i('OfflineOilRepository.syncPending: push update');
        await _remote
            .saveState(pending.data!)
            .timeout(const Duration(seconds: 5));
        await _local.markSynced();
      }
    } catch (_) {
      _logger.i('OfflineOilRepository.syncPending: push failed');
      // Leave dirty flags intact.
    }
  }

  Future<void> _pushRemoteState(Map<String, dynamic> data) async {
    try {
      _logger.i('OfflineOilRepository._pushRemoteState: push to remote');
      await _remote.saveState(data).timeout(const Duration(seconds: 5));
      await _local.markSynced();
    } catch (_) {
      _logger.i('OfflineOilRepository._pushRemoteState: remote push failed');
      // Keep local dirty for later sync.
    }
  }

  Future<void> _pushRemoteClear() async {
    try {
      _logger.i('OfflineOilRepository._pushRemoteClear: clear remote state');
      await _remote.clearState().timeout(const Duration(seconds: 5));
      await _local.markSyncedClear();
    } catch (_) {
      _logger.i('OfflineOilRepository._pushRemoteClear: remote clear failed');
      // Keep local dirty for later sync.
    }
  }
}
