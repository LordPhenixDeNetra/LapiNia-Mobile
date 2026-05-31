// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LapinsLocalTable extends LapinsLocal
    with TableInfo<$LapinsLocalTable, LapinsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LapinsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreFertiliteMeta = const VerificationMeta(
    'scoreFertilite',
  );
  @override
  late final GeneratedColumn<int> scoreFertilite = GeneratedColumn<int>(
    'score_fertilite',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    data,
    scoreFertilite,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lapins_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<LapinsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('score_fertilite')) {
      context.handle(
        _scoreFertiliteMeta,
        scoreFertilite.isAcceptableOrUnknown(
          data['score_fertilite']!,
          _scoreFertiliteMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LapinsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LapinsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      scoreFertilite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_fertilite'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LapinsLocalTable createAlias(String alias) {
    return $LapinsLocalTable(attachedDatabase, alias);
  }
}

class LapinsLocalData extends DataClass implements Insertable<LapinsLocalData> {
  final String id;
  final String userId;
  final String data;
  final int? scoreFertilite;
  final DateTime updatedAt;
  final bool isDeleted;
  const LapinsLocalData({
    required this.id,
    required this.userId,
    required this.data,
    this.scoreFertilite,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['data'] = Variable<String>(data);
    if (!nullToAbsent || scoreFertilite != null) {
      map['score_fertilite'] = Variable<int>(scoreFertilite);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LapinsLocalCompanion toCompanion(bool nullToAbsent) {
    return LapinsLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      data: Value(data),
      scoreFertilite: scoreFertilite == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreFertilite),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LapinsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LapinsLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      data: serializer.fromJson<String>(json['data']),
      scoreFertilite: serializer.fromJson<int?>(json['scoreFertilite']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'data': serializer.toJson<String>(data),
      'scoreFertilite': serializer.toJson<int?>(scoreFertilite),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LapinsLocalData copyWith({
    String? id,
    String? userId,
    String? data,
    Value<int?> scoreFertilite = const Value.absent(),
    DateTime? updatedAt,
    bool? isDeleted,
  }) => LapinsLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    data: data ?? this.data,
    scoreFertilite: scoreFertilite.present
        ? scoreFertilite.value
        : this.scoreFertilite,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LapinsLocalData copyWithCompanion(LapinsLocalCompanion data) {
    return LapinsLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      data: data.data.present ? data.data.value : this.data,
      scoreFertilite: data.scoreFertilite.present
          ? data.scoreFertilite.value
          : this.scoreFertilite,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LapinsLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('scoreFertilite: $scoreFertilite, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, data, scoreFertilite, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LapinsLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.data == this.data &&
          other.scoreFertilite == this.scoreFertilite &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class LapinsLocalCompanion extends UpdateCompanion<LapinsLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> data;
  final Value<int?> scoreFertilite;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LapinsLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.data = const Value.absent(),
    this.scoreFertilite = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LapinsLocalCompanion.insert({
    required String id,
    required String userId,
    required String data,
    this.scoreFertilite = const Value.absent(),
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       data = Value(data),
       updatedAt = Value(updatedAt);
  static Insertable<LapinsLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? data,
    Expression<int>? scoreFertilite,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (data != null) 'data': data,
      if (scoreFertilite != null) 'score_fertilite': scoreFertilite,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LapinsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? data,
    Value<int?>? scoreFertilite,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LapinsLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      scoreFertilite: scoreFertilite ?? this.scoreFertilite,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (scoreFertilite.present) {
      map['score_fertilite'] = Variable<int>(scoreFertilite.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LapinsLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('scoreFertilite: $scoreFertilite, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FertilityScoresLocalTable extends FertilityScoresLocal
    with TableInfo<$FertilityScoresLocalTable, FertilityScoresLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FertilityScoresLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lapinIdMeta = const VerificationMeta(
    'lapinId',
  );
  @override
  late final GeneratedColumn<String> lapinId = GeneratedColumn<String>(
    'lapin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    lapinId,
    monthKey,
    score,
    data,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fertility_scores_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<FertilityScoresLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('lapin_id')) {
      context.handle(
        _lapinIdMeta,
        lapinId.isAcceptableOrUnknown(data['lapin_id']!, _lapinIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lapinIdMeta);
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FertilityScoresLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FertilityScoresLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      lapinId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lapin_id'],
      )!,
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FertilityScoresLocalTable createAlias(String alias) {
    return $FertilityScoresLocalTable(attachedDatabase, alias);
  }
}

class FertilityScoresLocalData extends DataClass
    implements Insertable<FertilityScoresLocalData> {
  final String id;
  final String userId;
  final String lapinId;
  final String monthKey;
  final int score;
  final String? data;
  final DateTime createdAt;
  const FertilityScoresLocalData({
    required this.id,
    required this.userId,
    required this.lapinId,
    required this.monthKey,
    required this.score,
    this.data,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['lapin_id'] = Variable<String>(lapinId);
    map['month_key'] = Variable<String>(monthKey);
    map['score'] = Variable<int>(score);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FertilityScoresLocalCompanion toCompanion(bool nullToAbsent) {
    return FertilityScoresLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      lapinId: Value(lapinId),
      monthKey: Value(monthKey),
      score: Value(score),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      createdAt: Value(createdAt),
    );
  }

  factory FertilityScoresLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FertilityScoresLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      lapinId: serializer.fromJson<String>(json['lapinId']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
      score: serializer.fromJson<int>(json['score']),
      data: serializer.fromJson<String?>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'lapinId': serializer.toJson<String>(lapinId),
      'monthKey': serializer.toJson<String>(monthKey),
      'score': serializer.toJson<int>(score),
      'data': serializer.toJson<String?>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FertilityScoresLocalData copyWith({
    String? id,
    String? userId,
    String? lapinId,
    String? monthKey,
    int? score,
    Value<String?> data = const Value.absent(),
    DateTime? createdAt,
  }) => FertilityScoresLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    lapinId: lapinId ?? this.lapinId,
    monthKey: monthKey ?? this.monthKey,
    score: score ?? this.score,
    data: data.present ? data.value : this.data,
    createdAt: createdAt ?? this.createdAt,
  );
  FertilityScoresLocalData copyWithCompanion(
    FertilityScoresLocalCompanion data,
  ) {
    return FertilityScoresLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      lapinId: data.lapinId.present ? data.lapinId.value : this.lapinId,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      score: data.score.present ? data.score.value : this.score,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FertilityScoresLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('lapinId: $lapinId, ')
          ..write('monthKey: $monthKey, ')
          ..write('score: $score, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, lapinId, monthKey, score, data, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FertilityScoresLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.lapinId == this.lapinId &&
          other.monthKey == this.monthKey &&
          other.score == this.score &&
          other.data == this.data &&
          other.createdAt == this.createdAt);
}

class FertilityScoresLocalCompanion
    extends UpdateCompanion<FertilityScoresLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> lapinId;
  final Value<String> monthKey;
  final Value<int> score;
  final Value<String?> data;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FertilityScoresLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.lapinId = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.score = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FertilityScoresLocalCompanion.insert({
    required String id,
    required String userId,
    required String lapinId,
    required String monthKey,
    required int score,
    this.data = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       lapinId = Value(lapinId),
       monthKey = Value(monthKey),
       score = Value(score),
       createdAt = Value(createdAt);
  static Insertable<FertilityScoresLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? lapinId,
    Expression<String>? monthKey,
    Expression<int>? score,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (lapinId != null) 'lapin_id': lapinId,
      if (monthKey != null) 'month_key': monthKey,
      if (score != null) 'score': score,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FertilityScoresLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? lapinId,
    Value<String>? monthKey,
    Value<int>? score,
    Value<String?>? data,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FertilityScoresLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lapinId: lapinId ?? this.lapinId,
      monthKey: monthKey ?? this.monthKey,
      score: score ?? this.score,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (lapinId.present) {
      map['lapin_id'] = Variable<String>(lapinId.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FertilityScoresLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('lapinId: $lapinId, ')
          ..write('monthKey: $monthKey, ')
          ..write('score: $score, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PorteesLocalTable extends PorteesLocal
    with TableInfo<$PorteesLocalTable, PorteesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PorteesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    data,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'portees_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<PorteesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PorteesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PorteesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $PorteesLocalTable createAlias(String alias) {
    return $PorteesLocalTable(attachedDatabase, alias);
  }
}

class PorteesLocalData extends DataClass
    implements Insertable<PorteesLocalData> {
  final String id;
  final String userId;
  final String data;
  final DateTime updatedAt;
  final bool isDeleted;
  const PorteesLocalData({
    required this.id,
    required this.userId,
    required this.data,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  PorteesLocalCompanion toCompanion(bool nullToAbsent) {
    return PorteesLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      data: Value(data),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory PorteesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PorteesLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  PorteesLocalData copyWith({
    String? id,
    String? userId,
    String? data,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => PorteesLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    data: data ?? this.data,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  PorteesLocalData copyWithCompanion(PorteesLocalCompanion data) {
    return PorteesLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PorteesLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, data, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PorteesLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class PorteesLocalCompanion extends UpdateCompanion<PorteesLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> data;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const PorteesLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PorteesLocalCompanion.insert({
    required String id,
    required String userId,
    required String data,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       data = Value(data),
       updatedAt = Value(updatedAt);
  static Insertable<PorteesLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? data,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PorteesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? data,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return PorteesLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PorteesLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LapereauxLocalTable extends LapereauxLocal
    with TableInfo<$LapereauxLocalTable, LapereauxLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LapereauxLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _porteeIdMeta = const VerificationMeta(
    'porteeId',
  );
  @override
  late final GeneratedColumn<String> porteeId = GeneratedColumn<String>(
    'portee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    porteeId,
    userId,
    data,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lapereaux_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<LapereauxLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('portee_id')) {
      context.handle(
        _porteeIdMeta,
        porteeId.isAcceptableOrUnknown(data['portee_id']!, _porteeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_porteeIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LapereauxLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LapereauxLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      porteeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portee_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LapereauxLocalTable createAlias(String alias) {
    return $LapereauxLocalTable(attachedDatabase, alias);
  }
}

class LapereauxLocalData extends DataClass
    implements Insertable<LapereauxLocalData> {
  final String id;
  final String porteeId;
  final String userId;
  final String data;
  final DateTime updatedAt;
  final bool isDeleted;
  const LapereauxLocalData({
    required this.id,
    required this.porteeId,
    required this.userId,
    required this.data,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['portee_id'] = Variable<String>(porteeId);
    map['user_id'] = Variable<String>(userId);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LapereauxLocalCompanion toCompanion(bool nullToAbsent) {
    return LapereauxLocalCompanion(
      id: Value(id),
      porteeId: Value(porteeId),
      userId: Value(userId),
      data: Value(data),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LapereauxLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LapereauxLocalData(
      id: serializer.fromJson<String>(json['id']),
      porteeId: serializer.fromJson<String>(json['porteeId']),
      userId: serializer.fromJson<String>(json['userId']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'porteeId': serializer.toJson<String>(porteeId),
      'userId': serializer.toJson<String>(userId),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LapereauxLocalData copyWith({
    String? id,
    String? porteeId,
    String? userId,
    String? data,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => LapereauxLocalData(
    id: id ?? this.id,
    porteeId: porteeId ?? this.porteeId,
    userId: userId ?? this.userId,
    data: data ?? this.data,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LapereauxLocalData copyWithCompanion(LapereauxLocalCompanion data) {
    return LapereauxLocalData(
      id: data.id.present ? data.id.value : this.id,
      porteeId: data.porteeId.present ? data.porteeId.value : this.porteeId,
      userId: data.userId.present ? data.userId.value : this.userId,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LapereauxLocalData(')
          ..write('id: $id, ')
          ..write('porteeId: $porteeId, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, porteeId, userId, data, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LapereauxLocalData &&
          other.id == this.id &&
          other.porteeId == this.porteeId &&
          other.userId == this.userId &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class LapereauxLocalCompanion extends UpdateCompanion<LapereauxLocalData> {
  final Value<String> id;
  final Value<String> porteeId;
  final Value<String> userId;
  final Value<String> data;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LapereauxLocalCompanion({
    this.id = const Value.absent(),
    this.porteeId = const Value.absent(),
    this.userId = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LapereauxLocalCompanion.insert({
    required String id,
    required String porteeId,
    required String userId,
    required String data,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       porteeId = Value(porteeId),
       userId = Value(userId),
       data = Value(data),
       updatedAt = Value(updatedAt);
  static Insertable<LapereauxLocalData> custom({
    Expression<String>? id,
    Expression<String>? porteeId,
    Expression<String>? userId,
    Expression<String>? data,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (porteeId != null) 'portee_id': porteeId,
      if (userId != null) 'user_id': userId,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LapereauxLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? porteeId,
    Value<String>? userId,
    Value<String>? data,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LapereauxLocalCompanion(
      id: id ?? this.id,
      porteeId: porteeId ?? this.porteeId,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (porteeId.present) {
      map['portee_id'] = Variable<String>(porteeId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LapereauxLocalCompanion(')
          ..write('id: $id, ')
          ..write('porteeId: $porteeId, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeseesLocalTable extends PeseesLocal
    with TableInfo<$PeseesLocalTable, PeseesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeseesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lapinIdMeta = const VerificationMeta(
    'lapinId',
  );
  @override
  late final GeneratedColumn<String> lapinId = GeneratedColumn<String>(
    'lapin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lapinId,
    userId,
    data,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pesees_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeseesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lapin_id')) {
      context.handle(
        _lapinIdMeta,
        lapinId.isAcceptableOrUnknown(data['lapin_id']!, _lapinIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lapinIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeseesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeseesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lapinId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lapin_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $PeseesLocalTable createAlias(String alias) {
    return $PeseesLocalTable(attachedDatabase, alias);
  }
}

class PeseesLocalData extends DataClass implements Insertable<PeseesLocalData> {
  final String id;
  final String lapinId;
  final String userId;
  final String data;
  final DateTime updatedAt;
  final bool isDeleted;
  const PeseesLocalData({
    required this.id,
    required this.lapinId,
    required this.userId,
    required this.data,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lapin_id'] = Variable<String>(lapinId);
    map['user_id'] = Variable<String>(userId);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  PeseesLocalCompanion toCompanion(bool nullToAbsent) {
    return PeseesLocalCompanion(
      id: Value(id),
      lapinId: Value(lapinId),
      userId: Value(userId),
      data: Value(data),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory PeseesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeseesLocalData(
      id: serializer.fromJson<String>(json['id']),
      lapinId: serializer.fromJson<String>(json['lapinId']),
      userId: serializer.fromJson<String>(json['userId']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lapinId': serializer.toJson<String>(lapinId),
      'userId': serializer.toJson<String>(userId),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  PeseesLocalData copyWith({
    String? id,
    String? lapinId,
    String? userId,
    String? data,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => PeseesLocalData(
    id: id ?? this.id,
    lapinId: lapinId ?? this.lapinId,
    userId: userId ?? this.userId,
    data: data ?? this.data,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  PeseesLocalData copyWithCompanion(PeseesLocalCompanion data) {
    return PeseesLocalData(
      id: data.id.present ? data.id.value : this.id,
      lapinId: data.lapinId.present ? data.lapinId.value : this.lapinId,
      userId: data.userId.present ? data.userId.value : this.userId,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeseesLocalData(')
          ..write('id: $id, ')
          ..write('lapinId: $lapinId, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lapinId, userId, data, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeseesLocalData &&
          other.id == this.id &&
          other.lapinId == this.lapinId &&
          other.userId == this.userId &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class PeseesLocalCompanion extends UpdateCompanion<PeseesLocalData> {
  final Value<String> id;
  final Value<String> lapinId;
  final Value<String> userId;
  final Value<String> data;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const PeseesLocalCompanion({
    this.id = const Value.absent(),
    this.lapinId = const Value.absent(),
    this.userId = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeseesLocalCompanion.insert({
    required String id,
    required String lapinId,
    required String userId,
    required String data,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lapinId = Value(lapinId),
       userId = Value(userId),
       data = Value(data),
       updatedAt = Value(updatedAt);
  static Insertable<PeseesLocalData> custom({
    Expression<String>? id,
    Expression<String>? lapinId,
    Expression<String>? userId,
    Expression<String>? data,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lapinId != null) 'lapin_id': lapinId,
      if (userId != null) 'user_id': userId,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeseesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? lapinId,
    Value<String>? userId,
    Value<String>? data,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return PeseesLocalCompanion(
      id: id ?? this.id,
      lapinId: lapinId ?? this.lapinId,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lapinId.present) {
      map['lapin_id'] = Variable<String>(lapinId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeseesLocalCompanion(')
          ..write('id: $id, ')
          ..write('lapinId: $lapinId, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SanteLocalTable extends SanteLocal
    with TableInfo<$SanteLocalTable, SanteLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SanteLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lapinIdMeta = const VerificationMeta(
    'lapinId',
  );
  @override
  late final GeneratedColumn<String> lapinId = GeneratedColumn<String>(
    'lapin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lapinId,
    userId,
    data,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sante_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<SanteLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lapin_id')) {
      context.handle(
        _lapinIdMeta,
        lapinId.isAcceptableOrUnknown(data['lapin_id']!, _lapinIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lapinIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SanteLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SanteLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lapinId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lapin_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $SanteLocalTable createAlias(String alias) {
    return $SanteLocalTable(attachedDatabase, alias);
  }
}

class SanteLocalData extends DataClass implements Insertable<SanteLocalData> {
  final String id;
  final String lapinId;
  final String userId;
  final String data;
  final DateTime updatedAt;
  final bool isDeleted;
  const SanteLocalData({
    required this.id,
    required this.lapinId,
    required this.userId,
    required this.data,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lapin_id'] = Variable<String>(lapinId);
    map['user_id'] = Variable<String>(userId);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  SanteLocalCompanion toCompanion(bool nullToAbsent) {
    return SanteLocalCompanion(
      id: Value(id),
      lapinId: Value(lapinId),
      userId: Value(userId),
      data: Value(data),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory SanteLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SanteLocalData(
      id: serializer.fromJson<String>(json['id']),
      lapinId: serializer.fromJson<String>(json['lapinId']),
      userId: serializer.fromJson<String>(json['userId']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lapinId': serializer.toJson<String>(lapinId),
      'userId': serializer.toJson<String>(userId),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  SanteLocalData copyWith({
    String? id,
    String? lapinId,
    String? userId,
    String? data,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => SanteLocalData(
    id: id ?? this.id,
    lapinId: lapinId ?? this.lapinId,
    userId: userId ?? this.userId,
    data: data ?? this.data,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  SanteLocalData copyWithCompanion(SanteLocalCompanion data) {
    return SanteLocalData(
      id: data.id.present ? data.id.value : this.id,
      lapinId: data.lapinId.present ? data.lapinId.value : this.lapinId,
      userId: data.userId.present ? data.userId.value : this.userId,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SanteLocalData(')
          ..write('id: $id, ')
          ..write('lapinId: $lapinId, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lapinId, userId, data, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SanteLocalData &&
          other.id == this.id &&
          other.lapinId == this.lapinId &&
          other.userId == this.userId &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class SanteLocalCompanion extends UpdateCompanion<SanteLocalData> {
  final Value<String> id;
  final Value<String> lapinId;
  final Value<String> userId;
  final Value<String> data;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const SanteLocalCompanion({
    this.id = const Value.absent(),
    this.lapinId = const Value.absent(),
    this.userId = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SanteLocalCompanion.insert({
    required String id,
    required String lapinId,
    required String userId,
    required String data,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lapinId = Value(lapinId),
       userId = Value(userId),
       data = Value(data),
       updatedAt = Value(updatedAt);
  static Insertable<SanteLocalData> custom({
    Expression<String>? id,
    Expression<String>? lapinId,
    Expression<String>? userId,
    Expression<String>? data,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lapinId != null) 'lapin_id': lapinId,
      if (userId != null) 'user_id': userId,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SanteLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? lapinId,
    Value<String>? userId,
    Value<String>? data,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return SanteLocalCompanion(
      id: id ?? this.id,
      lapinId: lapinId ?? this.lapinId,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lapinId.present) {
      map['lapin_id'] = Variable<String>(lapinId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SanteLocalCompanion(')
          ..write('id: $id, ')
          ..write('lapinId: $lapinId, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StocksLocalTable extends StocksLocal
    with TableInfo<$StocksLocalTable, StocksLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    data,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocks_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<StocksLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StocksLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StocksLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $StocksLocalTable createAlias(String alias) {
    return $StocksLocalTable(attachedDatabase, alias);
  }
}

class StocksLocalData extends DataClass implements Insertable<StocksLocalData> {
  final String id;
  final String userId;
  final String data;
  final DateTime updatedAt;
  final bool isDeleted;
  const StocksLocalData({
    required this.id,
    required this.userId,
    required this.data,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  StocksLocalCompanion toCompanion(bool nullToAbsent) {
    return StocksLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      data: Value(data),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory StocksLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StocksLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  StocksLocalData copyWith({
    String? id,
    String? userId,
    String? data,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => StocksLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    data: data ?? this.data,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  StocksLocalData copyWithCompanion(StocksLocalCompanion data) {
    return StocksLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StocksLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, data, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StocksLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class StocksLocalCompanion extends UpdateCompanion<StocksLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> data;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const StocksLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocksLocalCompanion.insert({
    required String id,
    required String userId,
    required String data,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       data = Value(data),
       updatedAt = Value(updatedAt);
  static Insertable<StocksLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? data,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocksLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? data,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return StocksLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancesLocalTable extends FinancesLocal
    with TableInfo<$FinancesLocalTable, FinancesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    data,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'finances_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $FinancesLocalTable createAlias(String alias) {
    return $FinancesLocalTable(attachedDatabase, alias);
  }
}

class FinancesLocalData extends DataClass
    implements Insertable<FinancesLocalData> {
  final String id;
  final String userId;
  final String data;
  final DateTime updatedAt;
  final bool isDeleted;
  const FinancesLocalData({
    required this.id,
    required this.userId,
    required this.data,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  FinancesLocalCompanion toCompanion(bool nullToAbsent) {
    return FinancesLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      data: Value(data),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory FinancesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancesLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  FinancesLocalData copyWith({
    String? id,
    String? userId,
    String? data,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => FinancesLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    data: data ?? this.data,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  FinancesLocalData copyWithCompanion(FinancesLocalCompanion data) {
    return FinancesLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancesLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, data, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancesLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class FinancesLocalCompanion extends UpdateCompanion<FinancesLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> data;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const FinancesLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancesLocalCompanion.insert({
    required String id,
    required String userId,
    required String data,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       data = Value(data),
       updatedAt = Value(updatedAt);
  static Insertable<FinancesLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? data,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? data,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return FinancesLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancesLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertesLocalTable extends AlertesLocal
    with TableInfo<$AlertesLocalTable, AlertesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    data,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alertes_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $AlertesLocalTable createAlias(String alias) {
    return $AlertesLocalTable(attachedDatabase, alias);
  }
}

class AlertesLocalData extends DataClass
    implements Insertable<AlertesLocalData> {
  final String id;
  final String userId;
  final String data;
  final DateTime updatedAt;
  final bool isDeleted;
  const AlertesLocalData({
    required this.id,
    required this.userId,
    required this.data,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  AlertesLocalCompanion toCompanion(bool nullToAbsent) {
    return AlertesLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      data: Value(data),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory AlertesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertesLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  AlertesLocalData copyWith({
    String? id,
    String? userId,
    String? data,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => AlertesLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    data: data ?? this.data,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  AlertesLocalData copyWithCompanion(AlertesLocalCompanion data) {
    return AlertesLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertesLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, data, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertesLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class AlertesLocalCompanion extends UpdateCompanion<AlertesLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> data;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const AlertesLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertesLocalCompanion.insert({
    required String id,
    required String userId,
    required String data,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       data = Value(data),
       updatedAt = Value(updatedAt);
  static Insertable<AlertesLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? data,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? data,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return AlertesLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertesLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RacesRefTable extends RacesRef
    with TableInfo<$RacesRefTable, RacesRefData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RacesRefTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, data, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'races_ref';
  @override
  VerificationContext validateIntegrity(
    Insertable<RacesRefData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RacesRefData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RacesRefData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $RacesRefTable createAlias(String alias) {
    return $RacesRefTable(attachedDatabase, alias);
  }
}

class RacesRefData extends DataClass implements Insertable<RacesRefData> {
  final String id;
  final String data;
  final DateTime cachedAt;
  const RacesRefData({
    required this.id,
    required this.data,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['data'] = Variable<String>(data);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  RacesRefCompanion toCompanion(bool nullToAbsent) {
    return RacesRefCompanion(
      id: Value(id),
      data: Value(data),
      cachedAt: Value(cachedAt),
    );
  }

  factory RacesRefData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RacesRefData(
      id: serializer.fromJson<String>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'data': serializer.toJson<String>(data),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  RacesRefData copyWith({String? id, String? data, DateTime? cachedAt}) =>
      RacesRefData(
        id: id ?? this.id,
        data: data ?? this.data,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  RacesRefData copyWithCompanion(RacesRefCompanion data) {
    return RacesRefData(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RacesRefData(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RacesRefData &&
          other.id == this.id &&
          other.data == this.data &&
          other.cachedAt == this.cachedAt);
}

class RacesRefCompanion extends UpdateCompanion<RacesRefData> {
  final Value<String> id;
  final Value<String> data;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const RacesRefCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RacesRefCompanion.insert({
    required String id,
    required String data,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       data = Value(data),
       cachedAt = Value(cachedAt);
  static Insertable<RacesRefData> custom({
    Expression<String>? id,
    Expression<String>? data,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RacesRefCompanion copyWith({
    Value<String>? id,
    Value<String>? data,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return RacesRefCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RacesRefCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicamentsRefTable extends MedicamentsRef
    with TableInfo<$MedicamentsRefTable, MedicamentsRefData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicamentsRefTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, data, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicaments_ref';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicamentsRefData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicamentsRefData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicamentsRefData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $MedicamentsRefTable createAlias(String alias) {
    return $MedicamentsRefTable(attachedDatabase, alias);
  }
}

class MedicamentsRefData extends DataClass
    implements Insertable<MedicamentsRefData> {
  final String id;
  final String data;
  final DateTime cachedAt;
  const MedicamentsRefData({
    required this.id,
    required this.data,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['data'] = Variable<String>(data);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  MedicamentsRefCompanion toCompanion(bool nullToAbsent) {
    return MedicamentsRefCompanion(
      id: Value(id),
      data: Value(data),
      cachedAt: Value(cachedAt),
    );
  }

  factory MedicamentsRefData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicamentsRefData(
      id: serializer.fromJson<String>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'data': serializer.toJson<String>(data),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  MedicamentsRefData copyWith({String? id, String? data, DateTime? cachedAt}) =>
      MedicamentsRefData(
        id: id ?? this.id,
        data: data ?? this.data,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  MedicamentsRefData copyWithCompanion(MedicamentsRefCompanion data) {
    return MedicamentsRefData(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicamentsRefData(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicamentsRefData &&
          other.id == this.id &&
          other.data == this.data &&
          other.cachedAt == this.cachedAt);
}

class MedicamentsRefCompanion extends UpdateCompanion<MedicamentsRefData> {
  final Value<String> id;
  final Value<String> data;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const MedicamentsRefCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicamentsRefCompanion.insert({
    required String id,
    required String data,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       data = Value(data),
       cachedAt = Value(cachedAt);
  static Insertable<MedicamentsRefData> custom({
    Expression<String>? id,
    Expression<String>? data,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicamentsRefCompanion copyWith({
    Value<String>? id,
    Value<String>? data,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return MedicamentsRefCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicamentsRefCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlimentsLocauxRefTable extends AlimentsLocauxRef
    with TableInfo<$AlimentsLocauxRefTable, AlimentsLocauxRefData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlimentsLocauxRefTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, data, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aliments_locaux_ref';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlimentsLocauxRefData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlimentsLocauxRefData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlimentsLocauxRefData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $AlimentsLocauxRefTable createAlias(String alias) {
    return $AlimentsLocauxRefTable(attachedDatabase, alias);
  }
}

class AlimentsLocauxRefData extends DataClass
    implements Insertable<AlimentsLocauxRefData> {
  final String id;
  final String data;
  final DateTime cachedAt;
  const AlimentsLocauxRefData({
    required this.id,
    required this.data,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['data'] = Variable<String>(data);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  AlimentsLocauxRefCompanion toCompanion(bool nullToAbsent) {
    return AlimentsLocauxRefCompanion(
      id: Value(id),
      data: Value(data),
      cachedAt: Value(cachedAt),
    );
  }

  factory AlimentsLocauxRefData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlimentsLocauxRefData(
      id: serializer.fromJson<String>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'data': serializer.toJson<String>(data),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  AlimentsLocauxRefData copyWith({
    String? id,
    String? data,
    DateTime? cachedAt,
  }) => AlimentsLocauxRefData(
    id: id ?? this.id,
    data: data ?? this.data,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  AlimentsLocauxRefData copyWithCompanion(AlimentsLocauxRefCompanion data) {
    return AlimentsLocauxRefData(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlimentsLocauxRefData(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlimentsLocauxRefData &&
          other.id == this.id &&
          other.data == this.data &&
          other.cachedAt == this.cachedAt);
}

class AlimentsLocauxRefCompanion
    extends UpdateCompanion<AlimentsLocauxRefData> {
  final Value<String> id;
  final Value<String> data;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const AlimentsLocauxRefCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlimentsLocauxRefCompanion.insert({
    required String id,
    required String data,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       data = Value(data),
       cachedAt = Value(cachedAt);
  static Insertable<AlimentsLocauxRefData> custom({
    Expression<String>? id,
    Expression<String>? data,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlimentsLocauxRefCompanion copyWith({
    Value<String>? id,
    Value<String>? data,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return AlimentsLocauxRefCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlimentsLocauxRefCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyAdviceCacheTable extends DailyAdviceCache
    with TableInfo<$DailyAdviceCacheTable, DailyAdviceCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyAdviceCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, content, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_advice_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyAdviceCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyAdviceCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyAdviceCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $DailyAdviceCacheTable createAlias(String alias) {
    return $DailyAdviceCacheTable(attachedDatabase, alias);
  }
}

class DailyAdviceCacheData extends DataClass
    implements Insertable<DailyAdviceCacheData> {
  final String id;
  final String userId;
  final String content;
  final DateTime cachedAt;
  const DailyAdviceCacheData({
    required this.id,
    required this.userId,
    required this.content,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['content'] = Variable<String>(content);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  DailyAdviceCacheCompanion toCompanion(bool nullToAbsent) {
    return DailyAdviceCacheCompanion(
      id: Value(id),
      userId: Value(userId),
      content: Value(content),
      cachedAt: Value(cachedAt),
    );
  }

  factory DailyAdviceCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyAdviceCacheData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      content: serializer.fromJson<String>(json['content']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'content': serializer.toJson<String>(content),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  DailyAdviceCacheData copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? cachedAt,
  }) => DailyAdviceCacheData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    content: content ?? this.content,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  DailyAdviceCacheData copyWithCompanion(DailyAdviceCacheCompanion data) {
    return DailyAdviceCacheData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      content: data.content.present ? data.content.value : this.content,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyAdviceCacheData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('content: $content, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, content, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyAdviceCacheData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.content == this.content &&
          other.cachedAt == this.cachedAt);
}

class DailyAdviceCacheCompanion extends UpdateCompanion<DailyAdviceCacheData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> content;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const DailyAdviceCacheCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.content = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyAdviceCacheCompanion.insert({
    required String id,
    required String userId,
    required String content,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       content = Value(content),
       cachedAt = Value(cachedAt);
  static Insertable<DailyAdviceCacheData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? content,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (content != null) 'content': content,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyAdviceCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? content,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return DailyAdviceCacheCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyAdviceCacheCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('content: $content, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedEventsTable extends PlannedEvents
    with TableInfo<$PlannedEventsTable, PlannedEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    targetId,
    date,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlannedEventsTable createAlias(String alias) {
    return $PlannedEventsTable(attachedDatabase, alias);
  }
}

class PlannedEvent extends DataClass implements Insertable<PlannedEvent> {
  final String id;
  final String userId;
  final String type;
  final String? targetId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  const PlannedEvent({
    required this.id,
    required this.userId,
    required this.type,
    this.targetId,
    required this.date,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<String>(targetId);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlannedEventsCompanion toCompanion(bool nullToAbsent) {
    return PlannedEventsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory PlannedEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedEvent(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      targetId: serializer.fromJson<String?>(json['targetId']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'targetId': serializer.toJson<String?>(targetId),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlannedEvent copyWith({
    String? id,
    String? userId,
    String? type,
    Value<String?> targetId = const Value.absent(),
    DateTime? date,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => PlannedEvent(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    targetId: targetId.present ? targetId.value : this.targetId,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  PlannedEvent copyWithCompanion(PlannedEventsCompanion data) {
    return PlannedEvent(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedEvent(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('targetId: $targetId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, type, targetId, date, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedEvent &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.targetId == this.targetId &&
          other.date == this.date &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class PlannedEventsCompanion extends UpdateCompanion<PlannedEvent> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String?> targetId;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlannedEventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.targetId = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedEventsCompanion.insert({
    required String id,
    required String userId,
    required String type,
    this.targetId = const Value.absent(),
    required DateTime date,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       type = Value(type),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<PlannedEvent> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? targetId,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (targetId != null) 'target_id': targetId,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? type,
    Value<String?>? targetId,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlannedEventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedEventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('targetId: $targetId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreMiseBasChecklistLocalTable extends PreMiseBasChecklistLocal
    with
        TableInfo<
          $PreMiseBasChecklistLocalTable,
          PreMiseBasChecklistLocalData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreMiseBasChecklistLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _porteeIdMeta = const VerificationMeta(
    'porteeId',
  );
  @override
  late final GeneratedColumn<String> porteeId = GeneratedColumn<String>(
    'portee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemKeyMeta = const VerificationMeta(
    'itemKey',
  );
  @override
  late final GeneratedColumn<String> itemKey = GeneratedColumn<String>(
    'item_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedMeta = const VerificationMeta(
    'checked',
  );
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
    'checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("checked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    porteeId,
    itemKey,
    checked,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pre_mise_bas_checklist_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreMiseBasChecklistLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('portee_id')) {
      context.handle(
        _porteeIdMeta,
        porteeId.isAcceptableOrUnknown(data['portee_id']!, _porteeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_porteeIdMeta);
    }
    if (data.containsKey('item_key')) {
      context.handle(
        _itemKeyMeta,
        itemKey.isAcceptableOrUnknown(data['item_key']!, _itemKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_itemKeyMeta);
    }
    if (data.containsKey('checked')) {
      context.handle(
        _checkedMeta,
        checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta),
      );
    } else if (isInserting) {
      context.missing(_checkedMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreMiseBasChecklistLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreMiseBasChecklistLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      porteeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portee_id'],
      )!,
      itemKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_key'],
      )!,
      checked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}checked'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PreMiseBasChecklistLocalTable createAlias(String alias) {
    return $PreMiseBasChecklistLocalTable(attachedDatabase, alias);
  }
}

class PreMiseBasChecklistLocalData extends DataClass
    implements Insertable<PreMiseBasChecklistLocalData> {
  final String id;
  final String userId;
  final String porteeId;
  final String itemKey;
  final bool checked;
  final DateTime updatedAt;
  const PreMiseBasChecklistLocalData({
    required this.id,
    required this.userId,
    required this.porteeId,
    required this.itemKey,
    required this.checked,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['portee_id'] = Variable<String>(porteeId);
    map['item_key'] = Variable<String>(itemKey);
    map['checked'] = Variable<bool>(checked);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PreMiseBasChecklistLocalCompanion toCompanion(bool nullToAbsent) {
    return PreMiseBasChecklistLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      porteeId: Value(porteeId),
      itemKey: Value(itemKey),
      checked: Value(checked),
      updatedAt: Value(updatedAt),
    );
  }

  factory PreMiseBasChecklistLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreMiseBasChecklistLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      porteeId: serializer.fromJson<String>(json['porteeId']),
      itemKey: serializer.fromJson<String>(json['itemKey']),
      checked: serializer.fromJson<bool>(json['checked']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'porteeId': serializer.toJson<String>(porteeId),
      'itemKey': serializer.toJson<String>(itemKey),
      'checked': serializer.toJson<bool>(checked),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PreMiseBasChecklistLocalData copyWith({
    String? id,
    String? userId,
    String? porteeId,
    String? itemKey,
    bool? checked,
    DateTime? updatedAt,
  }) => PreMiseBasChecklistLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    porteeId: porteeId ?? this.porteeId,
    itemKey: itemKey ?? this.itemKey,
    checked: checked ?? this.checked,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PreMiseBasChecklistLocalData copyWithCompanion(
    PreMiseBasChecklistLocalCompanion data,
  ) {
    return PreMiseBasChecklistLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      porteeId: data.porteeId.present ? data.porteeId.value : this.porteeId,
      itemKey: data.itemKey.present ? data.itemKey.value : this.itemKey,
      checked: data.checked.present ? data.checked.value : this.checked,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreMiseBasChecklistLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('porteeId: $porteeId, ')
          ..write('itemKey: $itemKey, ')
          ..write('checked: $checked, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, porteeId, itemKey, checked, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreMiseBasChecklistLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.porteeId == this.porteeId &&
          other.itemKey == this.itemKey &&
          other.checked == this.checked &&
          other.updatedAt == this.updatedAt);
}

class PreMiseBasChecklistLocalCompanion
    extends UpdateCompanion<PreMiseBasChecklistLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> porteeId;
  final Value<String> itemKey;
  final Value<bool> checked;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PreMiseBasChecklistLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.porteeId = const Value.absent(),
    this.itemKey = const Value.absent(),
    this.checked = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreMiseBasChecklistLocalCompanion.insert({
    required String id,
    required String userId,
    required String porteeId,
    required String itemKey,
    required bool checked,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       porteeId = Value(porteeId),
       itemKey = Value(itemKey),
       checked = Value(checked),
       updatedAt = Value(updatedAt);
  static Insertable<PreMiseBasChecklistLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? porteeId,
    Expression<String>? itemKey,
    Expression<bool>? checked,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (porteeId != null) 'portee_id': porteeId,
      if (itemKey != null) 'item_key': itemKey,
      if (checked != null) 'checked': checked,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreMiseBasChecklistLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? porteeId,
    Value<String>? itemKey,
    Value<bool>? checked,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PreMiseBasChecklistLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      porteeId: porteeId ?? this.porteeId,
      itemKey: itemKey ?? this.itemKey,
      checked: checked ?? this.checked,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (porteeId.present) {
      map['portee_id'] = Variable<String>(porteeId.value);
    }
    if (itemKey.present) {
      map['item_key'] = Variable<String>(itemKey.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreMiseBasChecklistLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('porteeId: $porteeId, ')
          ..write('itemKey: $itemKey, ')
          ..write('checked: $checked, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    operation,
    payload,
    idempotencyKey,
    createdAt,
    retryCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['table_name']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String targetTable;
  final String operation;
  final String payload;
  final String idempotencyKey;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  const SyncQueueData({
    required this.id,
    required this.targetTable,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    required this.createdAt,
    required this.retryCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(targetTable);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      operation: Value(operation),
      payload: Value(payload),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueData copyWith({
    String? id,
    String? targetTable,
    String? operation,
    String? payload,
    String? idempotencyKey,
    DateTime? createdAt,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    operation,
    payload,
    idempotencyKey,
    createdAt,
    retryCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> targetTable;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> idempotencyKey;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String targetTable,
    required String operation,
    required String payload,
    required String idempotencyKey,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetTable = Value(targetTable),
       operation = Value(operation),
       payload = Value(payload),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? targetTable,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'table_name': targetTable,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? targetTable,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? idempotencyKey,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetTable.present) {
      map['table_name'] = Variable<String>(targetTable.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LapinsLocalTable lapinsLocal = $LapinsLocalTable(this);
  late final $FertilityScoresLocalTable fertilityScoresLocal =
      $FertilityScoresLocalTable(this);
  late final $PorteesLocalTable porteesLocal = $PorteesLocalTable(this);
  late final $LapereauxLocalTable lapereauxLocal = $LapereauxLocalTable(this);
  late final $PeseesLocalTable peseesLocal = $PeseesLocalTable(this);
  late final $SanteLocalTable santeLocal = $SanteLocalTable(this);
  late final $StocksLocalTable stocksLocal = $StocksLocalTable(this);
  late final $FinancesLocalTable financesLocal = $FinancesLocalTable(this);
  late final $AlertesLocalTable alertesLocal = $AlertesLocalTable(this);
  late final $RacesRefTable racesRef = $RacesRefTable(this);
  late final $MedicamentsRefTable medicamentsRef = $MedicamentsRefTable(this);
  late final $AlimentsLocauxRefTable alimentsLocauxRef =
      $AlimentsLocauxRefTable(this);
  late final $DailyAdviceCacheTable dailyAdviceCache = $DailyAdviceCacheTable(
    this,
  );
  late final $PlannedEventsTable plannedEvents = $PlannedEventsTable(this);
  late final $PreMiseBasChecklistLocalTable preMiseBasChecklistLocal =
      $PreMiseBasChecklistLocalTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lapinsLocal,
    fertilityScoresLocal,
    porteesLocal,
    lapereauxLocal,
    peseesLocal,
    santeLocal,
    stocksLocal,
    financesLocal,
    alertesLocal,
    racesRef,
    medicamentsRef,
    alimentsLocauxRef,
    dailyAdviceCache,
    plannedEvents,
    preMiseBasChecklistLocal,
    syncQueue,
  ];
}

typedef $$LapinsLocalTableCreateCompanionBuilder =
    LapinsLocalCompanion Function({
      required String id,
      required String userId,
      required String data,
      Value<int?> scoreFertilite,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LapinsLocalTableUpdateCompanionBuilder =
    LapinsLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> data,
      Value<int?> scoreFertilite,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$LapinsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $LapinsLocalTable> {
  $$LapinsLocalTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreFertilite => $composableBuilder(
    column: $table.scoreFertilite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LapinsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $LapinsLocalTable> {
  $$LapinsLocalTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreFertilite => $composableBuilder(
    column: $table.scoreFertilite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LapinsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $LapinsLocalTable> {
  $$LapinsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get scoreFertilite => $composableBuilder(
    column: $table.scoreFertilite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LapinsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LapinsLocalTable,
          LapinsLocalData,
          $$LapinsLocalTableFilterComposer,
          $$LapinsLocalTableOrderingComposer,
          $$LapinsLocalTableAnnotationComposer,
          $$LapinsLocalTableCreateCompanionBuilder,
          $$LapinsLocalTableUpdateCompanionBuilder,
          (
            LapinsLocalData,
            BaseReferences<_$AppDatabase, $LapinsLocalTable, LapinsLocalData>,
          ),
          LapinsLocalData,
          PrefetchHooks Function()
        > {
  $$LapinsLocalTableTableManager(_$AppDatabase db, $LapinsLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LapinsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LapinsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LapinsLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int?> scoreFertilite = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LapinsLocalCompanion(
                id: id,
                userId: userId,
                data: data,
                scoreFertilite: scoreFertilite,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String data,
                Value<int?> scoreFertilite = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LapinsLocalCompanion.insert(
                id: id,
                userId: userId,
                data: data,
                scoreFertilite: scoreFertilite,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LapinsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LapinsLocalTable,
      LapinsLocalData,
      $$LapinsLocalTableFilterComposer,
      $$LapinsLocalTableOrderingComposer,
      $$LapinsLocalTableAnnotationComposer,
      $$LapinsLocalTableCreateCompanionBuilder,
      $$LapinsLocalTableUpdateCompanionBuilder,
      (
        LapinsLocalData,
        BaseReferences<_$AppDatabase, $LapinsLocalTable, LapinsLocalData>,
      ),
      LapinsLocalData,
      PrefetchHooks Function()
    >;
typedef $$FertilityScoresLocalTableCreateCompanionBuilder =
    FertilityScoresLocalCompanion Function({
      required String id,
      required String userId,
      required String lapinId,
      required String monthKey,
      required int score,
      Value<String?> data,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FertilityScoresLocalTableUpdateCompanionBuilder =
    FertilityScoresLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> lapinId,
      Value<String> monthKey,
      Value<int> score,
      Value<String?> data,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FertilityScoresLocalTableFilterComposer
    extends Composer<_$AppDatabase, $FertilityScoresLocalTable> {
  $$FertilityScoresLocalTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lapinId => $composableBuilder(
    column: $table.lapinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FertilityScoresLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $FertilityScoresLocalTable> {
  $$FertilityScoresLocalTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lapinId => $composableBuilder(
    column: $table.lapinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FertilityScoresLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $FertilityScoresLocalTable> {
  $$FertilityScoresLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get lapinId =>
      $composableBuilder(column: $table.lapinId, builder: (column) => column);

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FertilityScoresLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FertilityScoresLocalTable,
          FertilityScoresLocalData,
          $$FertilityScoresLocalTableFilterComposer,
          $$FertilityScoresLocalTableOrderingComposer,
          $$FertilityScoresLocalTableAnnotationComposer,
          $$FertilityScoresLocalTableCreateCompanionBuilder,
          $$FertilityScoresLocalTableUpdateCompanionBuilder,
          (
            FertilityScoresLocalData,
            BaseReferences<
              _$AppDatabase,
              $FertilityScoresLocalTable,
              FertilityScoresLocalData
            >,
          ),
          FertilityScoresLocalData,
          PrefetchHooks Function()
        > {
  $$FertilityScoresLocalTableTableManager(
    _$AppDatabase db,
    $FertilityScoresLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FertilityScoresLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FertilityScoresLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FertilityScoresLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> lapinId = const Value.absent(),
                Value<String> monthKey = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FertilityScoresLocalCompanion(
                id: id,
                userId: userId,
                lapinId: lapinId,
                monthKey: monthKey,
                score: score,
                data: data,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String lapinId,
                required String monthKey,
                required int score,
                Value<String?> data = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FertilityScoresLocalCompanion.insert(
                id: id,
                userId: userId,
                lapinId: lapinId,
                monthKey: monthKey,
                score: score,
                data: data,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FertilityScoresLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FertilityScoresLocalTable,
      FertilityScoresLocalData,
      $$FertilityScoresLocalTableFilterComposer,
      $$FertilityScoresLocalTableOrderingComposer,
      $$FertilityScoresLocalTableAnnotationComposer,
      $$FertilityScoresLocalTableCreateCompanionBuilder,
      $$FertilityScoresLocalTableUpdateCompanionBuilder,
      (
        FertilityScoresLocalData,
        BaseReferences<
          _$AppDatabase,
          $FertilityScoresLocalTable,
          FertilityScoresLocalData
        >,
      ),
      FertilityScoresLocalData,
      PrefetchHooks Function()
    >;
typedef $$PorteesLocalTableCreateCompanionBuilder =
    PorteesLocalCompanion Function({
      required String id,
      required String userId,
      required String data,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$PorteesLocalTableUpdateCompanionBuilder =
    PorteesLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> data,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$PorteesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $PorteesLocalTable> {
  $$PorteesLocalTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PorteesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $PorteesLocalTable> {
  $$PorteesLocalTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PorteesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $PorteesLocalTable> {
  $$PorteesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$PorteesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PorteesLocalTable,
          PorteesLocalData,
          $$PorteesLocalTableFilterComposer,
          $$PorteesLocalTableOrderingComposer,
          $$PorteesLocalTableAnnotationComposer,
          $$PorteesLocalTableCreateCompanionBuilder,
          $$PorteesLocalTableUpdateCompanionBuilder,
          (
            PorteesLocalData,
            BaseReferences<_$AppDatabase, $PorteesLocalTable, PorteesLocalData>,
          ),
          PorteesLocalData,
          PrefetchHooks Function()
        > {
  $$PorteesLocalTableTableManager(_$AppDatabase db, $PorteesLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PorteesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PorteesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PorteesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PorteesLocalCompanion(
                id: id,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String data,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PorteesLocalCompanion.insert(
                id: id,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PorteesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PorteesLocalTable,
      PorteesLocalData,
      $$PorteesLocalTableFilterComposer,
      $$PorteesLocalTableOrderingComposer,
      $$PorteesLocalTableAnnotationComposer,
      $$PorteesLocalTableCreateCompanionBuilder,
      $$PorteesLocalTableUpdateCompanionBuilder,
      (
        PorteesLocalData,
        BaseReferences<_$AppDatabase, $PorteesLocalTable, PorteesLocalData>,
      ),
      PorteesLocalData,
      PrefetchHooks Function()
    >;
typedef $$LapereauxLocalTableCreateCompanionBuilder =
    LapereauxLocalCompanion Function({
      required String id,
      required String porteeId,
      required String userId,
      required String data,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LapereauxLocalTableUpdateCompanionBuilder =
    LapereauxLocalCompanion Function({
      Value<String> id,
      Value<String> porteeId,
      Value<String> userId,
      Value<String> data,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$LapereauxLocalTableFilterComposer
    extends Composer<_$AppDatabase, $LapereauxLocalTable> {
  $$LapereauxLocalTableFilterComposer({
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

  ColumnFilters<String> get porteeId => $composableBuilder(
    column: $table.porteeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LapereauxLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $LapereauxLocalTable> {
  $$LapereauxLocalTableOrderingComposer({
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

  ColumnOrderings<String> get porteeId => $composableBuilder(
    column: $table.porteeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LapereauxLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $LapereauxLocalTable> {
  $$LapereauxLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get porteeId =>
      $composableBuilder(column: $table.porteeId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LapereauxLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LapereauxLocalTable,
          LapereauxLocalData,
          $$LapereauxLocalTableFilterComposer,
          $$LapereauxLocalTableOrderingComposer,
          $$LapereauxLocalTableAnnotationComposer,
          $$LapereauxLocalTableCreateCompanionBuilder,
          $$LapereauxLocalTableUpdateCompanionBuilder,
          (
            LapereauxLocalData,
            BaseReferences<
              _$AppDatabase,
              $LapereauxLocalTable,
              LapereauxLocalData
            >,
          ),
          LapereauxLocalData,
          PrefetchHooks Function()
        > {
  $$LapereauxLocalTableTableManager(
    _$AppDatabase db,
    $LapereauxLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LapereauxLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LapereauxLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LapereauxLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> porteeId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LapereauxLocalCompanion(
                id: id,
                porteeId: porteeId,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String porteeId,
                required String userId,
                required String data,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LapereauxLocalCompanion.insert(
                id: id,
                porteeId: porteeId,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LapereauxLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LapereauxLocalTable,
      LapereauxLocalData,
      $$LapereauxLocalTableFilterComposer,
      $$LapereauxLocalTableOrderingComposer,
      $$LapereauxLocalTableAnnotationComposer,
      $$LapereauxLocalTableCreateCompanionBuilder,
      $$LapereauxLocalTableUpdateCompanionBuilder,
      (
        LapereauxLocalData,
        BaseReferences<_$AppDatabase, $LapereauxLocalTable, LapereauxLocalData>,
      ),
      LapereauxLocalData,
      PrefetchHooks Function()
    >;
typedef $$PeseesLocalTableCreateCompanionBuilder =
    PeseesLocalCompanion Function({
      required String id,
      required String lapinId,
      required String userId,
      required String data,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$PeseesLocalTableUpdateCompanionBuilder =
    PeseesLocalCompanion Function({
      Value<String> id,
      Value<String> lapinId,
      Value<String> userId,
      Value<String> data,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$PeseesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $PeseesLocalTable> {
  $$PeseesLocalTableFilterComposer({
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

  ColumnFilters<String> get lapinId => $composableBuilder(
    column: $table.lapinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeseesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $PeseesLocalTable> {
  $$PeseesLocalTableOrderingComposer({
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

  ColumnOrderings<String> get lapinId => $composableBuilder(
    column: $table.lapinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeseesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeseesLocalTable> {
  $$PeseesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lapinId =>
      $composableBuilder(column: $table.lapinId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$PeseesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeseesLocalTable,
          PeseesLocalData,
          $$PeseesLocalTableFilterComposer,
          $$PeseesLocalTableOrderingComposer,
          $$PeseesLocalTableAnnotationComposer,
          $$PeseesLocalTableCreateCompanionBuilder,
          $$PeseesLocalTableUpdateCompanionBuilder,
          (
            PeseesLocalData,
            BaseReferences<_$AppDatabase, $PeseesLocalTable, PeseesLocalData>,
          ),
          PeseesLocalData,
          PrefetchHooks Function()
        > {
  $$PeseesLocalTableTableManager(_$AppDatabase db, $PeseesLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeseesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeseesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeseesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lapinId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeseesLocalCompanion(
                id: id,
                lapinId: lapinId,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lapinId,
                required String userId,
                required String data,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeseesLocalCompanion.insert(
                id: id,
                lapinId: lapinId,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeseesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeseesLocalTable,
      PeseesLocalData,
      $$PeseesLocalTableFilterComposer,
      $$PeseesLocalTableOrderingComposer,
      $$PeseesLocalTableAnnotationComposer,
      $$PeseesLocalTableCreateCompanionBuilder,
      $$PeseesLocalTableUpdateCompanionBuilder,
      (
        PeseesLocalData,
        BaseReferences<_$AppDatabase, $PeseesLocalTable, PeseesLocalData>,
      ),
      PeseesLocalData,
      PrefetchHooks Function()
    >;
typedef $$SanteLocalTableCreateCompanionBuilder =
    SanteLocalCompanion Function({
      required String id,
      required String lapinId,
      required String userId,
      required String data,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$SanteLocalTableUpdateCompanionBuilder =
    SanteLocalCompanion Function({
      Value<String> id,
      Value<String> lapinId,
      Value<String> userId,
      Value<String> data,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$SanteLocalTableFilterComposer
    extends Composer<_$AppDatabase, $SanteLocalTable> {
  $$SanteLocalTableFilterComposer({
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

  ColumnFilters<String> get lapinId => $composableBuilder(
    column: $table.lapinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SanteLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $SanteLocalTable> {
  $$SanteLocalTableOrderingComposer({
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

  ColumnOrderings<String> get lapinId => $composableBuilder(
    column: $table.lapinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SanteLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $SanteLocalTable> {
  $$SanteLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lapinId =>
      $composableBuilder(column: $table.lapinId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$SanteLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SanteLocalTable,
          SanteLocalData,
          $$SanteLocalTableFilterComposer,
          $$SanteLocalTableOrderingComposer,
          $$SanteLocalTableAnnotationComposer,
          $$SanteLocalTableCreateCompanionBuilder,
          $$SanteLocalTableUpdateCompanionBuilder,
          (
            SanteLocalData,
            BaseReferences<_$AppDatabase, $SanteLocalTable, SanteLocalData>,
          ),
          SanteLocalData,
          PrefetchHooks Function()
        > {
  $$SanteLocalTableTableManager(_$AppDatabase db, $SanteLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SanteLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SanteLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SanteLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lapinId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SanteLocalCompanion(
                id: id,
                lapinId: lapinId,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lapinId,
                required String userId,
                required String data,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SanteLocalCompanion.insert(
                id: id,
                lapinId: lapinId,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SanteLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SanteLocalTable,
      SanteLocalData,
      $$SanteLocalTableFilterComposer,
      $$SanteLocalTableOrderingComposer,
      $$SanteLocalTableAnnotationComposer,
      $$SanteLocalTableCreateCompanionBuilder,
      $$SanteLocalTableUpdateCompanionBuilder,
      (
        SanteLocalData,
        BaseReferences<_$AppDatabase, $SanteLocalTable, SanteLocalData>,
      ),
      SanteLocalData,
      PrefetchHooks Function()
    >;
typedef $$StocksLocalTableCreateCompanionBuilder =
    StocksLocalCompanion Function({
      required String id,
      required String userId,
      required String data,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$StocksLocalTableUpdateCompanionBuilder =
    StocksLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> data,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$StocksLocalTableFilterComposer
    extends Composer<_$AppDatabase, $StocksLocalTable> {
  $$StocksLocalTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StocksLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $StocksLocalTable> {
  $$StocksLocalTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StocksLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $StocksLocalTable> {
  $$StocksLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$StocksLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StocksLocalTable,
          StocksLocalData,
          $$StocksLocalTableFilterComposer,
          $$StocksLocalTableOrderingComposer,
          $$StocksLocalTableAnnotationComposer,
          $$StocksLocalTableCreateCompanionBuilder,
          $$StocksLocalTableUpdateCompanionBuilder,
          (
            StocksLocalData,
            BaseReferences<_$AppDatabase, $StocksLocalTable, StocksLocalData>,
          ),
          StocksLocalData,
          PrefetchHooks Function()
        > {
  $$StocksLocalTableTableManager(_$AppDatabase db, $StocksLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StocksLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StocksLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocksLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksLocalCompanion(
                id: id,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String data,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksLocalCompanion.insert(
                id: id,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StocksLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StocksLocalTable,
      StocksLocalData,
      $$StocksLocalTableFilterComposer,
      $$StocksLocalTableOrderingComposer,
      $$StocksLocalTableAnnotationComposer,
      $$StocksLocalTableCreateCompanionBuilder,
      $$StocksLocalTableUpdateCompanionBuilder,
      (
        StocksLocalData,
        BaseReferences<_$AppDatabase, $StocksLocalTable, StocksLocalData>,
      ),
      StocksLocalData,
      PrefetchHooks Function()
    >;
typedef $$FinancesLocalTableCreateCompanionBuilder =
    FinancesLocalCompanion Function({
      required String id,
      required String userId,
      required String data,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$FinancesLocalTableUpdateCompanionBuilder =
    FinancesLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> data,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$FinancesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $FinancesLocalTable> {
  $$FinancesLocalTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinancesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancesLocalTable> {
  $$FinancesLocalTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinancesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancesLocalTable> {
  $$FinancesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$FinancesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinancesLocalTable,
          FinancesLocalData,
          $$FinancesLocalTableFilterComposer,
          $$FinancesLocalTableOrderingComposer,
          $$FinancesLocalTableAnnotationComposer,
          $$FinancesLocalTableCreateCompanionBuilder,
          $$FinancesLocalTableUpdateCompanionBuilder,
          (
            FinancesLocalData,
            BaseReferences<
              _$AppDatabase,
              $FinancesLocalTable,
              FinancesLocalData
            >,
          ),
          FinancesLocalData,
          PrefetchHooks Function()
        > {
  $$FinancesLocalTableTableManager(_$AppDatabase db, $FinancesLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancesLocalCompanion(
                id: id,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String data,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancesLocalCompanion.insert(
                id: id,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinancesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinancesLocalTable,
      FinancesLocalData,
      $$FinancesLocalTableFilterComposer,
      $$FinancesLocalTableOrderingComposer,
      $$FinancesLocalTableAnnotationComposer,
      $$FinancesLocalTableCreateCompanionBuilder,
      $$FinancesLocalTableUpdateCompanionBuilder,
      (
        FinancesLocalData,
        BaseReferences<_$AppDatabase, $FinancesLocalTable, FinancesLocalData>,
      ),
      FinancesLocalData,
      PrefetchHooks Function()
    >;
typedef $$AlertesLocalTableCreateCompanionBuilder =
    AlertesLocalCompanion Function({
      required String id,
      required String userId,
      required String data,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$AlertesLocalTableUpdateCompanionBuilder =
    AlertesLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> data,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$AlertesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $AlertesLocalTable> {
  $$AlertesLocalTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertesLocalTable> {
  $$AlertesLocalTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertesLocalTable> {
  $$AlertesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$AlertesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertesLocalTable,
          AlertesLocalData,
          $$AlertesLocalTableFilterComposer,
          $$AlertesLocalTableOrderingComposer,
          $$AlertesLocalTableAnnotationComposer,
          $$AlertesLocalTableCreateCompanionBuilder,
          $$AlertesLocalTableUpdateCompanionBuilder,
          (
            AlertesLocalData,
            BaseReferences<_$AppDatabase, $AlertesLocalTable, AlertesLocalData>,
          ),
          AlertesLocalData,
          PrefetchHooks Function()
        > {
  $$AlertesLocalTableTableManager(_$AppDatabase db, $AlertesLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertesLocalCompanion(
                id: id,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String data,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertesLocalCompanion.insert(
                id: id,
                userId: userId,
                data: data,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertesLocalTable,
      AlertesLocalData,
      $$AlertesLocalTableFilterComposer,
      $$AlertesLocalTableOrderingComposer,
      $$AlertesLocalTableAnnotationComposer,
      $$AlertesLocalTableCreateCompanionBuilder,
      $$AlertesLocalTableUpdateCompanionBuilder,
      (
        AlertesLocalData,
        BaseReferences<_$AppDatabase, $AlertesLocalTable, AlertesLocalData>,
      ),
      AlertesLocalData,
      PrefetchHooks Function()
    >;
typedef $$RacesRefTableCreateCompanionBuilder =
    RacesRefCompanion Function({
      required String id,
      required String data,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$RacesRefTableUpdateCompanionBuilder =
    RacesRefCompanion Function({
      Value<String> id,
      Value<String> data,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$RacesRefTableFilterComposer
    extends Composer<_$AppDatabase, $RacesRefTable> {
  $$RacesRefTableFilterComposer({
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

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RacesRefTableOrderingComposer
    extends Composer<_$AppDatabase, $RacesRefTable> {
  $$RacesRefTableOrderingComposer({
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

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RacesRefTableAnnotationComposer
    extends Composer<_$AppDatabase, $RacesRefTable> {
  $$RacesRefTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$RacesRefTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RacesRefTable,
          RacesRefData,
          $$RacesRefTableFilterComposer,
          $$RacesRefTableOrderingComposer,
          $$RacesRefTableAnnotationComposer,
          $$RacesRefTableCreateCompanionBuilder,
          $$RacesRefTableUpdateCompanionBuilder,
          (
            RacesRefData,
            BaseReferences<_$AppDatabase, $RacesRefTable, RacesRefData>,
          ),
          RacesRefData,
          PrefetchHooks Function()
        > {
  $$RacesRefTableTableManager(_$AppDatabase db, $RacesRefTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RacesRefTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RacesRefTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RacesRefTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RacesRefCompanion(
                id: id,
                data: data,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String data,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => RacesRefCompanion.insert(
                id: id,
                data: data,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RacesRefTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RacesRefTable,
      RacesRefData,
      $$RacesRefTableFilterComposer,
      $$RacesRefTableOrderingComposer,
      $$RacesRefTableAnnotationComposer,
      $$RacesRefTableCreateCompanionBuilder,
      $$RacesRefTableUpdateCompanionBuilder,
      (
        RacesRefData,
        BaseReferences<_$AppDatabase, $RacesRefTable, RacesRefData>,
      ),
      RacesRefData,
      PrefetchHooks Function()
    >;
typedef $$MedicamentsRefTableCreateCompanionBuilder =
    MedicamentsRefCompanion Function({
      required String id,
      required String data,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$MedicamentsRefTableUpdateCompanionBuilder =
    MedicamentsRefCompanion Function({
      Value<String> id,
      Value<String> data,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$MedicamentsRefTableFilterComposer
    extends Composer<_$AppDatabase, $MedicamentsRefTable> {
  $$MedicamentsRefTableFilterComposer({
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

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicamentsRefTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicamentsRefTable> {
  $$MedicamentsRefTableOrderingComposer({
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

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicamentsRefTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicamentsRefTable> {
  $$MedicamentsRefTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$MedicamentsRefTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicamentsRefTable,
          MedicamentsRefData,
          $$MedicamentsRefTableFilterComposer,
          $$MedicamentsRefTableOrderingComposer,
          $$MedicamentsRefTableAnnotationComposer,
          $$MedicamentsRefTableCreateCompanionBuilder,
          $$MedicamentsRefTableUpdateCompanionBuilder,
          (
            MedicamentsRefData,
            BaseReferences<
              _$AppDatabase,
              $MedicamentsRefTable,
              MedicamentsRefData
            >,
          ),
          MedicamentsRefData,
          PrefetchHooks Function()
        > {
  $$MedicamentsRefTableTableManager(
    _$AppDatabase db,
    $MedicamentsRefTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicamentsRefTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicamentsRefTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicamentsRefTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicamentsRefCompanion(
                id: id,
                data: data,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String data,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => MedicamentsRefCompanion.insert(
                id: id,
                data: data,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicamentsRefTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicamentsRefTable,
      MedicamentsRefData,
      $$MedicamentsRefTableFilterComposer,
      $$MedicamentsRefTableOrderingComposer,
      $$MedicamentsRefTableAnnotationComposer,
      $$MedicamentsRefTableCreateCompanionBuilder,
      $$MedicamentsRefTableUpdateCompanionBuilder,
      (
        MedicamentsRefData,
        BaseReferences<_$AppDatabase, $MedicamentsRefTable, MedicamentsRefData>,
      ),
      MedicamentsRefData,
      PrefetchHooks Function()
    >;
typedef $$AlimentsLocauxRefTableCreateCompanionBuilder =
    AlimentsLocauxRefCompanion Function({
      required String id,
      required String data,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$AlimentsLocauxRefTableUpdateCompanionBuilder =
    AlimentsLocauxRefCompanion Function({
      Value<String> id,
      Value<String> data,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$AlimentsLocauxRefTableFilterComposer
    extends Composer<_$AppDatabase, $AlimentsLocauxRefTable> {
  $$AlimentsLocauxRefTableFilterComposer({
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

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlimentsLocauxRefTableOrderingComposer
    extends Composer<_$AppDatabase, $AlimentsLocauxRefTable> {
  $$AlimentsLocauxRefTableOrderingComposer({
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

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlimentsLocauxRefTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlimentsLocauxRefTable> {
  $$AlimentsLocauxRefTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$AlimentsLocauxRefTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlimentsLocauxRefTable,
          AlimentsLocauxRefData,
          $$AlimentsLocauxRefTableFilterComposer,
          $$AlimentsLocauxRefTableOrderingComposer,
          $$AlimentsLocauxRefTableAnnotationComposer,
          $$AlimentsLocauxRefTableCreateCompanionBuilder,
          $$AlimentsLocauxRefTableUpdateCompanionBuilder,
          (
            AlimentsLocauxRefData,
            BaseReferences<
              _$AppDatabase,
              $AlimentsLocauxRefTable,
              AlimentsLocauxRefData
            >,
          ),
          AlimentsLocauxRefData,
          PrefetchHooks Function()
        > {
  $$AlimentsLocauxRefTableTableManager(
    _$AppDatabase db,
    $AlimentsLocauxRefTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlimentsLocauxRefTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlimentsLocauxRefTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlimentsLocauxRefTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlimentsLocauxRefCompanion(
                id: id,
                data: data,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String data,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => AlimentsLocauxRefCompanion.insert(
                id: id,
                data: data,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlimentsLocauxRefTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlimentsLocauxRefTable,
      AlimentsLocauxRefData,
      $$AlimentsLocauxRefTableFilterComposer,
      $$AlimentsLocauxRefTableOrderingComposer,
      $$AlimentsLocauxRefTableAnnotationComposer,
      $$AlimentsLocauxRefTableCreateCompanionBuilder,
      $$AlimentsLocauxRefTableUpdateCompanionBuilder,
      (
        AlimentsLocauxRefData,
        BaseReferences<
          _$AppDatabase,
          $AlimentsLocauxRefTable,
          AlimentsLocauxRefData
        >,
      ),
      AlimentsLocauxRefData,
      PrefetchHooks Function()
    >;
typedef $$DailyAdviceCacheTableCreateCompanionBuilder =
    DailyAdviceCacheCompanion Function({
      required String id,
      required String userId,
      required String content,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$DailyAdviceCacheTableUpdateCompanionBuilder =
    DailyAdviceCacheCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> content,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$DailyAdviceCacheTableFilterComposer
    extends Composer<_$AppDatabase, $DailyAdviceCacheTable> {
  $$DailyAdviceCacheTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyAdviceCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyAdviceCacheTable> {
  $$DailyAdviceCacheTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyAdviceCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyAdviceCacheTable> {
  $$DailyAdviceCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$DailyAdviceCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyAdviceCacheTable,
          DailyAdviceCacheData,
          $$DailyAdviceCacheTableFilterComposer,
          $$DailyAdviceCacheTableOrderingComposer,
          $$DailyAdviceCacheTableAnnotationComposer,
          $$DailyAdviceCacheTableCreateCompanionBuilder,
          $$DailyAdviceCacheTableUpdateCompanionBuilder,
          (
            DailyAdviceCacheData,
            BaseReferences<
              _$AppDatabase,
              $DailyAdviceCacheTable,
              DailyAdviceCacheData
            >,
          ),
          DailyAdviceCacheData,
          PrefetchHooks Function()
        > {
  $$DailyAdviceCacheTableTableManager(
    _$AppDatabase db,
    $DailyAdviceCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyAdviceCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyAdviceCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyAdviceCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyAdviceCacheCompanion(
                id: id,
                userId: userId,
                content: content,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String content,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyAdviceCacheCompanion.insert(
                id: id,
                userId: userId,
                content: content,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyAdviceCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyAdviceCacheTable,
      DailyAdviceCacheData,
      $$DailyAdviceCacheTableFilterComposer,
      $$DailyAdviceCacheTableOrderingComposer,
      $$DailyAdviceCacheTableAnnotationComposer,
      $$DailyAdviceCacheTableCreateCompanionBuilder,
      $$DailyAdviceCacheTableUpdateCompanionBuilder,
      (
        DailyAdviceCacheData,
        BaseReferences<
          _$AppDatabase,
          $DailyAdviceCacheTable,
          DailyAdviceCacheData
        >,
      ),
      DailyAdviceCacheData,
      PrefetchHooks Function()
    >;
typedef $$PlannedEventsTableCreateCompanionBuilder =
    PlannedEventsCompanion Function({
      required String id,
      required String userId,
      required String type,
      Value<String?> targetId,
      required DateTime date,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlannedEventsTableUpdateCompanionBuilder =
    PlannedEventsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> type,
      Value<String?> targetId,
      Value<DateTime> date,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PlannedEventsTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedEventsTable> {
  $$PlannedEventsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlannedEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedEventsTable> {
  $$PlannedEventsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlannedEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedEventsTable> {
  $$PlannedEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlannedEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedEventsTable,
          PlannedEvent,
          $$PlannedEventsTableFilterComposer,
          $$PlannedEventsTableOrderingComposer,
          $$PlannedEventsTableAnnotationComposer,
          $$PlannedEventsTableCreateCompanionBuilder,
          $$PlannedEventsTableUpdateCompanionBuilder,
          (
            PlannedEvent,
            BaseReferences<_$AppDatabase, $PlannedEventsTable, PlannedEvent>,
          ),
          PlannedEvent,
          PrefetchHooks Function()
        > {
  $$PlannedEventsTableTableManager(_$AppDatabase db, $PlannedEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> targetId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedEventsCompanion(
                id: id,
                userId: userId,
                type: type,
                targetId: targetId,
                date: date,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String type,
                Value<String?> targetId = const Value.absent(),
                required DateTime date,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlannedEventsCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                targetId: targetId,
                date: date,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlannedEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedEventsTable,
      PlannedEvent,
      $$PlannedEventsTableFilterComposer,
      $$PlannedEventsTableOrderingComposer,
      $$PlannedEventsTableAnnotationComposer,
      $$PlannedEventsTableCreateCompanionBuilder,
      $$PlannedEventsTableUpdateCompanionBuilder,
      (
        PlannedEvent,
        BaseReferences<_$AppDatabase, $PlannedEventsTable, PlannedEvent>,
      ),
      PlannedEvent,
      PrefetchHooks Function()
    >;
typedef $$PreMiseBasChecklistLocalTableCreateCompanionBuilder =
    PreMiseBasChecklistLocalCompanion Function({
      required String id,
      required String userId,
      required String porteeId,
      required String itemKey,
      required bool checked,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PreMiseBasChecklistLocalTableUpdateCompanionBuilder =
    PreMiseBasChecklistLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> porteeId,
      Value<String> itemKey,
      Value<bool> checked,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PreMiseBasChecklistLocalTableFilterComposer
    extends Composer<_$AppDatabase, $PreMiseBasChecklistLocalTable> {
  $$PreMiseBasChecklistLocalTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get porteeId => $composableBuilder(
    column: $table.porteeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get checked => $composableBuilder(
    column: $table.checked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreMiseBasChecklistLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $PreMiseBasChecklistLocalTable> {
  $$PreMiseBasChecklistLocalTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get porteeId => $composableBuilder(
    column: $table.porteeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get checked => $composableBuilder(
    column: $table.checked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreMiseBasChecklistLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreMiseBasChecklistLocalTable> {
  $$PreMiseBasChecklistLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get porteeId =>
      $composableBuilder(column: $table.porteeId, builder: (column) => column);

  GeneratedColumn<String> get itemKey =>
      $composableBuilder(column: $table.itemKey, builder: (column) => column);

  GeneratedColumn<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PreMiseBasChecklistLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreMiseBasChecklistLocalTable,
          PreMiseBasChecklistLocalData,
          $$PreMiseBasChecklistLocalTableFilterComposer,
          $$PreMiseBasChecklistLocalTableOrderingComposer,
          $$PreMiseBasChecklistLocalTableAnnotationComposer,
          $$PreMiseBasChecklistLocalTableCreateCompanionBuilder,
          $$PreMiseBasChecklistLocalTableUpdateCompanionBuilder,
          (
            PreMiseBasChecklistLocalData,
            BaseReferences<
              _$AppDatabase,
              $PreMiseBasChecklistLocalTable,
              PreMiseBasChecklistLocalData
            >,
          ),
          PreMiseBasChecklistLocalData,
          PrefetchHooks Function()
        > {
  $$PreMiseBasChecklistLocalTableTableManager(
    _$AppDatabase db,
    $PreMiseBasChecklistLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreMiseBasChecklistLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PreMiseBasChecklistLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PreMiseBasChecklistLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> porteeId = const Value.absent(),
                Value<String> itemKey = const Value.absent(),
                Value<bool> checked = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreMiseBasChecklistLocalCompanion(
                id: id,
                userId: userId,
                porteeId: porteeId,
                itemKey: itemKey,
                checked: checked,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String porteeId,
                required String itemKey,
                required bool checked,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PreMiseBasChecklistLocalCompanion.insert(
                id: id,
                userId: userId,
                porteeId: porteeId,
                itemKey: itemKey,
                checked: checked,
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

typedef $$PreMiseBasChecklistLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreMiseBasChecklistLocalTable,
      PreMiseBasChecklistLocalData,
      $$PreMiseBasChecklistLocalTableFilterComposer,
      $$PreMiseBasChecklistLocalTableOrderingComposer,
      $$PreMiseBasChecklistLocalTableAnnotationComposer,
      $$PreMiseBasChecklistLocalTableCreateCompanionBuilder,
      $$PreMiseBasChecklistLocalTableUpdateCompanionBuilder,
      (
        PreMiseBasChecklistLocalData,
        BaseReferences<
          _$AppDatabase,
          $PreMiseBasChecklistLocalTable,
          PreMiseBasChecklistLocalData
        >,
      ),
      PreMiseBasChecklistLocalData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String id,
      required String targetTable,
      required String operation,
      required String payload,
      required String idempotencyKey,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<String> targetTable,
      Value<String> operation,
      Value<String> payload,
      Value<String> idempotencyKey,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                targetTable: targetTable,
                operation: operation,
                payload: payload,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetTable,
                required String operation,
                required String payload,
                required String idempotencyKey,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                targetTable: targetTable,
                operation: operation,
                payload: payload,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LapinsLocalTableTableManager get lapinsLocal =>
      $$LapinsLocalTableTableManager(_db, _db.lapinsLocal);
  $$FertilityScoresLocalTableTableManager get fertilityScoresLocal =>
      $$FertilityScoresLocalTableTableManager(_db, _db.fertilityScoresLocal);
  $$PorteesLocalTableTableManager get porteesLocal =>
      $$PorteesLocalTableTableManager(_db, _db.porteesLocal);
  $$LapereauxLocalTableTableManager get lapereauxLocal =>
      $$LapereauxLocalTableTableManager(_db, _db.lapereauxLocal);
  $$PeseesLocalTableTableManager get peseesLocal =>
      $$PeseesLocalTableTableManager(_db, _db.peseesLocal);
  $$SanteLocalTableTableManager get santeLocal =>
      $$SanteLocalTableTableManager(_db, _db.santeLocal);
  $$StocksLocalTableTableManager get stocksLocal =>
      $$StocksLocalTableTableManager(_db, _db.stocksLocal);
  $$FinancesLocalTableTableManager get financesLocal =>
      $$FinancesLocalTableTableManager(_db, _db.financesLocal);
  $$AlertesLocalTableTableManager get alertesLocal =>
      $$AlertesLocalTableTableManager(_db, _db.alertesLocal);
  $$RacesRefTableTableManager get racesRef =>
      $$RacesRefTableTableManager(_db, _db.racesRef);
  $$MedicamentsRefTableTableManager get medicamentsRef =>
      $$MedicamentsRefTableTableManager(_db, _db.medicamentsRef);
  $$AlimentsLocauxRefTableTableManager get alimentsLocauxRef =>
      $$AlimentsLocauxRefTableTableManager(_db, _db.alimentsLocauxRef);
  $$DailyAdviceCacheTableTableManager get dailyAdviceCache =>
      $$DailyAdviceCacheTableTableManager(_db, _db.dailyAdviceCache);
  $$PlannedEventsTableTableManager get plannedEvents =>
      $$PlannedEventsTableTableManager(_db, _db.plannedEvents);
  $$PreMiseBasChecklistLocalTableTableManager get preMiseBasChecklistLocal =>
      $$PreMiseBasChecklistLocalTableTableManager(
        _db,
        _db.preMiseBasChecklistLocal,
      );
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
