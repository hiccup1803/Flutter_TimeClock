part of 'main_page.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer(this.profile, this.state);

  final Profile profile;
  final MainState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Drawer(
        child: Theme(
          data: theme.copyWith(
            appBarTheme: theme.appBarTheme.copyWith(
              backgroundColor: Colors.white,
              elevation: 1,
            ),
            listTileTheme: theme.listTileTheme.copyWith(
              selectedColor: theme.colorScheme.secondary,
              selectedTileColor: theme.colorScheme.secondary.withOpacity(0.1),
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(
                    profile.name!,
                    style: TextStyle(color: Colors.black),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.pop(context);
                        Dijkstra.openSettingsPage();
                      },
                    )
                  ],
                ),
              ),
              Material(
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Employee'.i18n),
                    ),
                    ListTile(
                      leading: Icon(Icons.not_started),
                      selected: state is MainMyStartStop,
                      title: Text('Start'.i18n),
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<MainCubit>(context).openMyStartStop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.task),
                      title: Text('My Tasks'.i18n),
                      selected: state is MainMyTasks,
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<MainCubit>(context).openMyTasks();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.widgets),
                      selected: state is MainMySessions,
                      title: Text('My Sessions'.i18n),
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<MainCubit>(context).openMySessions();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('My Calendar'.i18n),
                      selected: state is MainMyCalendars,
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<MainCubit>(context).openMyCalendars();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.beach_access),
                      title: Text('My Off-times'.i18n),
                      selected: state is MainMyOffTimes,
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<MainCubit>(context).openMyOffTimes();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Admin'.i18n),
                    ),
                    if (profile.isSupervisor != true)
                      ListTile(
                        leading: Icon(Icons.group),
                        title: Text('Employees'.i18n),
                        selected: state is MainEmployees,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context).openEmployees();
                        },
                      ),
                    if (profile.isSupervisor != true)
                      ListTile(
                        leading: Icon(Icons.task),
                        title: Text('Tasks'.i18n),
                        selected: state is MainTasks,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context).openTasks();
                        },
                      ),
                    ListTile(
                      leading: Icon(Icons.widgets),
                      title: Text('Sessions'.i18n),
                      selected: state is MainSessions,
                      onTap: () {
                        Navigator.pop(context);
                        BlocProvider.of<MainCubit>(context)
                            .openSessions(supervisor: profile.isSupervisor == true);
                      },
                    ),
                    if (profile.isSupervisor != true)
                      ListTile(
                        leading: Icon(Icons.beach_access),
                        title: Text('Off-times'.i18n),
                        selected: state is MainOffTimes,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context).openOffTimes();
                        },
                      ),
                    if (profile.isSupervisor != true)
                      ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text('Overall Calendar'.i18n),
                        selected: state is MainCalendars,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context).openCalendars();
                        },
                      ),
                    if (profile.isSupervisor != true)
                      ListTile(
                        leading: Icon(Icons.file_copy),
                        title: Text('Files'.i18n),
                        selected: state is MainFiles,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context).openFiles();
                        },
                      ),
                    if (profile.isSupervisor == true && profile.supervisorCalendarAccess == true)
                      ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text('Overall Calendar'.i18n),
                        selected: state is MainCalendars,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context)
                              .openCalendars(supervisor: true, isSupervisorCalanderAccess: true);
                        },
                      ),
                    if (profile.isSupervisor == true && profile.supervisorFilesAccess == true)
                      ListTile(
                        leading: Icon(Icons.file_copy),
                        title: Text('Files'.i18n),
                        selected: state is MainFiles,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context).openFiles(supervisor: true);
                        },
                      ),
                    if (profile.isSupervisor != true)
                      ListTile(
                        leading: Icon(Icons.account_tree),
                        title: Text('Projects Manager'.i18n),
                        selected: state is MainProjects,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context).openProjects();
                        },
                      ),
                    if (profile.isSupervisor != true)
                      ListTile(
                        leading: Icon(Icons.phone_android_rounded),
                        title: Text('KIOSK Mode'.i18n),
                        selected: state is MainKiosk,
                        onTap: () {
                          Navigator.pop(context);
                          BlocProvider.of<MainCubit>(context).openKioskMode();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
