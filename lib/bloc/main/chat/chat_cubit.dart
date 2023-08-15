import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/repository/chat_repository.dart';

import '../../../service/local_database_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._chatRepository) : super(ChatInitial());

  final log = Logger('chatCubit');
  final ChatRepository _chatRepository;

  late List<ChatRoom> _chatRooms = List.empty();
  Loadable<Paginated<ChatUser>> _chatUsersList = Loadable.inProgress();

  void init(bool isChatRoom) {
    if (isChatRoom) {
      refreshChatRooms();
    } else {
      refreshChatUsersList();
    }
  }

  void refreshChatRooms() {
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    await injector.chatRepository.getAllChatRooms().then((value) {
      _chatRooms = value;
      _updateState();
    });
  }

  void refreshChatUsersList() {
    _chatUsersList = Loadable.inProgress();
    _updateChatUsersState();
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
          _loadChatUsersList(value.page + 1);
        } else {
          _chatUsersList = Loadable.ready(value);
        }
        log.fine('_in loadChatUsers ($value)');
        _updateChatUsersState();
      },
      onError: (e, stack) {
        log.shout('loadChatUsers', e, stack);
        if (e is AppError) {
          _chatUsersList = Loadable.error(e, _chatUsersList.value);
        } else {
          _chatUsersList = Loadable.error(AppError.from(e), _chatUsersList.value);
        }
        _updateChatUsersState();
      },
    );
  }

  Future<void> _updateState() async {
    await injector.appDatabase.deleteTable();

    if (_chatRooms.isNotEmpty == true) {
      _chatRooms.forEach((element) {
        injector.appDatabase.insertNewChatRoom(ChatRoomsLocalData(
            roomid: element.id,
            createdat: element.createdAt!,
            latestmsgat: element.latestMessageAt ?? element.createdAt!));
      });
    }

    emit(
      ChatReady(_chatRooms),
    );
  }

  void _updateChatUsersState() {
    emit(
      ChatUserListReady(_chatUsersList.transform((value) => value.list ?? [])),
    );
  }

  Future<ChatRoom> createGroupChatRoom(String name, int group, List<int> users) {
    return _chatRepository.createChatRoom(name, group, users);
  }
}