import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class OilStateTable extends Table {
  TextColumn get id => text()();
  TextColumn get dataJson => text().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TourListTable extends Table {
  TextColumn get id => text()();
  TextColumn get dataJson => text().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TourDraftTable extends Table {
  TextColumn get id => text()();
  TextColumn get dataJson => text().nullable()();
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [OilStateTable, TourListTable, TourDraftTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(tourDraftTable);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return driftDatabase(name: 'oil_change');
  });
}

Map<String, dynamic>? decodeJson(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final decoded = jsonDecode(raw);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  if (decoded is Map) {
    return Map<String, dynamic>.from(decoded);
  }
  return null;
}

List<Map<String, dynamic>> decodeJsonList(String? raw) {
  if (raw == null || raw.isEmpty) {
    return [];
  }
  final decoded = jsonDecode(raw);
  if (decoded is List) {
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  return [];
}
