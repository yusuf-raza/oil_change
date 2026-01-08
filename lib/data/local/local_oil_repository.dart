import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../services/app_logger.dart';
import '../../services/oil_repository.dart';
import 'app_database.dart';

class LocalOilRepository implements OilRepositoryBase {
  LocalOilRepository(this._db);

  final AppDatabase _db;
  static const _rowId = 'state';
  final _logger = AppLogger.logger;

  @override
  Future<Map<String, dynamic>?> fetchState() async {
    _logger.i('LocalOilRepository.fetchState: read local oil state');
    final row = await (_db.select(_db.oilStateTable)
          ..where((tbl) => tbl.id.equals(_rowId)))
        .getSingleOrNull();
    if (row == null || row.deleted) {
      return null;
    }
    return decodeJson(row.dataJson);
  }

  @override
  Future<void> saveState(Map<String, dynamic> data) async {
    _logger.i('LocalOilRepository.saveState: write local oil state');
    final existing = await fetchState();
    final merged = _mergeState(existing, data);
    await _db.into(_db.oilStateTable).insertOnConflictUpdate(
          OilStateTableCompanion(
            id: const Value(_rowId),
            dataJson: Value(jsonEncode(merged)),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
            dirty: const Value(true),
            deleted: const Value(false),
          ),
        );
  }

  @override
  Future<void> clearState() async {
    _logger.i('LocalOilRepository.clearState: delete local oil state');
    await _db.into(_db.oilStateTable).insertOnConflictUpdate(
          OilStateTableCompanion(
            id: const Value(_rowId),
            dataJson: const Value(null),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
            dirty: const Value(true),
            deleted: const Value(true),
          ),
        );
  }

  Future<void> replaceState(Map<String, dynamic>? data) async {
    _logger.i('LocalOilRepository.replaceState: replace local oil state');
    if (data == null) {
      await _db.into(_db.oilStateTable).insertOnConflictUpdate(
            OilStateTableCompanion(
              id: const Value(_rowId),
              dataJson: const Value(null),
              updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
              dirty: const Value(false),
              deleted: const Value(false),
            ),
          );
      return;
    }
    await _db.into(_db.oilStateTable).insertOnConflictUpdate(
          OilStateTableCompanion(
            id: const Value(_rowId),
            dataJson: Value(jsonEncode(data)),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
            dirty: const Value(false),
            deleted: const Value(false),
          ),
        );
  }

  Future<LocalOilSyncState?> getPendingSync() async {
    _logger.i('LocalOilRepository.getPendingSync: read pending sync state');
    final row = await (_db.select(_db.oilStateTable)
          ..where((tbl) => tbl.id.equals(_rowId)))
        .getSingleOrNull();
    if (row == null || !row.dirty) {
      return null;
    }
    return LocalOilSyncState(
      deleted: row.deleted,
      data: decodeJson(row.dataJson),
    );
  }

  Future<void> markSynced() async {
    _logger.i('LocalOilRepository.markSynced: clear dirty flag');
    await _db.into(_db.oilStateTable).insertOnConflictUpdate(
          OilStateTableCompanion(
            id: const Value(_rowId),
            dirty: const Value(false),
            deleted: const Value(false),
          ),
        );
  }

  Future<void> markSyncedClear() async {
    _logger.i('LocalOilRepository.markSyncedClear: clear dirty flag and data');
    await _db.into(_db.oilStateTable).insertOnConflictUpdate(
          OilStateTableCompanion(
            id: const Value(_rowId),
            dataJson: const Value(null),
            dirty: const Value(false),
            deleted: const Value(false),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Map<String, dynamic> _mergeState(
    Map<String, dynamic>? existing,
    Map<String, dynamic> updates,
  ) {
    // Mimic Firestore merge semantics, honoring FieldValue.delete.
    final merged = <String, dynamic>{};
    if (existing != null) {
      merged.addAll(existing);
    }
    updates.forEach((key, value) {
      if (value is FieldValue) {
        merged.remove(key);
      } else {
        merged[key] = value;
      }
    });
    return merged;
  }
}

class LocalOilSyncState {
  const LocalOilSyncState({
    required this.deleted,
    required this.data,
  });

  final bool deleted;
  final Map<String, dynamic>? data;
}
