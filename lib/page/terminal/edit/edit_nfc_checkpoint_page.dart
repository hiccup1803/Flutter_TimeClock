import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/kiosk/edit_nfc_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/admin_nfc.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/nfc_reader_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';
import 'package:staffmonitor/widget/dialog/users_picker_dialog.dart';

import '../terminal.i18n.dart';

class EditCheckpointPage extends BasePageWidget {
  static const String TASK_KEY = 'nfckey';
  static const int TASK_DELETED = 100;
  static const int TASK_CHANGED = 101;
  static const String TYPE = 'checkpoint';

  static Map<String, dynamic> buildArgs(String type, AdminNfc? task) => {
        TASK_KEY: task,
        TYPE: type,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    final theme = Theme.of(context);
    AdminNfc? paramTask = args[TASK_KEY];
    String type = args[TYPE];

    String getTitle() {
      if (paramTask == null) {
        if (type == 'checkpoint') return 'Add a checkpoint'.i18n;
        return 'Add an access card'.i18n;
      } else {
        if (type == 'checkpoint') return 'Checkpoint'.i18n;
        return 'Access card'.i18n;
      }
    }

    return BlocProvider<EditNfcCubit>(
      create: (context) =>
          EditNfcCubit(injector.nfcRepository, injector.usersRepository, profile, true)
            ..init(paramTask, type),
      child: Scaffold(
        appBar: AppBar(
          leading: BackIcon(),
          titleSpacing: 0,
          title: Text(
            getTitle(),
            style: theme.textTheme.headline4,
          ),
          actions: [
            Center(child: SaveTaskButton()),
            Container(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: TaskContent(
              paramTask,
              paramTask?.serialNumber,
              paramTask?.description,
              profile,
              type,
            ),
          ),
        ),
      ),
    );
  }
}

class SaveTaskButton extends StatelessWidget {
  final log = Logger('SaveButton');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditNfcCubit, EditNfcState>(
      builder: (context, state) {
        bool enabled = false;
        bool loading = false;
        if (state is EditNfcReady) {
          enabled = state.requireSaving;
        } else if (state is EditNfcProcessing) {
          loading = true;
        }

        log.fine('requireSaving: $enabled');

        return WillPopScope(
          onWillPop: () async {
            bool changed = false;
            if (state is EditNfcReady) {
              changed = state.changed;
            }

            if (!loading) {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.pop(context, changed ? EditCheckpointPage.TASK_CHANGED : null);
              return false;
            }
            return false;
          },
          child: ElevatedButton(
            onPressed: enabled ? BlocProvider.of<EditNfcCubit>(context).save : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  enabled ? 'Save'.i18n : 'Saved'.i18n,
                ),
                if (loading) CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditNfcCubit, EditNfcState>(
      builder: (context, state) {
        bool changed = false;
        if (state is EditNfcReady) {
          changed = state.changed;
        }

        return IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Dijkstra.goBack(changed ? EditCheckpointPage.TASK_CHANGED : null),
        );
      },
    );
  }
}

class TaskContent extends StatefulWidget {
  final AdminNfc? task;
  final String? initialTitle;
  final String? desc;
  final String type;
  final Profile? profile;

  const TaskContent(this.task, this.initialTitle, this.desc, this.profile, this.type);

  @override
  _TaskContentState createState() => _TaskContentState();
}

class _TaskContentState extends State<TaskContent> {
  final log = Logger('----->TerminalContent');

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  List<Profile> valueProfile = [];
  String _employeeName = 'Select employee';
  bool _enable = false;
  int _profileId = 0;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    descriptionController = TextEditingController(text: widget.desc ?? '');
    titleController.addListener(titleChanged);
    descriptionController.addListener(descChanged);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  EditNfcCubit get cubit => BlocProvider.of<EditNfcCubit>(context);

  void titleChanged() => cubit.changeTitle(titleController.text);

  void descChanged() => cubit.changeDescription(descriptionController.text);

  Future<Profile?> selectProfile(
      BuildContext context, String title, List<Profile> profiles, int selected) {
    return UsersPickerDialog.show(
      context: context,
      profiles: profiles,
      titleText: title,
      initialSelection: selected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<EditNfcCubit, EditNfcState>(
      listenWhen: (previous, current) => current is EditNfcError || current is EditNfcSaved,
      listener: (context, state) {
        if (state is EditNfcError) {
          FailureDialog.show(
            context: context,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.error.messages.map((e) => Text(e!)).toList(),
            ),
          ).then((_) {
            cubit.errorConsumed();
          });
        } else if (state is EditNfcSaved) {
          SuccessDialog.show(
            context: context,
            content:
                Text(state is EditNfcDeleted ? 'Nfc tag deleted!'.i18n : 'Nfc tag saved!'.i18n),
          ).then((value) {
            if (state is EditNfcDeleted) {
              Dijkstra.goBack(EditCheckpointPage.TASK_DELETED);
            } else if (state.closePage == true) {
              Dijkstra.goBack(EditCheckpointPage.TASK_CHANGED);
            } else {
              BlocProvider.of<EditNfcCubit>(context).stateConsumed();
            }
          });
        }
      },
      builder: (context, state) {
        AdminNfc? task;
        bool processing = true;
        if (state is EditNfcReady) {
          task = state.task;
          processing = false;
        } else if (state is EditNfcProcessing) {
          task = state.task;
        } else if (state is EditNfcSaved) {
          task = state.task;
        } else if (state is EditNfcError) {
          task = state.task;
        } else if (state is EditNfcValidator) {
          task = state.task;
          processing = false;
        }
        log.fine('build with task: $task');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Text(
                'NFC Serial number'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.color2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: titleController,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.color1,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        errorText: state is EditNfcValidator ? state.titleError : null,
                        contentPadding: const EdgeInsets.all(10),
                        enabled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: AppColors.color3.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: AppColors.color3.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                      ),
                      minLines: 1,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    onPressed: _startNfcReader,
                    icon: Icon(
                      Icons.nfc,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Text(
                'Description'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.color2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: descriptionController,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.color1,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                  enabled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppColors.color3.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppColors.color3.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                ),
                minLines: 1,
                maxLines: 2,
              ),
            ),
            if (widget.type == 'access_card')
              Padding(
                padding: EdgeInsets.fromLTRB(18, 20, 20, 0),
                child: Text(
                  'Select User'.i18n,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.color2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (widget.type == 'access_card')
              Padding(
                padding: const EdgeInsets.only(left: 6.0, top: 8.0, right: 20.0, bottom: 0.0),
                child: FutureBuilder<List<Profile>>(
                  future: injector.usersRepository.getAllEmployee(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      snapshot.data!.forEach((element) {
                        if (element.id == _profileId) {
                          _employeeName = element.name!;
                          _enable = true;
                        }
                      });
                    }
                    return InkWell(
                      onTap: () {
                        int selected =
                            snapshot.data!.indexWhere((element) => element.id == _profileId);

                        Future.delayed(Duration(milliseconds: 300), () {
                          selectProfile(context, 'Select Employee', snapshot.data!, selected)
                              .then((selectProfile) {
                            if (selectProfile != null) {
                              setState(() {
                                _employeeName = selectProfile.name!;
                                _profileId = selectProfile.id;
                                _enable = true;
                                BlocProvider.of<EditNfcCubit>(context).selectUser(_profileId);
                              });
                            }
                          });
                        });
                      },
                      child: Container(
                        constraints: BoxConstraints(minWidth: 200),
                        margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4, right: 12),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 12),
                        child: Text(
                          _employeeName,
                          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.020),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (task?.isCreate == false && widget.profile?.allowRemove == true) Divider(),
          ],
        );
      },
    );
  }

  void _startNfcReader() {
    showDialog<String>(
      context: context,
      builder: (context) => NfcReaderDialog(),
      barrierDismissible: false,
    ).then((value) {
      if (value != null) {
        titleController.text = value;
      }
    });
  }
}
