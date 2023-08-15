part of 'main_page.dart';

class MainBottomBar extends StatelessWidget {
  MainBottomBar(this.userIsAdmin, this.userIsSupervisor, this.isSupervisorFileAccess,
      this.isSupervisorCalanderAccess, this.stateMain);

  final MainState stateMain;
  final bool userIsAdmin;
  final bool userIsSupervisor;
  final bool isSupervisorFileAccess;
  final bool isSupervisorCalanderAccess;
  final log = Logger('AppNavigationBottomBar');

  @override
  Widget build(BuildContext context) {
    final bool isAdminContext = userIsAdmin == true && stateMain.adminContext == true;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: stateMain.selected,
      onTap: (value) {
        log.finer('onTap: $value, $isAdminContext, $userIsAdmin');
        if (isAdminContext && value > 0 && userIsSupervisor) {
          if ((value == 1 && isSupervisorFileAccess == false) ||
              (value == 3 && isSupervisorFileAccess == true)) {
            Scaffold.of(context).openEndDrawer();
          } else {
            BlocProvider.of<MainCubit>(context)
                .navigateTo(value, userIsSupervisor, isSupervisorCalanderAccess);
          }
        } else if ((isAdminContext && value == 4) ||
            (isAdminContext == false && userIsAdmin == true && value == 4)) {
          Scaffold.of(context).openEndDrawer();
        } else {
          log.fine('navigateTo($value)');
          BlocProvider.of<MainCubit>(context)
              .navigateTo(value, userIsSupervisor, isSupervisorCalanderAccess);
        }
      },
      showUnselectedLabels: true,
      items: [
        if (isAdminContext == true && userIsSupervisor != true)
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks'.i18n,
          ),
        if (isAdminContext != true)
          BottomNavigationBarItem(
            icon: Icon(Icons.not_started),
            label: 'Start'.i18n,
          ),
        if (isAdminContext != true)
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks'.i18n,
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_rounded),
          label: 'Sessions'.i18n,
        ),
        if (isAdminContext == true && userIsSupervisor != true)
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy),
            label: 'Files'.i18n,
          ),
        if (isAdminContext == true && userIsSupervisor != true)
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar'.i18n,
          ),
        if (isAdminContext == true &&
            (userIsSupervisor == true && isSupervisorCalanderAccess == true))
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar'.i18n,
          ),
        if (isAdminContext != true)
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar'.i18n,
          ),
        if (userIsAdmin != true)
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings'.i18n,
          ),
        if (isAdminContext == true && (userIsSupervisor == true && isSupervisorFileAccess == true))
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_rounded),
            label: 'Files'.i18n,
          ),
        if (userIsAdmin == true)
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu'.i18n,
          ),
      ],
    );
  }
}
