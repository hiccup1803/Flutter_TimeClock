import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/kiosk/admin/admin_nfc_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/admin_nfc.dart';
import 'package:staffmonitor/model/admin_terminal.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';
import '../../../../../bloc/main/kiosk/admin/admin_terminals_cubit.dart';
import '../../../../../widget/dialog/confirm_dialog.dart';
import 'admin_nfc_widget.i18n.dart';

class AdminCheckpointWidget extends StatelessWidget {
  const AdminCheckpointWidget();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _TerminalsList(terminals: (state) => state.nfcList.value ?? []),
    );
  }
}

class _TerminalsList extends StatefulWidget {
  const _TerminalsList({Key? key, required this.terminals}) : super(key: key);

  final List<AdminNfc> Function(AdminNfcReady state) terminals;

  @override
  State<_TerminalsList> createState() => _TerminalsListState();
}

class _TerminalsListState extends State<_TerminalsList> {
  void onEditTerminalChange() {
    BlocProvider.of<AdminNfcCubit>(context).refresh();
  }

  void onEditTerminalDeleted([AdminNfc? task]) {}

  void deleteCheckpoint(int id) {
    ConfirmDialog.show(
            context: context,
            title: Text('Confirmation required'.i18n),
            content: Text("Are you sure you want to delete this NFC tag?".i18n))
        .then((result) {
      if (result == true) {
        BlocProvider.of<AdminNfcCubit>(context).deleteTask(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminNfcCubit, AdminNfcState>(
      listenWhen: (previous, current) => current is AdminNfcSaved,
      listener: (context, state) {
        // TODO: implement listener
        if (state is AdminNfcSaved) {
          SuccessDialog.show(
            context: context,
            content:
                Text(state is AdminNfcDeleted ? 'Nfc tag deleted!'.i18n : 'Nfc tag saved!'.i18n),
          ).then((value) {
            BlocProvider.of<AdminNfcCubit>(context).refresh();
          });
        }
      },
      builder: (context, state) {
        List<dynamic> terminal = [];
        List<Profile> users = [];
        bool loading = false;
        AppError? error;
        if (state is AdminNfcReady) {
          users = state.users.value ?? [];
          terminal =
              state.nfcList.value?.where((element) => element.type == 'checkpoint').toList() ?? [];
          loading = state.nfcList.inProgress;
          error = state.nfcList.error;
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
                        () => Dijkstra.editAdminNfc(terminal[index],
                            onChanged: onEditTerminalChange, onDeleted: onEditTerminalDeleted),
                      )
                  : null,
              deleteNfc: (int id) {
                deleteCheckpoint(id);
              },
            );
          },
        );
      },
    );
  }
}

class _AdminProjectRow extends StatelessWidget {
  const _AdminProjectRow(this.terminal, this.users, {this.onTap, required this.deleteNfc});

  final AdminNfc terminal;
  final List<Profile> users;
  final Function()? onTap;
  final Function(int id)? deleteNfc;

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        terminal.serialNumber,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    // IconButton(
                    //     onPressed: () => null,
                    //     icon: Icon(
                    //       Icons.nfc,
                    //       color: AppColors.secondary,
                    //     )),
                    IconButton(
                      onPressed: () => deleteNfc!(terminal.id),
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                Text(
                  terminal.type ?? '',
                  style: theme.textTheme.subtitle1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
