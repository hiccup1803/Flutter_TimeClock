part of 'chat_messages_cubit.dart';

abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();
}

class ChatMessagesInitial extends ChatMessagesState {
  @override
  List<Object> get props => [];
}

class ChatMessagesReady extends ChatMessagesState {
  ChatMessagesReady(this.chatList, this.users);

  final Loadable<List<ChatMessage>> chatList;
  final List<ChatParticipants> users;

  @override
  List<Object?> get props => [chatList, this.users];
}
