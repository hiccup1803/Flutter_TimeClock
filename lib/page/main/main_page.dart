import 'dart:core';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/connect/connect_status_cubit.dart';
import 'package:staffmonitor/bloc/history/history_cubit.dart';
import 'package:staffmonitor/bloc/main/break/session_break_cubit.dart';
import 'package:staffmonitor/bloc/main/calendars/admin/calendars_cubit.dart';
import 'package:staffmonitor/bloc/main/calendars/filter/filter_cubit.dart';
import 'package:staffmonitor/bloc/main/calendars/my_calendars_cubit.dart';
import 'package:staffmonitor/bloc/main/chat/chat_cubit.dart';
import 'package:staffmonitor/bloc/main/employees/employees_cubit.dart';
import 'package:staffmonitor/bloc/main/files/admin_files_cubit.dart';
import 'package:staffmonitor/bloc/main/kiosk/admin/admin_nfc_cubit.dart';
import 'package:staffmonitor/bloc/main/main_cubit.dart';
import 'package:staffmonitor/bloc/main/off_time/my_off_times_cubit.dart';
import 'package:staffmonitor/bloc/main/projects/admin/admin_projects_cubit.dart';
import 'package:staffmonitor/bloc/main/projects/my_projects_cubit.dart';
import 'package:staffmonitor/bloc/main/sessions/my_sessions_cubit.dart';
import 'package:staffmonitor/bloc/main/settings/settings_cubit.dart';
import 'package:staffmonitor/bloc/main/tasks/admin/admin_tasks_cubit.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/employees/create_invitation_bottom_sheet.dart';
import 'package:staffmonitor/page/main/admin/taks/admin_tasks_widget.dart';
import 'package:staffmonitor/page/main/my_start_stop/my_start_stop_widget.dart';
import 'package:staffmonitor/page/main/my_tasks/my_tasks_widget.dart';
import 'package:staffmonitor/page/settings/settings_form.dart';
import 'package:staffmonitor/widget/app_logo_widget.dart';
import 'package:staffmonitor/widget/dialog/own_project_dialog.dart';

import '../../bloc/main/kiosk/admin/admin_terminals_cubit.dart';
import '../../bloc/notifications/notifications_cubit.dart';
import '../../dijkstra.dart';
import '../../injector.dart';
import 'admin/calendars/calendar_widget.dart';
import 'admin/employees/employees_widget.dart';
import 'admin/files/admin_files_widget.dart';
import 'admin/kiosk/admin_terminals_widget.dart';
import 'admin/off_times/admin_off_times_widget.dart';
import 'admin/projects/admin_projects_widget.dart';
import 'admin/sessions/admin_sessions_widget.dart';
import 'main.i18n.dart';
import 'my_calendars/my_calendar_widget.dart';
import 'my_off_times/my_off_times_widget.dart';
import 'my_projects/my_projects_widget.dart';
import 'my_sessions/my_sessions_widget.dart';
import 'settings/settings_widget.dart';

part 'main_app_bar.dart';

part 'main_bottom_bar.dart';

part 'main_drawer.dart';

part 'main_fab.dart';

class MainPage extends BasePageWidget {
  final MainCubit mainCubit = MainCubit();
  final ChatCubit chatCubit = ChatCubit(injector.chatRepository);

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    if (profile == null) {
      return Container();
    }
    BlocProvider.of<NotificationsCubit>(context).initListeners();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: mainCubit..updateChatRooms(profile),
        ),
        BlocProvider<MySessionsCubit>(
          create: (context) => MySessionsCubit(
            injector.sessionsRepository,
            injector.projectsRepository,
            injector.geolocationService,
            BlocProvider.of<AuthCubit>(context),
          )..init(
              trackGPS: const bool.fromEnvironment('always_track_gps') || profile.trackGps,
            ),
        ),
        BlocProvider<SessionBreakCubit>(
            create: (context) => SessionBreakCubit(injector.sessionBreakRepository)),
        BlocProvider<MyProjectsCubit>(
          create: (context) => MyProjectsCubit(
            injector.projectsRepository,
            DateTime.now(),
          ),
          lazy: true,
        ),
        BlocProvider<MyCalendarsCubit>(
          create: (context) => MyCalendarsCubit(
            injector.projectsRepository,
            injector.offTimesRepository,
            injector.sessionsRepository,
            MyOffTimesWidget.mapListToDates,
            DateTime.now(),
          )..init(DateTime.now()),
          lazy: true,
        ),
        BlocProvider<CalendarsCubit>(
          create: (context) => CalendarsCubit(
            injector.projectsRepository,
            injector.offTimesRepository,
            injector.sessionsRepository,
            MyOffTimesWidget.mapListToDates,
            DateTime.now(),
          )..init(DateTime.now()),
          lazy: true,
        ),
        BlocProvider<HistoryCubit>(
          create: (context) => HistoryCubit(
            injector.offTimesRepository,
            injector.networkStatusService,
            MyOffTimesWidget.mapListToDates,
          )..init(DateTime.now()),
          lazy: true,
        ),
        BlocProvider<MyOffTimesCubit>(
          create: (context) =>
              MyOffTimesCubit(injector.offTimesRepository)..init(DateTime.now().year),
          lazy: true,
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(
            BlocProvider.of<AuthCubit>(context),
            injector.profileRepository,
            injector.usersRepository,
            injector.profileCompanyRepository,
          ),
          lazy: true,
        ),
        BlocProvider<EmployeesCubit>(
          create: (context) => EmployeesCubit(
            injector.invitationRepository,
            injector.usersRepository,
          ),
          lazy: true,
        ),
        BlocProvider(
          create: (context) => AdminProjectsCubit(
            injector.projectsRepository,
            injector.usersRepository,
            injector.profileCompanyRepository,
          )..refresh(),
          lazy: true,
        ),
        BlocProvider(
          create: (context) => AdminTerminalsCubit(
            injector.terminalRepository,
            injector.usersRepository,
          )..refresh(),
          lazy: true,
        ),
        BlocProvider(
          create: (context) => AdminNfcCubit(
            injector.nfcRepository,
            injector.usersRepository,
          )..refresh(),
          lazy: true,
        ),
        BlocProvider(
          create: (context) => AdminFilesCubit(
            injector.filesRepository,
          )..refresh(),
          lazy: true,
        ),
        BlocProvider<AdminTasksCubit>(
          create: (context) => AdminTasksCubit(
            injector.projectsRepository,
            DateTime.now(),
          )..init(DateTime.now()),
          lazy: true,
        ),
        BlocProvider<FilterCubit>(create: (context) => FilterCubit()..init(), lazy: false),
      ],
      child: MainScaffold(profile, mainCubit),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold(this.profile, this.mainCubit);

  final Profile profile;
  final MainCubit mainCubit;

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TickerProviderStateMixin {
  final log = Logger('MainScaffold');
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(onTabChange);
    var _netStatus = BlocProvider.of<ConnectStatusCubit>(context).state;
    if (_netStatus) {
      _uploadOfflineAndRefresh();
    }
    // init();
  }

  void _uploadOfflineAndRefresh() {
    BlocProvider.of<MySessionsCubit>(context).uploadSaveData().then((value) {
      BlocProvider.of<MySessionsCubit>(context).refresh(force: true);
    });
  }

  @override
  void dispose() {
    tabController.removeListener(onTabChange);
    tabController.dispose();
    super.dispose();
  }

  void onTabChange() {
    BlocProvider.of<MainCubit>(context)
        .tabChanged(tabController.index, supervisor: widget.profile.isSupervisor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ConnectStatusCubit, bool>(
      listenWhen: (prevStatus, currentStatus) => prevStatus == false && currentStatus == true,
      listener: (context, netStatus) {
        if (netStatus) {
          _uploadOfflineAndRefresh();
        }
      },
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          ThemeData barTheme = theme;
          if (state.adminContext) {
            barTheme = theme.copyWith(
              appBarTheme: theme.appBarTheme.copyWith(
                color: theme.primaryColorLight,
                elevation: 0,
              ),
              bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
                backgroundColor: theme.primaryColorLight,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white60,
              ),
            );
          }
          return Theme(
            data: barTheme,
            child: Scaffold(
              appBar: MainAppBar(widget.mainCubit, state, tabController, theme),
              floatingActionButton: MainFab(state),
              bottomNavigationBar: MainBottomBar(
                  widget.profile.isAdmin == true,
                  widget.profile.isSupervisor == true,
                  widget.profile.supervisorFilesAccess,
                  widget.profile.supervisorCalendarAccess,
                  state),
              endDrawer: widget.profile.isAdmin == true ? MainDrawer(widget.profile, state) : null,
              body: MainWidget(widget.profile, state, tabController),
            ),
          );
        },
      ),
    );
  }
}

class MainWidget extends StatelessWidget {
  final Profile profile;
  final MainState state;
  final TabController tabController;

  const MainWidget(this.profile, this.state, this.tabController);

  @override
  Widget build(BuildContext context) {
    if (state is MainSettings) {
      return SettingsWidget(profile);
    }
    if (state is MainSettings) {
      return SettingsWidget(profile);
    }
    if (state is MainMyProjects) {
      BlocProvider.of<MyProjectsCubit>(context).refresh();
      return MyProjectsWidget(profile.preferredProjects, profile.allowWageView == true);
    }

    if (state is MainMyCalendars) {
      BlocProvider.of<MyCalendarsCubit>(context).refreshOffTime();
      return MyCalendarsWidget(profile.preferredProjects, profile.allowWageView == true);
    }

    if (state is MainCalendars) {
      BlocProvider.of<MyCalendarsCubit>(context).refreshOffTime();
      return MainCalendarsWidget(profile.preferredProjects, profile.allowWageView == true);
    }

    if (state is MainMyOffTimes) {
      BlocProvider.of<MyOffTimesCubit>(context).refresh();
      return MyOffTimesWidget();
    }
    if (state is MainMySessions) {
      BlocProvider.of<MySessionsCubit>(context).refresh(force: true);
      return MySessionsWidget(profile);
    }
    if (state is MainMyTasks) {
      return MyTasksWidget(profile);
    }
    if (state is MainMyStartStop) {
      BlocProvider.of<MySessionsCubit>(context).refresh(force: true);
      return Theme(
        data: Theme.of(context).copyWith(
          primaryColor: const Color(0xFF001F7E),
          colorScheme: ThemeData.light().colorScheme.copyWith(
                secondary: const Color(0xFF27B594),
              ),
          scaffoldBackgroundColor: Colors.white,
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          buttonTheme: const ButtonThemeData(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: const Color(0xFFC21717),
            selectionColor: const Color(0xFFC21717).withOpacity(0.2),
            selectionHandleColor: const Color(0xFFC21717),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Color(0xFF3A3A3A)),
            actionsIconTheme: IconThemeData(color: Color(0xFF3A3A3A)),
            iconTheme: IconThemeData(
              color: Color(0xFF3A3A3A),
            ),
          ),
          textTheme: ThemeData.light().textTheme.copyWith(
                headline1: const TextStyle(color: Color(0xFF3A3A3A)),
                headline2: const TextStyle(color: Color(0xFF6A6A6A)),
                headline3: const TextStyle(color: Color(0xFF9A9A9A)),
                headline4: const TextStyle(color: Color(0xFFF1F1F1)),
                headline5: const TextStyle(color: Color(0xFFF8F8F8)),
                headline6: const TextStyle(color: Colors.black),
              ),
        ),
        child: MyStartStopWidget(profile),
      );
    }
    if (state is MainInitial) {
      return Container();
    }
    if (state is MainTasks) {
      return AdminTasksWidget(profile);
    }
    if (state is MainEmployees) {
      BlocProvider.of<EmployeesCubit>(context).refresh();
      return EmployeesWidget(tabController);
    }
    if (state is MainSessions) {
      return AdminSessionsWidget(profile);
    }
    if (state is MainOffTimes) {
      return AdminOffTimesWidget();
    }
    if (state is MainFiles) {
      return AdminFilesWidget(tabController);
    }
    if (state is MainProjects) {
      BlocProvider.of<AdminProjectsCubit>(context).refresh();
      return AdminProjectsWidget(tabController);
    }
    if (state is MainKiosk) {
      BlocProvider.of<AdminTerminalsCubit>(context).refresh();
      return AdminTerminalWidget(tabController);
    }

    return Center(
      child: Text('404'),
    );
  }
}
