// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database_service.dart';

// ignore_for_file: type=lint
class $ChatRoomsLocalTable extends ChatRoomsLocal
    with TableInfo<$ChatRoomsLocalTable, ChatRoomsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatRoomsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roomidMeta = const VerificationMeta('roomid');
  @override
  late final GeneratedColumn<int> roomid = GeneratedColumn<int>(
      'roomid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdatMeta =
      const VerificationMeta('createdat');
  @override
  late final GeneratedColumn<DateTime> createdat = GeneratedColumn<DateTime>(
      'createdat', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _latestmsgatMeta =
      const VerificationMeta('latestmsgat');
  @override
  late final GeneratedColumn<DateTime> latestmsgat = GeneratedColumn<DateTime>(
      'latestmsgat', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, roomid, createdat, latestmsgat];
  @override
  String get aliasedName => _alias ?? 'chat_rooms_local';
  @override
  String get actualTableName => 'chat_rooms_local';
  @override
  VerificationContext validateIntegrity(Insertable<ChatRoomsLocalData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('roomid')) {
      context.handle(_roomidMeta,
          roomid.isAcceptableOrUnknown(data['roomid']!, _roomidMeta));
    }
    if (data.containsKey('createdat')) {
      context.handle(_createdatMeta,
          createdat.isAcceptableOrUnknown(data['createdat']!, _createdatMeta));
    } else if (isInserting) {
      context.missing(_createdatMeta);
    }
    if (data.containsKey('latestmsgat')) {
      context.handle(
          _latestmsgatMeta,
          latestmsgat.isAcceptableOrUnknown(
              data['latestmsgat']!, _latestmsgatMeta));
    } else if (isInserting) {
      context.missing(_latestmsgatMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomid};
  @override
  ChatRoomsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRoomsLocalData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      roomid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}roomid'])!,
      createdat: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}createdat'])!,
      latestmsgat: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}latestmsgat'])!,
    );
  }

  @override
  $ChatRoomsLocalTable createAlias(String alias) {
    return $ChatRoomsLocalTable(attachedDatabase, alias);
  }
}

class ChatRoomsLocalData extends DataClass
    implements Insertable<ChatRoomsLocalData> {
  final int? id;
  final int roomid;
  final DateTime createdat;
  final DateTime latestmsgat;
  const ChatRoomsLocalData(
      {this.id,
      required this.roomid,
      required this.createdat,
      required this.latestmsgat});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['roomid'] = Variable<int>(roomid);
    map['createdat'] = Variable<DateTime>(createdat);
    map['latestmsgat'] = Variable<DateTime>(latestmsgat);
    return map;
  }

  ChatRoomsLocalCompanion toCompanion(bool nullToAbsent) {
    return ChatRoomsLocalCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      roomid: Value(roomid),
      createdat: Value(createdat),
      latestmsgat: Value(latestmsgat),
    );
  }

  factory ChatRoomsLocalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRoomsLocalData(
      id: serializer.fromJson<int?>(json['id']),
      roomid: serializer.fromJson<int>(json['roomid']),
      createdat: serializer.fromJson<DateTime>(json['createdat']),
      latestmsgat: serializer.fromJson<DateTime>(json['latestmsgat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'roomid': serializer.toJson<int>(roomid),
      'createdat': serializer.toJson<DateTime>(createdat),
      'latestmsgat': serializer.toJson<DateTime>(latestmsgat),
    };
  }

  ChatRoomsLocalData copyWith(
          {Value<int?> id = const Value.absent(),
          int? roomid,
          DateTime? createdat,
          DateTime? latestmsgat}) =>
      ChatRoomsLocalData(
        id: id.present ? id.value : this.id,
        roomid: roomid ?? this.roomid,
        createdat: createdat ?? this.createdat,
        latestmsgat: latestmsgat ?? this.latestmsgat,
      );
  @override
  String toString() {
    return (StringBuffer('ChatRoomsLocalData(')
          ..write('id: $id, ')
          ..write('roomid: $roomid, ')
          ..write('createdat: $createdat, ')
          ..write('latestmsgat: $latestmsgat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomid, createdat, latestmsgat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRoomsLocalData &&
          other.id == this.id &&
          other.roomid == this.roomid &&
          other.createdat == this.createdat &&
          other.latestmsgat == this.latestmsgat);
}

class ChatRoomsLocalCompanion extends UpdateCompanion<ChatRoomsLocalData> {
  final Value<int?> id;
  final Value<int> roomid;
  final Value<DateTime> createdat;
  final Value<DateTime> latestmsgat;
  const ChatRoomsLocalCompanion({
    this.id = const Value.absent(),
    this.roomid = const Value.absent(),
    this.createdat = const Value.absent(),
    this.latestmsgat = const Value.absent(),
  });
  ChatRoomsLocalCompanion.insert({
    this.id = const Value.absent(),
    this.roomid = const Value.absent(),
    required DateTime createdat,
    required DateTime latestmsgat,
  })  : createdat = Value(createdat),
        latestmsgat = Value(latestmsgat);
  static Insertable<ChatRoomsLocalData> custom({
    Expression<int>? id,
    Expression<int>? roomid,
    Expression<DateTime>? createdat,
    Expression<DateTime>? latestmsgat,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomid != null) 'roomid': roomid,
      if (createdat != null) 'createdat': createdat,
      if (latestmsgat != null) 'latestmsgat': latestmsgat,
    });
  }

  ChatRoomsLocalCompanion copyWith(
      {Value<int?>? id,
      Value<int>? roomid,
      Value<DateTime>? createdat,
      Value<DateTime>? latestmsgat}) {
    return ChatRoomsLocalCompanion(
      id: id ?? this.id,
      roomid: roomid ?? this.roomid,
      createdat: createdat ?? this.createdat,
      latestmsgat: latestmsgat ?? this.latestmsgat,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomid.present) {
      map['roomid'] = Variable<int>(roomid.value);
    }
    if (createdat.present) {
      map['createdat'] = Variable<DateTime>(createdat.value);
    }
    if (latestmsgat.present) {
      map['latestmsgat'] = Variable<DateTime>(latestmsgat.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomsLocalCompanion(')
          ..write('id: $id, ')
          ..write('roomid: $roomid, ')
          ..write('createdat: $createdat, ')
          ..write('latestmsgat: $latestmsgat')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $ChatRoomsLocalTable chatRoomsLocal = $ChatRoomsLocalTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [chatRoomsLocal];
}
