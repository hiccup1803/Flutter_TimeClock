part of 'main_page.dart';

class MainAppBar extends AppBar {
  MainAppBar(MainCubit mainCubit, MainState state, TabController tabController, ThemeData theme)
      : super(
          automaticallyImplyLeading: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: Center(child: AppLogoWidget.small()),
          leadingWidth: 54,
          titleSpacing: 4,
          elevation: 0,
          title: BlocBuilder<ConnectStatusCubit, bool>(
            builder: (context, netStatus) {
              if (netStatus != true) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Offline'.i18n,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox();
            },
          ),
          centerTitle: true,
          bottom: state is MainEmployees
              ? TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  controller: tabController,
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.primary,
                  indicator: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people),
                          SizedBox(width: 8),
                          Text('Employees'.i18n),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium),
                          SizedBox(width: 8),
                          Text('Invitations'.i18n),
                        ],
                      ),
                    ),
                  ],
                )
              : state is MainProjects
                  ? TabBar(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      controller: tabController,
                      tabs: [
                        Tab(child: Text('Active'.i18n)),
                        Tab(child: Text('Archived'.i18n)),
                      ],
                      labelColor: theme.colorScheme.onPrimary,
                      unselectedLabelColor: theme.colorScheme.primary,
                      indicator: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                  : state is MainFiles
                      ? TabBar(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          controller: tabController,
                          tabs: [
                            Tab(child: Text('Work Time'.i18n)),
                            Tab(child: Text('Tasks'.i18n)),
                          ],
                          labelColor: theme.colorScheme.onPrimary,
                          unselectedLabelColor: theme.colorScheme.primary,
                          indicator: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      : state is MainKiosk
                          ? TabBar(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              controller: tabController,
                              tabs: [
                                Tab(child: Text('Terminals'.i18n)),
                                Tab(child: Text('NFC Tags'.i18n)),
                              ],
                              labelColor: theme.colorScheme.onPrimary,
                              unselectedLabelColor: theme.colorScheme.primary,
                              indicator: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                          : null,
          actions: [
            if (state is MainMySessions ||
                state is MainMyOffTimes ||
                state is MainMyStartStop ||
                state is MainMyCalendars ||
                state is MainEmployees ||
                state is MainSessions ||
                state is MainOffTimes ||
                state is MainTasks ||
                state is MainMyTasks ||
                state is MainFiles ||
                state is MainCalendars ||
                state is MainKiosk ||
                state is MainProjects)
              Center(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.comment_outlined,
                        size: 24,
                        color: const Color(0xFF001F7E),
                      ),
                      onPressed: () => Dijkstra.openChatRoomsPage(mainCubit: mainCubit),
                    ),
                    state.isAnyMessageUnread
                        ? Container(
                            margin: EdgeInsets.only(top: 12, right: 8),
                            alignment: Alignment.bottomRight,
                            width: 14,
                            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          )
                        : Container(),
                  ],
                ),
              ),
            if (state is MainSettings) Center(child: SettingsSaveButton()),
            if (state is MainFiles) Container(width: 8),
            if (state is MainFiles) Center(child: FilterFileButton()),
            if (state is MainFiles) Container(width: 8),
            Container(width: 8),
          ],
        );
}