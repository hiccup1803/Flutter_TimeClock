import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/chat_participants.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/repository/chat_repository.dart';

part 'chat_group_state.dart';

class ChatGroupCubit extends Cubit<ChatGroupState> {
  ChatGroupCubit(this._chatRepository) : super(ChatGroupInitial());

  final log = Logger('chatGroupCubit');
  final ChatRepository _chatRepository;

  int roomId = -1;
  Loadable<Paginated<ChatParticipants>> _chatParticipants = Loadable.inProgress();
  Loadable<Paginated<ChatUser>> _chatUsersList = Loadable.inProgress();

  void init(Profile profile, int roomID) {
    roomId = roomID;
    if (roomId > 0) {
      refreshChatParticipants();
      refreshChatUsersList();
    }
  }

  void refreshChatParticipants() {
    _chatParticipants = Loadable.inProgress();
    _updateState();
    _loadChatRooms(1);
  }

  void _loadChatRooms(int page) {
    log.fine('_in loadChatParticipants($page)');

    _chatRepository.getChatParticipants(roomId, page).then(
      (value) {
        if (_chatParticipants.value?.page != null && _chatParticipants.value!.page < value.page) {
          value = _chatParticipants.value! + value;
        }
        if (value.hasMore) {
          _chatParticipants = Loadable.inProgress(value);
          _loadChatRooms(value.page + 1);
        } else {
          _chatParticipants = Loadable.ready(value);
        }
        log.fine('_in list ($value)');
        _updateState();
      },
      onError: (e, stack) {
        log.shout('_chatParticipants', e, stack);
        if (e is AppError) {
          _chatParticipants = Loadable.error(e, _chatParticipants.value);
        } else {
          _chatParticipants = Loadable.error(AppError.from(e), _chatParticipants.value);
        }
        _updateState();
      },
    );
  }

  void refreshChatUsersList() {
    _chatUsersList = Loadable.inProgress();
    _loadChatUsersList(1);
  }

  void _loadChatUsersList(int page) {
    log.fine('_in loadChatUsers($page)');

    _chatRepository.getAvailableChatUser(page).then(
      (value) {
        if (_chatUsersList.value?.page != null && _chatUsersList.value!.page < value.page) {
          value = _chatUsersList.value! + value;
        }
        if (value.hasMore) {
          _chatUsersList = Loadable.inProgress(value);
          _loadChatRooms(value.page + 1);
        } else {
          _chatUsersList = Loadable.ready(value);
        }
        log.fine('_in loadChatUsers ($value)');
        _updateState();
      },
      onError: (e, stack) {
        log.shout('loadChatUsers', e, stack);
        if (e is AppError) {
          _chatUsersList = Loadable.error(e, _chatUsersList.value);
        } else {
          _chatUsersList = Loadable.error(AppError.from(e), _chatUsersList.value);
        }
        _updateState();
      },
    );
  }

  void _updateState() {
    emit(
      ChatGroupReady(_chatParticipants.transform((value) => value.list ?? []),
          _chatUsersList.transform((value) => value.list ?? [])),
    );
  }

  /* Future<ChatRoom> _createSingleChatRoom() {
    return _chatRepository.createChatRoom(roomName, 0, chatUsers);
  }*/

  Future<bool> addChatParticipant(int userId) async {
    await _chatRepository.createChatParticipant(roomId, userId).then((value) {
      refreshChatParticipants();
    });
    return true;
  }

  Future<bool> deleteChatParticipant(int participantId) async {
    await _chatRepository.deleteChatParticipant(roomId, participantId).then((value) {
      refreshChatParticipants();
    });
    return true;
  }

  Future<bool> deleteChatRoom() async {
    await _chatRepository.deleteChatRoom(roomId).then((value) {
      refreshChatParticipants();
    });
    return true;
  }
}
