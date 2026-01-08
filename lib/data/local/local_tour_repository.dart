import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/tour_entry.dart';
import '../../services/app_logger.dart';
import '../../services/tour_repository.dart';
import 'app_database.dart';

class LocalTourRepository implements TourRepositoryBase {
  LocalTourRepository(this._db);

  final AppDatabase _db;
  static const _rowId = 'tours';
  final _logger = AppLogger.logger;

  @override
  Future<List<TourEntry>> fetchTours() async {
    _logger.i('LocalTourRepository.fetchTours: read local tours');
    final row = await (_db.select(_db.tourListTable)
          ..where((tbl) => tbl.id.equals(_rowId)))
        .getSingleOrNull();
    final raw = decodeJsonList(row?.dataJson);
    final entries = <TourEntry>[];
    for (final item in raw) {
      final id = item['id']?.toString() ?? '';
      final entry = TourEntry.fromMap(id, item);
      if (entry != null) {
        entries.add(entry);
      }
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  @override
  Future<TourEntry> saveTour(TourEntry entry) async {
    _logger.i('LocalTourRepository.saveTour: write local tour');
    final existing = await _readToursRaw();
    final id =
        entry.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : entry.id;
    final payload = {
      ...entry.toMap(),
      'id': id,
    };
    existing.insert(0, payload);
    await _saveToursRaw(existing, dirty: true);
    return TourEntry(
      id: id,
      createdAt: entry.createdAt,
      title: entry.title,
      unit: entry.unit,
      startMileage: entry.startMileage,
      endMileage: entry.endMileage,
      distanceKm: entry.distanceKm,
      totalLiters: entry.totalLiters,
      totalSpendPkr: entry.totalSpendPkr,
      stops: entry.stops,
    );
  }

  @override
  Future<void> deleteTour(String id) async {
    _logger.i('LocalTourRepository.deleteTour: delete local tour id=$id');
    final existing = await _readToursRaw();
    existing.removeWhere((item) => item['id']?.toString() == id);
    await _saveToursRaw(existing, dirty: true);
  }

  Future<void> replaceTours(List<TourEntry> entries) async {
    _logger.i('LocalTourRepository.replaceTours: replace local tours list');
    final payload = entries
        .map((entry) => {
              ...entry.toMap(),
              'id': entry.id,
            })
        .toList();
    await _saveToursRaw(payload, dirty: false);
  }

  Future<LocalTourSyncState?> getPendingSync() async {
    _logger.i('LocalTourRepository.getPendingSync: read pending sync list');
    final row = await (_db.select(_db.tourListTable)
          ..where((tbl) => tbl.id.equals(_rowId)))
        .getSingleOrNull();
    if (row == null || !row.dirty) {
      return null;
    }
    return LocalTourSyncState(
      data: decodeJsonList(row.dataJson),
    );
  }

  Future<void> markSynced() async {
    _logger.i('LocalTourRepository.markSynced: clear dirty flag');
    await _db.into(_db.tourListTable).insertOnConflictUpdate(
          TourListTableCompanion(
            id: const Value(_rowId),
            dirty: const Value(false),
          ),
        );
  }

  Future<List<Map<String, dynamic>>> _readToursRaw() async {
    _logger.i('LocalTourRepository._readToursRaw: read raw tour list');
    final row = await (_db.select(_db.tourListTable)
          ..where((tbl) => tbl.id.equals(_rowId)))
        .getSingleOrNull();
    return decodeJsonList(row?.dataJson);
  }

  Future<void> _saveToursRaw(
    List<Map<String, dynamic>> payload, {
    required bool dirty,
  }) async {
    _logger.i('LocalTourRepository._saveToursRaw: write raw tour list dirty=$dirty');
    await _db.into(_db.tourListTable).insertOnConflictUpdate(
          TourListTableCompanion(
            id: const Value(_rowId),
            dataJson: Value(jsonEncode(payload)),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
            dirty: Value(dirty),
          ),
        );
  }
}

class LocalTourSyncState {
  const LocalTourSyncState({required this.data});

  final List<Map<String, dynamic>> data;
}
