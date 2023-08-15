part of 'chat_group_cubit.dart';

abstract class ChatGroupState extends Equatable {
  const ChatGroupState();
}

class ChatGroupInitial extends ChatGroupState {
  @override
  List<Object> get props => [];
}

class ChatGroupReady extends ChatGroupState {
  ChatGroupReady(this.chatParticipantList, this.chatUsersList);

  final Loadable<List<ChatParticipants>> chatParticipantList;
  final Loadable<List<ChatUser>> chatUsersList;

  @override
  List<Object?> get props => [chatParticipantList, chatUsersList];
}
