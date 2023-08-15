import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'dart:io';

part 'local_database_service.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [ChatRoomsLocal])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<ChatRoomsLocalData>> getLocalChatRooms() => select(chatRoomsLocal).get();

  Future<List<ChatRoomsLocalData>> getChatRooms(ChatRoomsLocalData data) =>
      (select(chatRoomsLocal)..where((tbl) => tbl.latestmsgat.isSmallerThanValue(data.latestmsgat)))
          .get();

  Stream<List<ChatRoomsLocalData>> watchAllChatRooms() => select(chatRoomsLocal).watch();

  Future insertNewChatRoom(ChatRoomsLocalData order) => into(chatRoomsLocal).insert(order);

  Future updateChatRoom(ChatRoomsLocalData order) => update(chatRoomsLocal).replace(order);

  updateUser(ChatRoomsLocalData order) =>
      (update(chatRoomsLocal)..where((t) => t.roomid.equals(order.roomid))).write(
          ChatRoomsLocalCompanion(
              roomid: Value(order.roomid),
              createdat: Value(order.createdat),
              latestmsgat: Value(order.latestmsgat)));

  Future deleteChatRoom(ChatRoomsLocalData order) => delete(chatRoomsLocal).delete(order);

  Future deleteTable() => delete(chatRoomsLocal).go();

  Future<ChatRoomsLocalData?> getSingle(int roomId) {
    final cartQuery = select(chatRoomsLocal)..where((room) => room.roomid.equals(roomId));

    final roomData = cartQuery.getSingleOrNull();

    return roomData;
  }
}

class ChatRoomsLocal extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  IntColumn get roomid => integer()();

  DateTimeColumn get createdat => dateTime()();

  DateTimeColumn get latestmsgat => dateTime()();

  @override
  Set<Column> get primaryKey => {roomid};
}
