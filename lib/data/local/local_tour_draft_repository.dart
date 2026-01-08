import 'dart:convert';

import 'package:drift/drift.dart';

import '../../services/app_logger.dart';
import 'app_database.dart';

class LocalTourDraftRepository {
  LocalTourDraftRepository(this._db);

  final AppDatabase _db;
  final _logger = AppLogger.logger;
  static const _rowId = 'draft';

  Future<Map<String, dynamic>?> fetchDraft() async {
    _logger.i('LocalTourDraftRepository.fetchDraft: read draft');
    final row = await (_db.select(_db.tourDraftTable)
          ..where((tbl) => tbl.id.equals(_rowId)))
        .getSingleOrNull();
    return decodeJson(row?.dataJson);
  }

  Future<void> saveDraft(Map<String, dynamic> data) async {
    _logger.i('LocalTourDraftRepository.saveDraft: write draft');
    await _db.into(_db.tourDraftTable).insertOnConflictUpdate(
          TourDraftTableCompanion(
            id: const Value(_rowId),
            dataJson: Value(jsonEncode(data)),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<void> clearDraft() async {
    _logger.i('LocalTourDraftRepository.clearDraft: clear draft');
    await (_db.delete(_db.tourDraftTable)
          ..where((tbl) => tbl.id.equals(_rowId)))
        .go();
  }
}
