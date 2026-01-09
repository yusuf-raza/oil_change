import 'dart:async';

import '../data/local/local_tour_repository.dart';
import '../models/tour_entry.dart';
import 'app_logger.dart';
import 'tour_repository.dart';

class OfflineTourRepository implements TourRepositoryBase {
  OfflineTourRepository(this._local, this._remote);

  final LocalTourRepository _local;
  final TourRepository _remote;
  final _logger = AppLogger.logger;

  @override
  Future<List<TourEntry>> fetchTours() async {
    // Prefer local cache; seed from remote when empty.
    _logger.i('OfflineTourRepository.fetchTours: read local, fallback remote');
    final local = await _local.fetchTours();
    if (local.isNotEmpty) {
      return local;
    }
    try {
      _logger.i('OfflineTourRepository.fetchTours: fetch remote tours');
      final remote = await _remote.fetchTours();
      await _local.replaceTours(remote);
      return remote;
    } catch (_) {
      _logger.i('OfflineTourRepository.fetchTours: remote fetch failed');
      return local;
    }
  }

  @override
  Future<TourEntry> saveTour(TourEntry entry) async {
    // Always persist locally first, then try remote sync.
    _logger.i('OfflineTourRepository.saveTour: write local tour');
    final seeded = entry.id.isEmpty
        ? TourEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            createdAt: entry.createdAt,
            title: entry.title,
            unit: entry.unit,
            startMileage: entry.startMileage,
            endMileage: entry.endMileage,
            distanceKm: entry.distanceKm,
            totalLiters: entry.totalLiters,
            totalSpendPkr: entry.totalSpendPkr,
            stops: entry.stops,
            expenses: entry.expenses,
            startAt: entry.startAt,
            endAt: entry.endAt,
          )
        : entry;
    final saved = await _local.saveTour(seeded);
    unawaited(_pushRemoteSave(saved));
    return saved;
  }

  @override
  Future<TourEntry> updateTour(TourEntry entry) async {
    _logger.i('OfflineTourRepository.updateTour: update local tour id=${entry.id}');
    final saved = await _local.updateTour(entry);
    unawaited(_pushRemoteUpdate(saved));
    return saved;
  }

  @override
  Future<void> deleteTour(String id) async {
    // Delete locally first, then attempt remote delete.
    _logger.i('OfflineTourRepository.deleteTour: delete local tour id=$id');
    await _local.deleteTour(id);
    unawaited(_pushRemoteDelete(id));
  }

  Future<void> syncPending() async {
    // Push any pending local changes to Firestore.
    _logger.i('OfflineTourRepository.syncPending: sync dirty tours');
    final pending = await _local.getPendingSync();
    if (pending == null) {
      _logger.i('OfflineTourRepository.syncPending: no pending changes');
      return;
    }
    try {
      _logger.i('OfflineTourRepository.syncPending: replace remote tours');
      await _remote
          .replaceTours(pending.data)
          .timeout(const Duration(seconds: 5));
      await _local.markSynced();
    } catch (_) {
      _logger.i('OfflineTourRepository.syncPending: push failed');
      // Leave dirty flags intact.
    }
  }

  Future<void> _pushRemoteSave(TourEntry entry) async {
    try {
      _logger.i('OfflineTourRepository._pushRemoteSave: push to remote');
      await _remote.saveTour(entry).timeout(const Duration(seconds: 5));
      await _local.markSynced();
    } catch (_) {
      _logger.i('OfflineTourRepository._pushRemoteSave: remote push failed');
      // Keep local dirty for later sync.
    }
  }

  Future<void> _pushRemoteDelete(String id) async {
    try {
      _logger.i('OfflineTourRepository._pushRemoteDelete: delete remote tour id=$id');
      await _remote.deleteTour(id).timeout(const Duration(seconds: 5));
      await _local.markSynced();
    } catch (_) {
      _logger.i('OfflineTourRepository._pushRemoteDelete: remote delete failed');
      // Keep local dirty for later sync.
    }
  }

  Future<void> _pushRemoteUpdate(TourEntry entry) async {
    try {
      _logger.i('OfflineTourRepository._pushRemoteUpdate: push to remote');
      await _remote.updateTour(entry).timeout(const Duration(seconds: 5));
      await _local.markSynced();
    } catch (_) {
      _logger.i('OfflineTourRepository._pushRemoteUpdate: remote push failed');
      // Keep local dirty for later sync.
    }
  }
}
