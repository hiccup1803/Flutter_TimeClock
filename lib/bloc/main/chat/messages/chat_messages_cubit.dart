import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_message.dart';
import 'package:staffmonitor/model/chat_participants.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/repository/chat_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';

part 'chat_messages_state.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  ChatMessagesCubit(this._chatRepository, this._usersRepository) : super(ChatMessagesInitial());

  final log = Logger('chatMessagesCubit');
  final ChatRepository _chatRepository;
  final UsersRepository _usersRepository;

  bool isGroup = false;
  int roomId = -1;
  Loadable<Paginated<ChatMessage>> _chatMessages = Loadable.inProgress();
  Loadable<List<Profile>?> users = Loadable.ready(null);
  List<ChatParticipants> listUsers = [];
  ChatUser? toUser;
  ChatUser? fromUser;

  late Timer _timer;

  void init(bool group, Profile profile, {ChatUser? paramChatUser, ChatRoom? chatRoom}) {
    isGroup = group;
    if (chatRoom != null) {
      roomId = chatRoom.id;
      if (listUsers.isEmpty == true) {
        _chatRepository.getAllChatParticipants(roomId).then((value) {
          listUsers = value;
        });
      }
    } else if (paramChatUser != null && chatRoom == null) {
      toUser = paramChatUser;
      fromUser = new ChatUser(profile.id, profile.name ?? '');
    }
    if (roomId >= 0) {
      //for first time immediately
      Future.delayed(Duration(seconds: 1)).then((value) => getAllChatMessages(roomId));
      _getPeriodicData(5);
    } else {
      _chatMessages = Loadable.ready(null);
      _updateState();
    }
  }

  void _getPeriodicData(int sec) {
    _timer = Timer.periodic(Duration(seconds: sec), (_) => getAllChatMessages(roomId));
  }

  Future<Paginated<ChatMessage>> getAllChatMessages(int roomId) async {
    late Paginated<ChatMessage> paginated;
    int page = 0;
    do {
      final result = await _chatRepository.getChatMessages(roomId, ++page);
      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
      _chatMessages = Loadable.ready(paginated);
      _updateState();
    } while (paginated.hasMore);

    return paginated;
  }

  void _updateState() {
    emit(ChatMessagesReady(_chatMessages.transform((value) => value.list ?? []), listUsers));
  }

  Future<ChatRoom> _createSingleChatRoom() {
    String roomName = fromUser!.name.toString() + ' - ' + toUser!.name.toString();
    List<int> chatUsers = List.empty(growable: true);
    chatUsers.add(fromUser!.id);
    chatUsers.add(toUser!.id);
    return _chatRepository.createChatRoom(roomName, 0, chatUsers);
  }

  Future<bool> sendMessage(String msg) async {
    if (roomId >= 0) {
      _chatRepository.createChatMessage(roomId, msg).then((value) {
        emit(ChatMessagesReady(_chatMessages.transform((value) => value.list ?? []), listUsers));
        return true;
      }).onError((error, stackTrace) {
        return false;
      });
    } else {
      ChatRoom chatRoom = await _createSingleChatRoom();
      roomId = chatRoom.id;
      _chatRepository.createChatMessage(roomId, msg).then((value) {
        if (!_timer.isActive) {
          _getPeriodicData(3);
        }
        return true;
      }).onError((error, stackTrace) {
        return false;
      });
    }
    return true;
  }

  @override
  Future<void> close() {
    // TODO: implement close
    if (_timer.isActive) _timer.cancel();
    return super.close();
  }
}
