import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/profile.dart';

import '../../service/local_database_service.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  bool adminContext = false;
  bool isAnyMessageUnread = false;

  MainCubit() : super(MainMyStartStop(false));

  Future<void> updateChatRooms(Profile profile, {bool force = false}) async {
    List<ChatRoom> _listLiveChatRoom = await injector.chatRepository.getAllChatRooms();

    List<ChatRoomsLocalData> _listLocalChatRoom = await injector.appDatabase.getLocalChatRooms();

    if (_listLiveChatRoom.isNotEmpty == true || force) {
      _listLiveChatRoom.forEach((element) {
        if (_listLocalChatRoom.isEmpty) {
          injector.appDatabase.insertNewChatRoom(ChatRoomsLocalData(
              roomid: element.id,
              createdat: element.createdAt!,
              latestmsgat: element.latestMessageAt ?? element.createdAt!));
        }
      });
    }

    if (_listLocalChatRoom.isNotEmpty == true &&
        _listLiveChatRoom.length > _listLocalChatRoom.length) {
      if (state is MainMySessions) {
        isAnyMessageUnread = true;
        return emit(MainMySessions(isAnyMessageUnread));
      } else if (state is MainMyProjects) {
        isAnyMessageUnread = true;
        return emit(MainMyProjects(isAnyMessageUnread));
      } else if (state is MainMyCalendars) {
        isAnyMessageUnread = true;
        return emit(MainMyCalendars(isAnyMessageUnread));
      } else if (state is MainMyOffTimes) {
        isAnyMessageUnread = true;
        return emit(MainMyOffTimes(isAnyMessageUnread));
      } else if (state is MainMyStartStop) {
        isAnyMessageUnread = true;
        return emit(MainMyStartStop(isAnyMessageUnread));
      } else if (state is MainEmployees) {
        isAnyMessageUnread = true;
        return emit(MainEmployees(isAnyMessageUnread));
      } else if (state is MainSessions) {
        isAnyMessageUnread = true;
        return emit(MainSessions(isAnyMessageUnread));
      } else if (state is MainOffTimes) {
        isAnyMessageUnread = true;
        return emit(MainOffTimes(isAnyMessageUnread));
      } else if (state is MainProjects) {
        isAnyMessageUnread = true;
        return emit(MainProjects(isAnyMessageUnread));
      } else if (state is MainKiosk) {
        isAnyMessageUnread = true;
        return emit(MainKiosk(isAnyMessageUnread));
      }
    } else if (_listLocalChatRoom.isNotEmpty == true) {
      for (int i = 0; i < _listLiveChatRoom.length; i++) {
        ChatRoomsLocalData? data = await injector.appDatabase.getSingle(_listLiveChatRoom[i].id);

        if (data != null) {
          var list = _listLiveChatRoom[i]
                  .participants
                  ?.where((element) => element.userId == profile.id)
                  .toList() ??
              [];
          var hasAnyNewMessage = false;
          if (list.isNotEmpty) {
            hasAnyNewMessage = list.elementAt(0).newMessage != 0;
          }

          if (hasAnyNewMessage) {
            if (state is MainMySessions) {
              isAnyMessageUnread = true;
              return emit(MainMySessions(isAnyMessageUnread));
            } else if (state is MainMyProjects) {
              isAnyMessageUnread = true;
              return emit(MainMyProjects(isAnyMessageUnread));
            } else if (state is MainMyCalendars) {
              isAnyMessageUnread = true;
              return emit(MainMyCalendars(isAnyMessageUnread));
            } else if (state is MainMyOffTimes) {
              isAnyMessageUnread = true;
              return emit(MainMyOffTimes(isAnyMessageUnread));
            } else if (state is MainMyStartStop) {
              isAnyMessageUnread = true;
              return emit(MainMyStartStop(isAnyMessageUnread));
            } else if (state is MainTasks) {
              isAnyMessageUnread = true;
              return emit(MainTasks(isAnyMessageUnread));
            } else if (state is MainSessions) {
              isAnyMessageUnread = true;
              return emit(MainSessions(isAnyMessageUnread));
            } else if (state is MainOffTimes) {
              isAnyMessageUnread = true;
              return emit(MainOffTimes(isAnyMessageUnread));
            } else if (state is MainProjects) {
              isAnyMessageUnread = true;
              return emit(MainProjects(isAnyMessageUnread));
            } else if (state is MainKiosk) {
              isAnyMessageUnread = true;
              return emit(MainKiosk(isAnyMessageUnread));
            }
          } else {
            if (state is MainMySessions) {
              isAnyMessageUnread = false;
              emit(MainMySessions(isAnyMessageUnread));
            } else if (state is MainMyProjects) {
              isAnyMessageUnread = false;
              emit(MainMyProjects(isAnyMessageUnread));
            } else if (state is MainMyCalendars) {
              isAnyMessageUnread = false;
              emit(MainMyCalendars(isAnyMessageUnread));
            } else if (state is MainMyOffTimes) {
              isAnyMessageUnread = false;
              emit(MainMyOffTimes(isAnyMessageUnread));
            } else if (state is MainMyStartStop) {
              isAnyMessageUnread = false;
              emit(MainMyStartStop(isAnyMessageUnread));
            } else if (state is MainTasks) {
              isAnyMessageUnread = false;
              emit(MainTasks(isAnyMessageUnread));
            } else if (state is MainSessions) {
              isAnyMessageUnread = false;
              emit(MainSessions(isAnyMessageUnread));
            } else if (state is MainOffTimes) {
              isAnyMessageUnread = false;
              emit(MainOffTimes(isAnyMessageUnread));
            } else if (state is MainProjects) {
              isAnyMessageUnread = false;
              emit(MainProjects(isAnyMessageUnread));
            } else if (state is MainKiosk) {
              isAnyMessageUnread = false;
              return emit(MainKiosk(isAnyMessageUnread));
            }
          }
        }
      }
    }
  }

  void navigateTo(int index, bool supervisor, bool isSupervisorCalanderAccess) {
    switch (index) {
      case 5:
        if (state.adminContext == true) {
          openProjects();
        } else {
          emit(MainSettings());
        }
        break;
      case 4:
        if (state.adminContext == true) {
          openCalendars();
        } else {
          emit(MainSettings());
        }
        break;
      case 3:
        if (state.adminContext == true) {
          openCalendars();
        } else {
          openMyCalendars();
        }
        break;
      case 2:
        if (state.adminContext == true) {
          openFiles();
        } else if (state.adminContext == true && supervisor && !isSupervisorCalanderAccess) {
          openFiles(isSupervisorCalanderAccess: isSupervisorCalanderAccess);
        } else {
          openMySessions();
        }
        break;
      case 1:
        if (state.adminContext == true && supervisor && isSupervisorCalanderAccess) {
          openCalendars(
              supervisor: supervisor, isSupervisorCalanderAccess: isSupervisorCalanderAccess);
        } else if (state.adminContext == true && supervisor && !isSupervisorCalanderAccess) {
          openFiles(supervisor: supervisor, isSupervisorCalanderAccess: isSupervisorCalanderAccess);
        } else if (state.adminContext == true) {
          openSessions();
        } else {
          openMyTasks();
        }
        break;
      default:
        if (state.adminContext == true && supervisor)
          openSessions(supervisor: supervisor);
        else if (state.adminContext == true) {
          openTasks();
        } else {
          openMyStartStop();
        }
        break;
    }
  }

  void openMySessions() {
    adminContext = false;
    emit(MainMySessions(isAnyMessageUnread));
  }

  void openMyStartStop() {
    adminContext = false;
    emit(MainMyStartStop(false));
  }

  void openMyOffTimes() {
    adminContext = false;
    emit(MainMyOffTimes(isAnyMessageUnread));
  }

  void openMyProjects() {
    adminContext = false;
    emit(MainMyProjects(isAnyMessageUnread));
  }

  void openMyCalendars() {
    adminContext = false;
    emit(MainMyCalendars(isAnyMessageUnread));
  }

  void openCalendars({bool supervisor = false, bool isSupervisorCalanderAccess = false}) {
    adminContext = true;
    emit(MainCalendars(
        isSupervisor: supervisor, isSupervisorCalanderAccess: isSupervisorCalanderAccess));
  }

  void openEmployees() {
    emit(MainEmployees(isAnyMessageUnread, users: true, invites: false));
  }

  void openMyTasks() {
    emit(MainMyTasks(isAnyMessageUnread));
  }

  void openTasks() {
    emit(MainTasks(isAnyMessageUnread));
  }

  void openInvites() {
    emit(MainEmployees(
      isAnyMessageUnread,
      invites: true,
      users: false,
    ));
  }

  void openSessions({bool supervisor = false}) {
    emit(MainSessions(isAnyMessageUnread, isSupervisor: supervisor));
  }

  void openOffTimes() {
    emit(MainOffTimes(isAnyMessageUnread));
  }

  void openFiles({bool supervisor = false, bool isSupervisorCalanderAccess = false}) {
    emit(MainFiles(
        sessionFiles: true,
        isSupervisor: supervisor,
        isSupervisorCalanderAccess: isSupervisorCalanderAccess));
  }

  void openProjects() {
    emit(MainProjects(isAnyMessageUnread, active: true));
  }

  void openKioskMode() {
    emit(MainKiosk(isAnyMessageUnread, terminals: true, nfc: false));
  }

  void openNfc() {
    emit(MainKiosk(isAnyMessageUnread, terminals: false, nfc: true));
  }

  void tabChanged(int index, {bool supervisor = false}) {
    final MainState s = state;

    if (s is MainTasks) {
      emit(MainTasks(isAnyMessageUnread));
    } else if (s is MainFiles) {
      emit(MainFiles(sessionFiles: index == 0, taskFiles: index == 1, isSupervisor: supervisor));
    } else if (s is MainProjects) {
      emit(MainProjects(isAnyMessageUnread, active: index == 0, archived: index == 1));
    } else if (s is MainKiosk) {
      emit(MainKiosk(isAnyMessageUnread, terminals: index == 0, nfc: index == 1));
    }
  }
}
