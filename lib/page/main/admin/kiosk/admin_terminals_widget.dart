import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/main_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/admin_terminal.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/kiosk/nfc/admin_nfc_widget.dart';
import '../../../../bloc/main/kiosk/admin/admin_terminals_cubit.dart';
import 'admin_terminals_widget.i18n.dart';

class AdminTerminalWidget extends StatelessWidget {
  const AdminTerminalWidget(this.tabController);

  final TabController tabController;

  @override
  Widget build(BuildContext context) {

    tabController.addListener(() {
      if (tabController.index == 1) {
        BlocProvider.of<MainCubit>(context).openNfc();
      } else if (tabController.index == 0) {
        BlocProvider.of<MainCubit>(context).openKioskMode();
      }
    });

    final theme = Theme.of(context);
    return SafeArea(
      child: TabBarView(
        controller: tabController,
        children: [
          _TerminalsList(terminals: (state) => state.terminals.value ?? []),
          NfcWidget(),
        ],
      ),
    );
  }
}

class _TerminalsList extends StatefulWidget {
  const _TerminalsList({Key? key, required this.terminals}) : super(key: key);

  final List<AdminTerminal> Function(AdminTerminalsReady state) terminals;

  @override
  State<_TerminalsList> createState() => _TerminalsListState();
}

class _TerminalsListState extends State<_TerminalsList> {
  void onEditTerminalChange() {
    BlocProvider.of<AdminTerminalsCubit>(context).refresh();
  }

  void onEditTerminalDeleted([AdminTerminal? task]) {
    BlocProvider.of<AdminTerminalsCubit>(context).terminalDeleted(task);
  }

  @override
  Widget build(BuildContext context) {
      return BlocBuilder<AdminTerminalsCubit, AdminTerminalsState>(
      builder: (context, state) {
        List<dynamic> terminal = [];
        List<Profile> users = [];
        bool loading = false;
        AppError? error;
        if (state is AdminTerminalsReady) {
          users = state.users.value ?? [];
          terminal = state.terminals.value ?? [];
          loading = state.terminals.inProgress;
          error = state.terminals.error;
        }
        if (terminal.isEmpty) {
          if (loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (error != null) {
            return Text(error.formatted() ?? 'An error occurred'.i18n);
          }
        }
        return ListView.builder(
          itemCount: terminal.length + 1,
          itemBuilder: (context, index) {
            if (index >= terminal.length) {
              return SizedBox(height: kToolbarHeight);
            }
            if (terminal[index] is Widget) {
              return terminal[index];
            }
            return _AdminProjectRow(
              terminal[index],
              users,
              onTap: users.isNotEmpty
                  ? () => Future.delayed(
                        Duration(milliseconds: 300),
                        () => Dijkstra.editAdminTerminal(terminal[index],
                            onChanged: onEditTerminalChange, onDeleted: onEditTerminalDeleted),
                      )
                  : null,
            );
          },
        );
      },
    );
  }
}

class _AdminProjectRow extends StatelessWidget {
  const _AdminProjectRow(this.terminal, this.users, {this.onTap});

  final AdminTerminal terminal;
  final List<Profile> users;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Divider(height: 8),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        terminal.name,
                        style: theme.textTheme.subtitle1,
                      ),
                    ),
                    Icon(
                      terminal.photoVerification == 1
                          ? Icons.photo_camera_outlined
                          : Icons.no_photography_outlined,
                      color: terminal.photoVerification == 1 ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.radio_button_checked_outlined,
                      color: terminal.status == 1 ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Icon(terminal.project == null ? Icons.assignment : Icons.assignment,
                        color: terminal.project == null ? Colors.red : Colors.green),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  terminal.id,
                  style: theme.textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
