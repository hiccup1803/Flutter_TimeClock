import 'package:dropdown_search/dropdown_search.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/files/file_upload_cubit.dart';
import 'package:staffmonitor/bloc/kiosk/edit_terminal_cubit.dart';
import 'package:staffmonitor/bloc/session/edit/edit_session_cubit.dart';
import 'package:staffmonitor/bloc/task/edit/edit_task_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/calendar_note.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/task/edit/note_author_date_widget.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/file_details_dialog.dart';
import 'package:staffmonitor/widget/dialog/file_size_over_dialog.dart';
import 'package:staffmonitor/widget/dialog/own_project_dialog.dart';
import 'package:staffmonitor/widget/dialog/project_picker_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';

import '../../../model/admin_terminal.dart';
import '../terminal.i18n.dart';

class EditAdminTerminalPage extends BasePageWidget {
  static const String TASK_KEY = 'task';
  static const int TASK_DELETED = 100;
  static const int TASK_CHANGED = 101;

  static Map<String, dynamic> buildArgs(AdminTerminal? task) => {
        TASK_KEY: task,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    final theme = Theme.of(context);
    AdminTerminal? paramTask = args[TASK_KEY];
    return BlocProvider<EditTerminalCubit>(
      create: (context) =>
          EditTerminalCubit(injector.terminalRepository, injector.projectsRepository, profile, true)
            ..init(
              paramTask,
            ),
      child: Scaffold(
        appBar: AppBar(
          leading: BackIcon(),
          titleSpacing: 0,
          title: Text(
            paramTask != null ? 'Terminal'.i18n : 'New Terminal'.i18n,
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
              paramTask?.name,
              profile,
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
    return BlocBuilder<EditTerminalCubit, EditTerminalState>(
      builder: (context, state) {
        bool enabled = false;
        bool loading = false;
        if (state is EditTerminalReady) {
          enabled = state.requireSaving;
        } else if (state is EditTerminalProcessing) {
          loading = true;
        }

        log.fine('requireSaving: $enabled');

        return WillPopScope(
          onWillPop: () async {
            bool changed = false;
            if (state is EditTerminalReady) {
              changed = state.changed;
            }

            if (!loading) {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.pop(context, changed ? EditAdminTerminalPage.TASK_CHANGED : null);
              return false;
            }
            return false;
          },
          child: ElevatedButton(
            onPressed: enabled ? BlocProvider.of<EditTerminalCubit>(context).save : null,
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
    return BlocBuilder<EditTerminalCubit, EditTerminalState>(
      builder: (context, state) {
        bool changed = false;
        if (state is EditTerminalReady) {
          changed = state.changed;
        }

        return IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Dijkstra.goBack(changed ? EditAdminTerminalPage.TASK_CHANGED : null),
        );
      },
    );
  }
}

class TaskContent extends StatefulWidget {
  final AdminTerminal? task;
  final String? initialTitle;
  final Profile? profile;

  const TaskContent(this.task, this.initialTitle, this.profile);

  @override
  _TaskContentState createState() => _TaskContentState();
}

class _TaskContentState extends State<TaskContent> {
  final log = Logger('----->TerminalContent');

  late TextEditingController titleController;
  List<Profile> valueProfile = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    titleController.addListener(titleChanged);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  EditTerminalCubit get cubit => BlocProvider.of<EditTerminalCubit>(context);

  void titleChanged() => cubit.changeTitle(titleController.text);

  Future<Project?> selectProject(
    BuildContext context,
    String title,
    List<Project> availableProjects, {
    int? selected,
    List<Project>? defaultProjects,
    List<int>? preferredProjects,
    List<int?>? lastProjects,
  }) {
    return ProjectPickerDialog.show(
      context: context,
      projects: availableProjects,
      defaultProjects: defaultProjects ?? [],
      preferred: preferredProjects,
      last: lastProjects,
      titleText: title,
      initialSelection: selected ?? availableProjects.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<EditTerminalCubit, EditTerminalState>(
      listenWhen: (previous, current) =>
          current is EditTerminalError || current is EditTerminalSaved,
      listener: (context, state) {
        if (state is EditTerminalError) {
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
        } else if (state is EditTerminalSaved) {
          SuccessDialog.show(
            context: context,
            content: Text(state is EditTerminalDeleted
                ? 'Terminal deleted!'.i18n
                : state is EditTerminalCodeSaved
                    ? 'Access code generated'
                    : 'Terminal saved!'.i18n),
          ).then((value) {
            if (state is EditTerminalDeleted) {
              Dijkstra.goBack(EditAdminTerminalPage.TASK_DELETED);
            } else if (state.closePage == true) {
              Dijkstra.goBack(EditAdminTerminalPage.TASK_CHANGED);
            } else {
              BlocProvider.of<EditTerminalCubit>(context).stateConsumed();
            }
          });
        }
      },
      builder: (context, state) {
        AdminTerminal? task;
        bool processing = true;
        if (state is EditTerminalReady) {
          task = state.task;
          processing = false;
        } else if (state is EditTerminalProcessing) {
          task = state.task;
        } else if (state is EditTerminalSaved) {
          task = state.task;
        } else if (state is EditTerminalError) {
          task = state.task;
        } else if (state is EditTerminalValidator) {
          task = state.task;
          processing = false;
        }
        log.fine('build with task: $task');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task?.isCreate == false)
              Padding(
                padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.color1,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terminal Access Code: '.i18n,
                      ),
                      TextSpan(
                        text: task?.code == null ? 'NONE' : task?.code,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (task?.isCreate == false)
              Padding(
                padding: EdgeInsets.fromLTRB(18, 14, 4, 8),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.color1,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terminal ID: '.i18n,
                      ),
                      TextSpan(
                        text: task?.id == null ? 'NONE' : task?.id,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (task?.isCreate == false)
              Padding(
                padding: EdgeInsets.fromLTRB(18, 8, 4, 8),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.color1,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Status: '.i18n,
                      ),
                      TextSpan(
                        text: task?.status == null
                            ? 'NONE'
                            : task?.status == 0
                                ? 'INACTIVE'
                                : 'ACTIVE',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (task?.isCreate == true) Container(height: 18),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Text(
                'Name'.i18n,
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
                controller: titleController,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.color1,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  errorText: state is EditTerminalValidator ? state.titleError : null,
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
            Padding(
              padding: EdgeInsets.fromLTRB(18, 20, 20, 0),
              child: Text(
                'Select assigned project'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.color2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0, top: 8.0, right: 20.0, bottom: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: FutureBuilder<List<int?>>(
                          future: injector.projectsRepository.getLastProjects(),
                          builder: (context, snapshot) {
                            List<Project> projects = [];
                            List<Project> defaultProjects = [];
                            defaultProjects.add(Project.noProject);
                            projects.addAll(widget.profile!.availableProjects ?? []);
                            return InkWell(
                              onTap: () {
                                context.unFocus();
                                Future.delayed(Duration(milliseconds: 300), () {
                                  selectProject(
                                    context,
                                    'Select project'.i18n,
                                    projects,
                                    defaultProjects: defaultProjects,
                                    selected:
                                        state is EditTerminalReady ? state.selectedProject.id : 0,
                                    preferredProjects: widget.profile!.preferredProjects,
                                    lastProjects: snapshot.data?.sublist(
                                      0,
                                      widget.profile!.lastProjectsLimit! > snapshot.data!.length
                                          ? snapshot.data!.length
                                          : widget.profile!.lastProjectsLimit,
                                    ),
                                  ).then((selectedProject) {
                                    if (selectedProject != null) {
                                      if (selectedProject.id == Project.ownProject.id) {
                                        OwnProjectDialog.show(context: context).then((project) {
                                          if (project != null) {
                                            BlocProvider.of<EditTerminalCubit>(context)
                                                .selectProject(project, widget.profile!.id);
                                          }
                                        });
                                      } else {
                                        BlocProvider.of<EditTerminalCubit>(context)
                                            .selectProject(selectedProject, widget.profile!.id);
                                      }
                                    } else {
                                      log.finer('selectedProject else');
                                    }
                                  });
                                });
                              },
                              child: Container(
                                constraints: BoxConstraints(minWidth: 200),
                                margin:
                                    const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 12),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.color3.withOpacity(0.4), width: 2),
                                    borderRadius: BorderRadius.circular(6)),
                                padding:
                                    const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 12),
                                child: Text(
                                  state is EditTerminalReady
                                      ? state.selectedProject.name
                                      : state is EditTerminalValidator
                                          ? state.selectedProject.name
                                          : '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.color1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            checkBoxRow(
              'Photo Verification'.i18n,
              state is EditTerminalReady ? state.photoVerification : true,
              enabled: !processing,
              highlight: !processing,
              onChange: (newValue) {
                context.unFocus();
                BlocProvider.of<EditTerminalCubit>(context)
                    .photoVerificationChanged(newValue ?? true);
              },
            ),
            if (task?.isCreate == false && widget.profile?.allowRemove == true) Divider(),
            if (task?.isCreate == false &&
                widget.profile?.allowRemove == true &&
                (!widget.profile!.isSupervisor))
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton.icon(
                        onPressed: processing ? null : deleteTask,
                        icon: Icon(Icons.delete_forever),
                        label: Text('Delete'.i18n),
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton.icon(
                        onPressed: processing ? null : generateAccessCode,
                        icon: Icon(Icons.key),
                        label: Text('Generate access code'.i18n),
                        style: ElevatedButton.styleFrom(primary: AppColors.secondary),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void deleteTask() {
    ConfirmDialog.show(
            context: context,
            title: Text('Deleting a Terminal'.i18n),
            content: Text("Are you sure you want to delete this terminal?".i18n))
        .then((result) {
      if (result == true) {
        cubit.deleteTask();
      }
    });
  }

  void generateAccessCode() {
    ConfirmDialog.show(
            context: context,
            title: Text('Confirmation required'.i18n),
            content:
                Text("Are you sure you want to generate new access code for this terminal?".i18n))
        .then((result) {
      if (result == true) {
        cubit.generateCode();
      }
    });
  }
}
