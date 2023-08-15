part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();
}

class ChatInitial extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatReady extends ChatState {
  ChatReady(this.chatList);

  final List<ChatRoom> chatList;

  @override
  List<Object?> get props => [chatList];
}

class ChatUserListReady extends ChatState {
  ChatUserListReady(this.chatUsersList);

  final Loadable<List<ChatUser>> chatUsersList;

  @override
  List<Object?> get props => [chatUsersList];
}
