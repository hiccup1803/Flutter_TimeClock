import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/main/chat/chat_cubit.dart';
import 'package:staffmonitor/bloc/main/main_cubit.dart';
import 'package:staffmonitor/model/admin_nfc.dart';
import 'package:staffmonitor/model/admin_off_time.dart';
import 'package:staffmonitor/model/admin_terminal.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/page/main/chat/chat_messages_widget.dart';
import 'package:staffmonitor/page/main/chat/chat_room_list_widget.dart';
import 'package:staffmonitor/page/main/chat/chat_user_list_widget.dart';
import 'package:staffmonitor/page/main/chat/group/chat_create_group_widget.dart';
import 'package:staffmonitor/page/main/chat/group/chat_group_details_widget.dart';
import 'package:staffmonitor/page/off_time/detail_off_time_page.dart';
import 'package:staffmonitor/page/off_time/edit_off_time_page.dart';
import 'package:staffmonitor/page/register/register_employer_page.dart';
import 'package:staffmonitor/page/session/session_map.dart';
import 'package:staffmonitor/page/start/start_page.dart';
import 'package:staffmonitor/page/task/edit/admin/edit_admin_task_page.dart';
import 'package:staffmonitor/page/terminal/edit/edit_admin_terminal_page.dart';
import 'package:staffmonitor/page/terminal/edit/edit_nfc_checkpoint_page.dart';
import 'package:staffmonitor/page/terminal/register_terminal_page.dart';
import 'package:staffmonitor/page/terminal/terminal_page.dart';
import 'package:staffmonitor/page/user/edit_user_page.dart';

import 'injector.dart';
import 'model/admin_session.dart';
import 'model/off_time.dart';
import 'model/profile.dart';
import 'model/session.dart';
import 'page/main/main_page.dart';
import 'page/recover/reset_password_page.dart';
import 'page/register/register_page.dart';
import 'page/session/edit/edit_session_page.dart';
import 'page/session/history/session_history_page.dart';
import 'page/settings/settings_page.dart';
import 'page/sing_in/sign_in_page.dart';
import 'page/splash/splash_page.dart';
import 'page/task/edit/edit_task_page.dart';

const String SPLASH_ROUTE = '/';
const String START_ROUTE = '/start';
const String SIGN_IN_ROUTE = '/sign-in';
const String REGISTER_ROUTE = '/register';
const String REGISTER_TERMINAL_ROUTE = 'register/terminal';
const String REGISTER_EMPLOYER_ROUTE = '/register-employer';
const String RESET_PASSWORD_ROUTE = '/reset';
const String MAIN_ROUTE = '/main';
const String SETTINGS_ROUTE = '/settings';
const String CHAT_ROUTE = '/chat';
const String CHAT_USER_ROUTE = '/chat/users';
const String CHAT_CREATE_GROUP_ROUTE = '/chat/group';
const String CHAT_GROUP_DETAILS_ROUTE = '/chat/group/detail';
const String CHAT_MESSAGES_ROUTE = '/chat/messages';
const String SESSIONS_HISTORY_ROUTE = '/sessions';
const String EDIT_SESSION_ROUTE = '/session/edit';
const String SESSION_MAP_ROUTE = '/session/locations';
const String EDIT_TASK_ROUTE = '/task/edit';
const String EDIT_ADMIN_TASK_ROUTE = '/admin-task/edit';
const String EDIT_OFF_TIME_ROUTE = '/off-time/edit';
const String DETAIL_OFF_TIME_ROUTE = '/off-time/detail';
const String EDIT_USER_ROUTE = '/user/edit';
const String DETAIL_FILE = '/files/detail';
const String DETAIL_FILE_CAROUSEL = '/files/detailCarousel';
const String DETAIL_TASK_FILE = '/files/detailTaskFile';
const String DETAIL_TASK_FILE_CAROUSEL = '/files/detailTaskFileCarousel';
const String EDIT_ADMIN_TERMINAL_ROUTE = '/admin-terminal/edit';
const String EDIT_NFC_ROUTE = '/admin-nfc/edit';

const String TERMINAL_ROUTE = 'terminal';

const String FALLBACK_ROUTE = SPLASH_ROUTE;

Route<dynamic> generateRoute(RouteSettings settings) {
  Logger('generateRoute').fine('name: ${settings.name}');
  switch (settings.name) {
    case MAIN_ROUTE:
      return _getPageRoute(MainPage(), settings);
    case SESSIONS_HISTORY_ROUTE:
      return _getPageRoute(SessionHistoryPage(), settings);
    case EDIT_SESSION_ROUTE:
      return _getPageRoute(EditSessionPage(), settings);
    case EDIT_TASK_ROUTE:
      return _getPageRoute(EditTaskPage(), settings);
    case EDIT_ADMIN_TASK_ROUTE:
      return _getPageRoute(EditAdminTaskPage(), settings);
    case SIGN_IN_ROUTE:
      return _getPageRoute(SignInPage(), settings);
    case REGISTER_ROUTE:
      return _getPageRoute(RegisterPage(), settings);
    case REGISTER_EMPLOYER_ROUTE:
      return _getPageRoute(RegisterEmployerPage(), settings);
    case RESET_PASSWORD_ROUTE:
      return _getPageRoute(ResetPasswordPage(), settings);
    case EDIT_OFF_TIME_ROUTE:
      return _getPageRoute(EditOffTimePage(), settings);
    case DETAIL_OFF_TIME_ROUTE:
      return _getPageRoute(DetailOffTimePage(), settings);
    case EDIT_USER_ROUTE:
      return _getPageRoute(EditUserPage(), settings);
    case SETTINGS_ROUTE:
      return _getPageRoute(SettingsPage(), settings);
    case TERMINAL_ROUTE:
      return _getPageRoute(TerminalPage(), settings);
    case REGISTER_TERMINAL_ROUTE:
      return _getPageRoute(RegisterTerminalPage(), settings);
    case START_ROUTE:
      return _getPageRoute(StartPage(), settings);
    case SESSION_MAP_ROUTE:
      return _getPageRoute(SessionLocationsPage(), settings);
    case CHAT_ROUTE:
      return _getPageRoute(ChatRoomListPage(), settings);
    case CHAT_USER_ROUTE:
      return _getPageRoute(ChatUserListPage(), settings);
    case CHAT_CREATE_GROUP_ROUTE:
      return _getPageRoute(CreateChatGroupPage(), settings);
    case CHAT_GROUP_DETAILS_ROUTE:
      return _getPageRoute(ChatGroupDetailsPage(), settings);
    case CHAT_MESSAGES_ROUTE:
      return _getPageRoute(ChatMessagesPage(), settings);
    case EDIT_ADMIN_TERMINAL_ROUTE:
      return _getPageRoute(EditAdminTerminalPage(), settings);
    case EDIT_NFC_ROUTE:
      return _getPageRoute(EditCheckpointPage(), settings);
    default:
      return _getPageRoute(SplashPage(), settings);
  }
}

PageRoute _getPageRoute(Widget child, RouteSettings settings) {
  var args = settings.arguments;
  if (args is Map<String, dynamic>) {
    if (args.containsKey('slide')) {
      return _SlideRoute(child: child, routeName: settings.name, arguments: args);
    }
  }
  return _FadeRoute(child: child, routeName: settings.name, arguments: args);
}

class _FadeRoute extends PageRouteBuilder {
  final Widget? child;
  final String? routeName;
  final Object? arguments;

  _FadeRoute({this.child, this.routeName, this.arguments})
      : super(
          settings: RouteSettings(name: routeName, arguments: arguments),
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return I18n(child: child!);
          },
          // transitionDuration: Duration(microseconds: 500),
          transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class _SlideRoute extends PageRouteBuilder {
  final Widget? child;
  final String? routeName;
  final Object? arguments;

  _SlideRoute({this.child, this.routeName, this.arguments})
      : super(
          settings: RouteSettings(name: routeName, arguments: arguments),
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return I18n(child: child!);
          },
          transitionDuration: Duration(seconds: 2),
          transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) {
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end);
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class Dijkstra {
  static goBack([dynamic result]) {
    injector.navigationService.navigateBack(result);
  }

  static openSplash() {
    injector.navigationService.navigateTo(SPLASH_ROUTE, replace: true);
  }

  static void openRegisterPage({String? registerCode}) {
    injector.navigationService.navigateTo(
      REGISTER_ROUTE,
      args: RegisterPage.buildArgs(registerCode),
    );
  }

  static openRegisterEmployerPage({String? email, bool replace = false}) {
    injector.navigationService.navigateTo(
      REGISTER_EMPLOYER_ROUTE,
      args: RegisterEmployerPage.buildArgs(email: email),
      replace: replace,
    );
  }

  static void openResetPasswordPage({String? email, String? recoveryToken}) {
    injector.navigationService.navigateTo(
      RESET_PASSWORD_ROUTE,
      args: ResetPasswordPage.buildArgs(email, recoveryToken),
    );
  }

  static void openMainPage() {
    injector.navigationService.navigateTo(MAIN_ROUTE, replace: true);
  }

  static void openSettingsPage() {
    injector.navigationService.navigateTo(SETTINGS_ROUTE);
  }

  static void openChatRoomsPage({MainCubit? mainCubit}) {
    injector.navigationService.navigateTo(CHAT_ROUTE, args: ChatRoomListPage.buildArgs(mainCubit));
  }

  static void openChatUserPage(ChatCubit chatCubit, List<ChatRoom> chatRoomsList,
      {Function([ChatRoom? chatRom])? onChanged}) {
    injector.navigationService
        .navigateTo(CHAT_USER_ROUTE, args: ChatUserListPage.buildArgs(chatCubit, chatRoomsList))
        .then((value) => onChanged?.call());
  }

  static void openCreateChatGroupPage(ChatCubit chatCubit, List<ChatUser> chatUserList) {
    injector.navigationService.navigateTo(CHAT_CREATE_GROUP_ROUTE,
        args: CreateChatGroupPage.buildArgs(chatCubit, chatUserList), replace: true);
  }

  static void openGroupDetailsPage(ChatRoom? chatRoom) {
    injector.navigationService
        .navigateTo(CHAT_GROUP_DETAILS_ROUTE, args: ChatGroupDetailsPage.buildArgs(chatRoom));
  }

  static void openChatMessagesPage(ChatCubit chatCubit, bool isGroup, String toUserName,
      {ChatRoom? chatRoom, ChatUser? chatUser, bool replace = false, Function()? onChanged}) {
    injector.navigationService
        .navigateTo(CHAT_MESSAGES_ROUTE,
            args: ChatMessagesPage.buildArgs(chatCubit, isGroup, toUserName,
                chatUser: chatUser, chatRoom: chatRoom),
            replace: replace)
        .then((value) {
      onChanged?.call();
    });
  }

  static void openSessionsHistory() {
    injector.navigationService.navigateTo(SESSIONS_HISTORY_ROUTE);
  }

  static void createSession({DateTime? initDate, required Function([dynamic session]) onChanged}) {
    injector.navigationService
        .navigateTo(EDIT_SESSION_ROUTE,
            args: EditSessionPage.buildArgs(null, date: initDate, admin: false))
        .then((value) {
      if (value != null) {
        if (value[EditSessionPage.CHANGE_TYPE_KEY] == EditSessionPage.SESSION_CHANGED) {
          onChanged.call(value[EditSessionPage.SESSION_KEY]);
        }
      }
    });
  }

  static void createAdminSession(
      {DateTime? initDate, required Function([dynamic session]) onChanged}) {
    injector.navigationService
        .navigateTo(EDIT_SESSION_ROUTE,
            args: EditSessionPage.buildArgs(null, date: initDate, admin: true))
        .then((value) {
      if (value != null) {
        if (value[EditSessionPage.CHANGE_TYPE_KEY] == EditSessionPage.SESSION_CHANGED) {
          onChanged.call(value[EditSessionPage.SESSION_KEY]);
        } else {
          onChanged.call(value[EditSessionPage.SESSION_KEY]);
        }
      }
    });
  }

  static void editAdminSession(
    AdminSession? session, {
    required Function([AdminSession? session]) onChanged,
    required Function([AdminSession? session]) onDeleted,
  }) {
    injector.navigationService
        .navigateTo(EDIT_SESSION_ROUTE, args: EditSessionPage.buildArgs(session, admin: true))
        .then((value) {
      if (value != null) {
        if (value[EditSessionPage.CHANGE_TYPE_KEY] == EditSessionPage.SESSION_CHANGED) {
          onChanged.call(value[EditSessionPage.SESSION_KEY]);
        } else if (value[EditSessionPage.CHANGE_TYPE_KEY] == EditSessionPage.SESSION_DELETED) {
          onDeleted.call(value[EditSessionPage.SESSION_KEY]);
        }
      }
    });
  }

  static void editSession(
    Session? session, {
    required Function([Session? session]) onChanged,
    required Function([Session? session]) onDeleted,
  }) {
    injector.navigationService
        .navigateTo(EDIT_SESSION_ROUTE, args: EditSessionPage.buildArgs(session))
        .then((value) {
      if (value != null) {
        if (value[EditSessionPage.CHANGE_TYPE_KEY] == EditSessionPage.SESSION_CHANGED) {
          onChanged.call(value[EditSessionPage.SESSION_KEY]);
        } else if (value[EditSessionPage.CHANGE_TYPE_KEY] == EditSessionPage.SESSION_DELETED) {
          onDeleted.call(value[EditSessionPage.SESSION_KEY]);
        }
      }
    });
  }

  static void editTask(
    CalendarTask? task,
    Session? session, {
    Function([Session? session])? onChanged,
    Function([Session? session])? onDeleted,
    bool replace = false,
  }) {
    injector.navigationService
        .navigateTo(EDIT_TASK_ROUTE, args: EditTaskPage.buildArgs(task, session), replace: replace)
        .then((value) {
      onChanged?.call(session);
    });
  }

  static void editAdminTask(
    CalendarTask? task, {
    Function()? onChanged,
    Function(CalendarTask? task)? onDeleted,
  }) {
    injector.navigationService
        .navigateTo(EDIT_ADMIN_TASK_ROUTE, args: EditAdminTaskPage.buildArgs(task))
        .then((value) {
      onChanged?.call();
    });
  }

  static void createAdminTask(
    DateTime day, {
    Function? onChanged,
  }) {
    injector.navigationService
        .navigateTo(EDIT_ADMIN_TASK_ROUTE, args: EditAdminTaskPage.buildArgs(null, date: day))
        .then((value) {
      onChanged?.call();
    });
  }

  static void createAdminTerminal({
    Function? onChanged,
  }) {
    injector.navigationService
        .navigateTo(EDIT_ADMIN_TERMINAL_ROUTE, args: EditAdminTerminalPage.buildArgs(null))
        .then((value) {
      onChanged?.call();
    });
  }

  static void editAdminTerminal(
    AdminTerminal? task, {
    Function()? onChanged,
    Function(AdminTerminal? task)? onDeleted,
  }) {
    injector.navigationService
        .navigateTo(EDIT_ADMIN_TERMINAL_ROUTE, args: EditAdminTerminalPage.buildArgs(task))
        .then((value) {
      onChanged?.call();
    });
  }

  static void editAdminNfc(AdminNfc? nfc,
      {Function()? onChanged, Function([AdminNfc? task])? onDeleted}) {}

  static void createAdminNfc(String i, {
    Function()? onChanged,
  }) {
    injector.navigationService
        .navigateTo(EDIT_NFC_ROUTE, args: EditCheckpointPage.buildArgs(i,null))
        .then((value) {
      onChanged?.call();
    });
  }

  static void editOffTime(
    OffTime offTime, {
    Function(OffTime offTime)? onChanged,
    Function()? onDeleted,
  }) {
    injector.navigationService
        .navigateTo(EDIT_OFF_TIME_ROUTE, args: EditOffTimePage.buildArgs(offTime: offTime))
        .then((value) {
      if (value is OffTime) {
        onChanged?.call(value);
      } else if (value == EditOffTimePage.OFF_TIME_DELETED) {
        onDeleted?.call();
      }
    });
  }

  static void detailOffTime(
    OffTime offTime, {
    Function? onChanged,
    Function? onDeleted,
  }) {
    injector.navigationService
        .navigateTo(DETAIL_OFF_TIME_ROUTE, args: DetailOffTimePage.buildArgs(offTime: offTime))
        .then((value) {
      if (value == DetailOffTimePage.OFF_TIME_CHANGED) {
        onChanged?.call(offTime);
      } else if (value == DetailOffTimePage.OFF_TIME_DELETED) {
        onDeleted?.call(offTime);
      }
    });
  }

  static void createOffTime(
    DateTime day, {
    Function()? onChanged,
  }) {
    injector.navigationService
        .navigateTo(EDIT_OFF_TIME_ROUTE, args: EditOffTimePage.buildArgs(startDay: day))
        .then((value) {
      onChanged?.call();
    });
  }

  static void editAdminOffTime(
    AdminOffTime offTime, {
    Function(AdminOffTime offTime)? onChanged,
    Function()? onDeleted,
  }) {
    injector.navigationService
        .navigateTo(EDIT_OFF_TIME_ROUTE,
            args: EditOffTimePage.buildArgs(offTime: offTime, admin: true))
        .then((value) {
      if (value is AdminOffTime) {
        onChanged?.call(offTime);
      } else if (value == EditOffTimePage.OFF_TIME_DELETED) {
        onDeleted?.call();
      }
    });
  }

  static void createAdminOffTime(
    DateTime day, {
    Function(AdminOffTime)? onChanged,
  }) {
    injector.navigationService
        .navigateTo(EDIT_OFF_TIME_ROUTE,
            args: EditOffTimePage.buildArgs(startDay: day, admin: true))
        .then((value) {
      if (value is AdminOffTime) {
        onChanged?.call(value);
      }
    });
  }

  static void editUser(Profile user, {Function(Profile? user)? onChanged}) {
    injector.navigationService.navigateTo(EDIT_USER_ROUTE, args: EditUserPage.buildArgs(user)).then(
      (value) {
        onChanged?.call(value);
      },
    );
  }

  static void createUser(Function(Profile? user) onChanged) {
    injector.navigationService.navigateTo(EDIT_USER_ROUTE).then(
      (value) {
        onChanged.call(value);
      },
    );
  }

  static void openSignInPage(
      {bool? employee, bool? admin, bool? checkFirstTime, bool replace = false}) async {
    if (checkFirstTime ?? false) {
      if (await injector.appPreferences.isFirstOpen()) {
        if (admin ?? false) {
          openRegisterEmployerPage();
        } else {
          openRegisterPage();
        }
      } else {
        injector.navigationService.navigateTo(SIGN_IN_ROUTE,
            args: SignInPage.buildArgs(employee, admin), replace: replace);
      }
      return;
    }
    injector.navigationService
        .navigateTo(SIGN_IN_ROUTE, args: SignInPage.buildArgs(employee, admin), replace: replace);
  }

  static openTerminalRegistration() {
    injector.navigationService.navigateTo(REGISTER_TERMINAL_ROUTE);
  }

  static openTerminal() {
    injector.navigationService.navigateTo(TERMINAL_ROUTE, replace: true);
  }

  static openSessionLocations(int sessionId, bool admin, [Session? session]) {
    injector.navigationService.navigateTo(SESSION_MAP_ROUTE,
        args: SessionLocationsPage.buildArgs(sessionId, admin, session));
  }
}
