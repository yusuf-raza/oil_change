// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OilStateTableTable extends OilStateTable
    with TableInfo<$OilStateTableTable, OilStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OilStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dataJson,
    updatedAt,
    dirty,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'oil_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<OilStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OilStateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OilStateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $OilStateTableTable createAlias(String alias) {
    return $OilStateTableTable(attachedDatabase, alias);
  }
}

class OilStateTableData extends DataClass
    implements Insertable<OilStateTableData> {
  final String id;
  final String? dataJson;
  final int? updatedAt;
  final bool dirty;
  final bool deleted;
  const OilStateTableData({
    required this.id,
    this.dataJson,
    this.updatedAt,
    required this.dirty,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || dataJson != null) {
      map['data_json'] = Variable<String>(dataJson);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  OilStateTableCompanion toCompanion(bool nullToAbsent) {
    return OilStateTableCompanion(
      id: Value(id),
      dataJson: dataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dataJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      dirty: Value(dirty),
      deleted: Value(deleted),
    );
  }

  factory OilStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OilStateTableData(
      id: serializer.fromJson<String>(json['id']),
      dataJson: serializer.fromJson<String?>(json['dataJson']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dataJson': serializer.toJson<String?>(dataJson),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  OilStateTableData copyWith({
    String? id,
    Value<String?> dataJson = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
    bool? dirty,
    bool? deleted,
  }) => OilStateTableData(
    id: id ?? this.id,
    dataJson: dataJson.present ? dataJson.value : this.dataJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    dirty: dirty ?? this.dirty,
    deleted: deleted ?? this.deleted,
  );
  OilStateTableData copyWithCompanion(OilStateTableCompanion data) {
    return OilStateTableData(
      id: data.id.present ? data.id.value : this.id,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OilStateTableData(')
          ..write('id: $id, ')
          ..write('dataJson: $dataJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dataJson, updatedAt, dirty, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OilStateTableData &&
          other.id == this.id &&
          other.dataJson == this.dataJson &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.deleted == this.deleted);
}

class OilStateTableCompanion extends UpdateCompanion<OilStateTableData> {
  final Value<String> id;
  final Value<String?> dataJson;
  final Value<int?> updatedAt;
  final Value<bool> dirty;
  final Value<bool> deleted;
  final Value<int> rowid;
  const OilStateTableCompanion({
    this.id = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OilStateTableCompanion.insert({
    required String id,
    this.dataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<OilStateTableData> custom({
    Expression<String>? id,
    Expression<String>? dataJson,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dataJson != null) 'data_json': dataJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OilStateTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? dataJson,
    Value<int?>? updatedAt,
    Value<bool>? dirty,
    Value<bool>? deleted,
    Value<int>? rowid,
  }) {
    return OilStateTableCompanion(
      id: id ?? this.id,
      dataJson: dataJson ?? this.dataJson,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OilStateTableCompanion(')
          ..write('id: $id, ')
          ..write('dataJson: $dataJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TourListTableTable extends TourListTable
    with TableInfo<$TourListTableTable, TourListTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TourListTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, dataJson, updatedAt, dirty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tour_list_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TourListTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TourListTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TourListTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $TourListTableTable createAlias(String alias) {
    return $TourListTableTable(attachedDatabase, alias);
  }
}

class TourListTableData extends DataClass
    implements Insertable<TourListTableData> {
  final String id;
  final String? dataJson;
  final int? updatedAt;
  final bool dirty;
  const TourListTableData({
    required this.id,
    this.dataJson,
    this.updatedAt,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || dataJson != null) {
      map['data_json'] = Variable<String>(dataJson);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  TourListTableCompanion toCompanion(bool nullToAbsent) {
    return TourListTableCompanion(
      id: Value(id),
      dataJson: dataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dataJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      dirty: Value(dirty),
    );
  }

  factory TourListTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TourListTableData(
      id: serializer.fromJson<String>(json['id']),
      dataJson: serializer.fromJson<String?>(json['dataJson']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dataJson': serializer.toJson<String?>(dataJson),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  TourListTableData copyWith({
    String? id,
    Value<String?> dataJson = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
    bool? dirty,
  }) => TourListTableData(
    id: id ?? this.id,
    dataJson: dataJson.present ? dataJson.value : this.dataJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    dirty: dirty ?? this.dirty,
  );
  TourListTableData copyWithCompanion(TourListTableCompanion data) {
    return TourListTableData(
      id: data.id.present ? data.id.value : this.id,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TourListTableData(')
          ..write('id: $id, ')
          ..write('dataJson: $dataJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dataJson, updatedAt, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TourListTableData &&
          other.id == this.id &&
          other.dataJson == this.dataJson &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty);
}

class TourListTableCompanion extends UpdateCompanion<TourListTableData> {
  final Value<String> id;
  final Value<String?> dataJson;
  final Value<int?> updatedAt;
  final Value<bool> dirty;
  final Value<int> rowid;
  const TourListTableCompanion({
    this.id = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TourListTableCompanion.insert({
    required String id,
    this.dataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<TourListTableData> custom({
    Expression<String>? id,
    Expression<String>? dataJson,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dataJson != null) 'data_json': dataJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TourListTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? dataJson,
    Value<int?>? updatedAt,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return TourListTableCompanion(
      id: id ?? this.id,
      dataJson: dataJson ?? this.dataJson,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TourListTableCompanion(')
          ..write('id: $id, ')
          ..write('dataJson: $dataJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TourDraftTableTable extends TourDraftTable
    with TableInfo<$TourDraftTableTable, TourDraftTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TourDraftTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dataJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tour_draft_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TourDraftTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TourDraftTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TourDraftTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TourDraftTableTable createAlias(String alias) {
    return $TourDraftTableTable(attachedDatabase, alias);
  }
}

class TourDraftTableData extends DataClass
    implements Insertable<TourDraftTableData> {
  final String id;
  final String? dataJson;
  final int? updatedAt;
  const TourDraftTableData({required this.id, this.dataJson, this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || dataJson != null) {
      map['data_json'] = Variable<String>(dataJson);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  TourDraftTableCompanion toCompanion(bool nullToAbsent) {
    return TourDraftTableCompanion(
      id: Value(id),
      dataJson: dataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dataJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TourDraftTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TourDraftTableData(
      id: serializer.fromJson<String>(json['id']),
      dataJson: serializer.fromJson<String?>(json['dataJson']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dataJson': serializer.toJson<String?>(dataJson),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  TourDraftTableData copyWith({
    String? id,
    Value<String?> dataJson = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => TourDraftTableData(
    id: id ?? this.id,
    dataJson: dataJson.present ? dataJson.value : this.dataJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TourDraftTableData copyWithCompanion(TourDraftTableCompanion data) {
    return TourDraftTableData(
      id: data.id.present ? data.id.value : this.id,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TourDraftTableData(')
          ..write('id: $id, ')
          ..write('dataJson: $dataJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dataJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TourDraftTableData &&
          other.id == this.id &&
          other.dataJson == this.dataJson &&
          other.updatedAt == this.updatedAt);
}

class TourDraftTableCompanion extends UpdateCompanion<TourDraftTableData> {
  final Value<String> id;
  final Value<String?> dataJson;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const TourDraftTableCompanion({
    this.id = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TourDraftTableCompanion.insert({
    required String id,
    this.dataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<TourDraftTableData> custom({
    Expression<String>? id,
    Expression<String>? dataJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dataJson != null) 'data_json': dataJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TourDraftTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? dataJson,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return TourDraftTableCompanion(
      id: id ?? this.id,
      dataJson: dataJson ?? this.dataJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TourDraftTableCompanion(')
          ..write('id: $id, ')
          ..write('dataJson: $dataJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OilStateTableTable oilStateTable = $OilStateTableTable(this);
  late final $TourListTableTable tourListTable = $TourListTableTable(this);
  late final $TourDraftTableTable tourDraftTable = $TourDraftTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    oilStateTable,
    tourListTable,
    tourDraftTable,
  ];
}

typedef $$OilStateTableTableCreateCompanionBuilder =
    OilStateTableCompanion Function({
      required String id,
      Value<String?> dataJson,
      Value<int?> updatedAt,
      Value<bool> dirty,
      Value<bool> deleted,
      Value<int> rowid,
    });
typedef $$OilStateTableTableUpdateCompanionBuilder =
    OilStateTableCompanion Function({
      Value<String> id,
      Value<String?> dataJson,
      Value<int?> updatedAt,
      Value<bool> dirty,
      Value<bool> deleted,
      Value<int> rowid,
    });

class $$OilStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $OilStateTableTable> {
  $$OilStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OilStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OilStateTableTable> {
  $$OilStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OilStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OilStateTableTable> {
  $$OilStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$OilStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OilStateTableTable,
          OilStateTableData,
          $$OilStateTableTableFilterComposer,
          $$OilStateTableTableOrderingComposer,
          $$OilStateTableTableAnnotationComposer,
          $$OilStateTableTableCreateCompanionBuilder,
          $$OilStateTableTableUpdateCompanionBuilder,
          (
            OilStateTableData,
            BaseReferences<
              _$AppDatabase,
              $OilStateTableTable,
              OilStateTableData
            >,
          ),
          OilStateTableData,
          PrefetchHooks Function()
        > {
  $$OilStateTableTableTableManager(_$AppDatabase db, $OilStateTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OilStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OilStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OilStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> dataJson = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OilStateTableCompanion(
                id: id,
                dataJson: dataJson,
                updatedAt: updatedAt,
                dirty: dirty,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> dataJson = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OilStateTableCompanion.insert(
                id: id,
                dataJson: dataJson,
                updatedAt: updatedAt,
                dirty: dirty,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OilStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OilStateTableTable,
      OilStateTableData,
      $$OilStateTableTableFilterComposer,
      $$OilStateTableTableOrderingComposer,
      $$OilStateTableTableAnnotationComposer,
      $$OilStateTableTableCreateCompanionBuilder,
      $$OilStateTableTableUpdateCompanionBuilder,
      (
        OilStateTableData,
        BaseReferences<_$AppDatabase, $OilStateTableTable, OilStateTableData>,
      ),
      OilStateTableData,
      PrefetchHooks Function()
    >;
typedef $$TourListTableTableCreateCompanionBuilder =
    TourListTableCompanion Function({
      required String id,
      Value<String?> dataJson,
      Value<int?> updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });
typedef $$TourListTableTableUpdateCompanionBuilder =
    TourListTableCompanion Function({
      Value<String> id,
      Value<String?> dataJson,
      Value<int?> updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });

class $$TourListTableTableFilterComposer
    extends Composer<_$AppDatabase, $TourListTableTable> {
  $$TourListTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TourListTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TourListTableTable> {
  $$TourListTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TourListTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TourListTableTable> {
  $$TourListTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$TourListTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TourListTableTable,
          TourListTableData,
          $$TourListTableTableFilterComposer,
          $$TourListTableTableOrderingComposer,
          $$TourListTableTableAnnotationComposer,
          $$TourListTableTableCreateCompanionBuilder,
          $$TourListTableTableUpdateCompanionBuilder,
          (
            TourListTableData,
            BaseReferences<
              _$AppDatabase,
              $TourListTableTable,
              TourListTableData
            >,
          ),
          TourListTableData,
          PrefetchHooks Function()
        > {
  $$TourListTableTableTableManager(_$AppDatabase db, $TourListTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TourListTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TourListTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TourListTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> dataJson = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TourListTableCompanion(
                id: id,
                dataJson: dataJson,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> dataJson = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TourListTableCompanion.insert(
                id: id,
                dataJson: dataJson,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TourListTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TourListTableTable,
      TourListTableData,
      $$TourListTableTableFilterComposer,
      $$TourListTableTableOrderingComposer,
      $$TourListTableTableAnnotationComposer,
      $$TourListTableTableCreateCompanionBuilder,
      $$TourListTableTableUpdateCompanionBuilder,
      (
        TourListTableData,
        BaseReferences<_$AppDatabase, $TourListTableTable, TourListTableData>,
      ),
      TourListTableData,
      PrefetchHooks Function()
    >;
typedef $$TourDraftTableTableCreateCompanionBuilder =
    TourDraftTableCompanion Function({
      required String id,
      Value<String?> dataJson,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$TourDraftTableTableUpdateCompanionBuilder =
    TourDraftTableCompanion Function({
      Value<String> id,
      Value<String?> dataJson,
      Value<int?> updatedAt,
      Value<int> rowid,
    });

class $$TourDraftTableTableFilterComposer
    extends Composer<_$AppDatabase, $TourDraftTableTable> {
  $$TourDraftTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TourDraftTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TourDraftTableTable> {
  $$TourDraftTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TourDraftTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TourDraftTableTable> {
  $$TourDraftTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TourDraftTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TourDraftTableTable,
          TourDraftTableData,
          $$TourDraftTableTableFilterComposer,
          $$TourDraftTableTableOrderingComposer,
          $$TourDraftTableTableAnnotationComposer,
          $$TourDraftTableTableCreateCompanionBuilder,
          $$TourDraftTableTableUpdateCompanionBuilder,
          (
            TourDraftTableData,
            BaseReferences<
              _$AppDatabase,
              $TourDraftTableTable,
              TourDraftTableData
            >,
          ),
          TourDraftTableData,
          PrefetchHooks Function()
        > {
  $$TourDraftTableTableTableManager(
    _$AppDatabase db,
    $TourDraftTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TourDraftTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TourDraftTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TourDraftTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> dataJson = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TourDraftTableCompanion(
                id: id,
                dataJson: dataJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> dataJson = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TourDraftTableCompanion.insert(
                id: id,
                dataJson: dataJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TourDraftTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TourDraftTableTable,
      TourDraftTableData,
      $$TourDraftTableTableFilterComposer,
      $$TourDraftTableTableOrderingComposer,
      $$TourDraftTableTableAnnotationComposer,
      $$TourDraftTableTableCreateCompanionBuilder,
      $$TourDraftTableTableUpdateCompanionBuilder,
      (
        TourDraftTableData,
        BaseReferences<_$AppDatabase, $TourDraftTableTable, TourDraftTableData>,
      ),
      TourDraftTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OilStateTableTableTableManager get oilStateTable =>
      $$OilStateTableTableTableManager(_db, _db.oilStateTable);
  $$TourListTableTableTableManager get tourListTable =>
      $$TourListTableTableTableManager(_db, _db.tourListTable);
  $$TourDraftTableTableTableManager get tourDraftTable =>
      $$TourDraftTableTableTableManager(_db, _db.tourDraftTable);
}
