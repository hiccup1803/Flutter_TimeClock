import 'package:equatable/equatable.dart';

class ChatRoomLocal extends Equatable {
  final int id;
  final DateTime? createdAt;
  final DateTime? latestMessageAt;

  const ChatRoomLocal(this.id, this.createdAt, this.latestMessageAt);

  @override
  String toString() =>
      'ChatRoomLocal{id: $id,createdAt: $createdAt,latestMessageAt: $latestMessageAt}';

  @override
  // TODO: implement props
  List<Object?> get props => [this.id, this.createdAt, this.latestMessageAt];
}
