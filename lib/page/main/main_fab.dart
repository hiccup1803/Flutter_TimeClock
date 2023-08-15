part of 'main_page.dart';

class MainFab extends StatelessWidget {
  const MainFab(this.state);

  final MainState state;

  @override
  Widget build(BuildContext context) {
    if (state is MainMySessions) {
      return FloatingActionButton(
        onPressed: () {
          Dijkstra.createSession(onChanged: ([_]) {
            BlocProvider.of<MySessionsCubit>(context).refresh(force: true);
          });
        },
        child: Icon(Icons.add),
      );
    }
    if (state is MainEmployees) {
      final s = state as MainEmployees;

      void createInvite() {
        CreateInvitationBottomSheet.show(context: context).then((invite) {
          if (invite != null) {
            BlocProvider.of<EmployeesCubit>(context).onInviteCreated(invite);
          }
        });
      }

      void createUser() {
        Dijkstra.createUser((user) {
          BlocProvider.of<EmployeesCubit>(context).onUserChanged(user);
        });
      }

      return FloatingActionButton(
        onPressed: s.users == true ? createUser : createInvite,
        child: Icon(s.users == true ? Icons.person_add : Icons.playlist_add),
      );
    }
    if (state is MainOffTimes) {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Dijkstra.createAdminOffTime(DateTime.now(), onChanged: (offTime) {
          BlocProvider.of<MyOffTimesCubit>(context).refresh();
        }),
      );
    }
    if (state is MainMyOffTimes) {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Dijkstra.createOffTime(DateTime.now(), onChanged: () {
          BlocProvider.of<MyOffTimesCubit>(context).refresh();
        }),
      );
    }
    if (state is MainProjects) {
      final s = state as MainProjects;
      if (s.active)
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            OwnProjectDialog.show(context: context).then((project) {
              if (project != null)
                BlocProvider.of<AdminProjectsCubit>(context)
                    .addNewProject(context, project.name, project.color);
            });
          },
        );
    }
    if (state is MainKiosk) {
      final s = state as MainKiosk;
      if (s.terminals == true) {
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Dijkstra.createAdminTerminal(onChanged: () {
              BlocProvider.of<AdminTerminalsCubit>(context).refresh();
            });
          },
        );
      } else {
        return Container();
      }
    }
    if (state is MainCalendars) {
      return FloatingActionButton(
        onPressed: () {
          Dijkstra.createAdminTask(DateTime.now(), onChanged: () {
            BlocProvider.of<CalendarsCubit>(context).init(DateTime.now());
          });
        },
        child: Icon(Icons.add),
      );
    }
    if (state is MainTasks) {
      return FloatingActionButton(
        onPressed: () {
          Dijkstra.createAdminTask(DateTime.now(), onChanged: () {
            BlocProvider.of<AdminTasksCubit>(context).init(DateTime.now());
          });
        },
        child: Icon(Icons.add),
      );
    }
    if (state is MainSessions) {
      return FloatingActionButton(
        onPressed: () {
          Dijkstra.createAdminSession(onChanged: ([_]) {
            BlocProvider.of<MySessionsCubit>(context).refresh(force: true);
          });
        },
        child: Icon(Icons.add),
      );
    }
    return Container();
  }
}
