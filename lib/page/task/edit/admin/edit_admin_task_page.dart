import 'package:dropdown_search/dropdown_search.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/files/file_upload_cubit.dart';
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
import 'package:staffmonitor/model/task_customfiled.dart';
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

import '../../../../model/company_profile.dart';
import '../../../../repository/company_repository.dart';
import '../../task.i18n.dart';

part 'admin_task_files.dart';

class EditAdminTaskPage extends BasePageWidget {
  static const String TASK_KEY = 'task';
  static const String DATE_KEY = 'date';
  static const int TASK_DELETED = 100;
  static const int TASK_CHANGED = 101;

  static Map<String, dynamic> buildArgs(CalendarTask? task, {DateTime? date}) => {
        TASK_KEY: task,
        DATE_KEY: date,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    final theme = Theme.of(context);
    CalendarTask? paramTask = args[TASK_KEY];
    DateTime? paramDate = args[DATE_KEY];
    return BlocProvider<EditTaskCubit>(
      create: (context) => EditTaskCubit(
          injector.projectsRepository, injector.profileCompanyRepository, profile, true)
        ..init(
          paramTask,
          date: paramDate,
        ),
      child: Scaffold(
        appBar: AppBar(
          leading: BackIcon(),
          titleSpacing: 0,
          title: Text(
            paramTask != null ? 'Task Details'.i18n : 'Adding Task'.i18n,
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
              paramTask?.notes,
              paramTask?.title,
              paramTask?.location,
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
    return BlocBuilder<EditTaskCubit, EditTaskState>(
      builder: (context, state) {
        bool enabled = false;
        bool loading = false;
        if (state is EditTaskReady) {
          enabled = state.requireSaving;
        } else if (state is EditTaskProcessing) {
          loading = true;
        }

        log.fine('requireSaving: $enabled');

        return WillPopScope(
          onWillPop: () async {
            bool changed = false;
            if (state is EditTaskReady) {
              changed = state.changed;
            }

            if (!loading) {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.pop(context, changed ? EditAdminTaskPage.TASK_CHANGED : null);
              return false;
            }
            return false;
          },
          child: ElevatedButton(
            onPressed: enabled ? BlocProvider.of<EditTaskCubit>(context).save : null,
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
    return BlocBuilder<EditTaskCubit, EditTaskState>(
      builder: (context, state) {
        bool changed = false;
        if (state is EditTaskReady) {
          changed = state.changed;
        }

        return IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Dijkstra.goBack(changed ? EditAdminTaskPage.TASK_CHANGED : null),
        );
      },
    );
  }
}

class TaskContent extends StatefulWidget {
  final CalendarTask? task;
  final List<CalendarNote>? initialNotes;
  final String? initialTitle;
  final String? initialLocation;
  final Profile? profile;

  const TaskContent(
      this.task, this.initialNotes, this.initialTitle, this.initialLocation, this.profile);

  @override
  _TaskContentState createState() => _TaskContentState();
}

class _TaskContentState extends State<TaskContent> {
  final log = Logger('TaskContent');

  late TextEditingController noteController;
  late TextEditingController titleController;
  late TextEditingController locationController;
  List<Profile> valueProfile = [];
  final _multiKey = GlobalKey<DropdownSearchState<String>>();

  Map<int, TextEditingController> _controllerMap = Map();
  List<String> valueDropdownList = ['option1', 'option2'];
  List<String> valueCheckList = ['option1', 'option2', 'option3'];

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    locationController = TextEditingController(text: widget.initialLocation ?? '');
    noteController.addListener(noteChanged);
    titleController.addListener(titleChanged);
    locationController.addListener(locationChanged);
  }

  @override
  void dispose() {
    noteController.dispose();
    titleController.dispose();
    locationController.dispose();
    super.dispose();
  }

  EditTaskCubit get cubit => BlocProvider.of<EditTaskCubit>(context);

  void noteChanged() => cubit.noteChanged(noteController.text);

  void titleChanged() => cubit.changeTitle(titleController.text);

  void locationChanged() => cubit.changeLocation(locationController.text);

  void changeStartAt(CalendarTask task) {
    showDatePicker(
      context: context,
      initialDate: task.start ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(3000),
    ).then((date) {
      if (date != null) cubit.changeStartDate(date);
    });
  }

  void changeEndAt(CalendarTask task) {
    showDatePicker(
      context: context,
      initialDate: task.end ?? DateTime.now(),
      firstDate: task.start ?? DateTime.now(),
      lastDate: DateTime(3000),
    ).then((date) {
      if (date != null) cubit.changeEndDate(date);
    });
  }

  void changeStartTime(DateTime startTime) {
    showTimePicker(
      context: context,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
      initialTime: TimeOfDay.fromDateTime(startTime.toUserTimeZone),
    ).then((value) {
      if (value != null) cubit.changeStartTime(value);
    });
  }

  void changeEndTime(DateTime endTime) {
    showTimePicker(
      context: context,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
      initialTime: TimeOfDay.fromDateTime(endTime.toUserTimeZone),
    ).then((value) {
      if (value != null) cubit.changeEndTime(value);
    });
  }

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

  void _changePriority(int currentPriority) {
    var style = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.color1,
    );

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select new priority'.i18n),
          children: [
            RadioListTile(
              value: 0,
              groupValue: currentPriority,
              activeColor: AppColors.primaryLight,
              selected: currentPriority == 0,
              title: Text(
                'low',
                style: style,
              ),
              onChanged: (value) => Navigator.pop(context, currentPriority == 0 ? null : 0),
            ),
            RadioListTile(
              value: 1,
              groupValue: currentPriority,
              activeColor: AppColors.primaryLight,
              selected: currentPriority == 1,
              title: Text(
                'medium',
                style: style,
              ),
              onChanged: (value) => Navigator.pop(context, currentPriority == 1 ? null : 1),
            ),
            RadioListTile(
              value: 2,
              groupValue: currentPriority,
              activeColor: AppColors.primaryLight,
              selected: currentPriority == 2,
              title: Text(
                'high',
                style: style,
              ),
              onChanged: (value) {
                Navigator.pop(context, currentPriority == 2 ? null : 2);
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        BlocProvider.of<EditTaskCubit>(context).changePriority(value);
      }
    });
  }

  void _changeStatus(int currentStatus) {
    var style = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.color1,
    );

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select status'.i18n),
          children: [
            RadioListTile(
              value: 0,
              groupValue: currentStatus,
              activeColor: AppColors.primaryLight,
              selected: currentStatus == 0,
              title: Text(
                'opened',
                style: style,
              ),
              onChanged: (value) => Navigator.pop(context, currentStatus == 0 ? null : 0),
            ),
            RadioListTile(
              value: 1,
              groupValue: currentStatus,
              activeColor: AppColors.primaryLight,
              selected: currentStatus == 1,
              title: Text(
                'closed',
                style: style,
              ),
              onChanged: (value) => Navigator.pop(context, currentStatus == 1 ? null : 1),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        BlocProvider.of<EditTaskCubit>(context).changeStatus(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<EditTaskCubit, EditTaskState>(
      listenWhen: (previous, current) => current is EditTaskError || current is EditTaskSaved,
      listener: (context, state) {
        if (state is EditTaskError) {
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
        } else if (state is EditTaskSaved) {
          SuccessDialog.show(
            context: context,
            content: Text(state is EditTaskDeleted ? 'Task deleted!'.i18n : 'Task saved!'.i18n),
          ).then((value) {
            if (state is EditTaskDeleted) {
              Dijkstra.goBack(EditAdminTaskPage.TASK_DELETED);
            } else if (state.closePage == true) {
              Dijkstra.goBack(EditAdminTaskPage.TASK_CHANGED);
            } else {
              BlocProvider.of<EditTaskCubit>(context).stateConsumed();
            }
          });
        }
      },
      builder: (context, state) {
        CalendarTask? task;
        bool processing = true;
        if (state is EditTaskReady) {
          task = state.task;
          processing = false;
        } else if (state is EditTaskProcessing) {
          task = state.task;
        } else if (state is EditTaskSaved) {
          task = state.task;
        } else if (state is EditTaskError) {
          task = state.task;
        } else if (state is EditTaskValidator) {
          task = state.task;
          processing = false;
        }
        log.fine('build with task: $task');

        return processing
            ? LinearProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date'.i18n,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.color3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            InkWell(
                                onTap: processing
                                    ? null
                                    : () {
                                        changeStartAt(task!);
                                      },
                                child: Text(
                                  task!.start!
                                      .format(task.wholeDay ? "MM-dd-yyyy" : "MM-dd-yyyy HH:mm"),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.color1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'End Date'.i18n,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.color3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            InkWell(
                              onTap: processing
                                  ? null
                                  : () {
                                      changeEndAt(task!);
                                    },
                              child: Text(
                                task.end?.format(
                                        task.wholeDay ? "MM-dd-yyyy" : "MM-dd-yyyy HH:mm") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.color1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!task.wholeDay)
                    Padding(
                      padding: EdgeInsets.fromLTRB(18, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time'.i18n,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.color3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              InkWell(
                                  onTap: processing
                                      ? null
                                      : () {
                                          changeStartTime(task!.start!);
                                        },
                                  child: Text(
                                    task.start!.format('HH:mm'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.color1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ))
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'End Time'.i18n,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.color3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              InkWell(
                                onTap: processing
                                    ? null
                                    : () {
                                        changeEndTime(task!.start!);
                                      },
                                child: Text(
                                  task.end?.format('HH:mm') ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.color1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  checkBoxRow(
                    'whole day'.i18n,
                    state is EditTaskReady ? task.wholeDay : true,
                    enabled: !processing,
                    highlight: !processing,
                    onChange: (newValue) {
                      context.unFocus();
                      BlocProvider.of<EditTaskCubit>(context).changeWholeDay(newValue ?? true);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 0),
                    child: Text(
                      'Title'.i18n,
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
                        errorText: state is EditTaskValidator ? state.titleError : null,
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
                    padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: Text(
                      'Priority'.i18n,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.color2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                width: 2.0,
                                color: AppColors.color3.withOpacity(0.4),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                (task.priority == 0
                                    ? '  low'
                                    : task.priority == 1
                                        ? '  medium'
                                        : '  high'),
                                textAlign: TextAlign.left,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.color1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                            onTap: () => _changePriority(task!.priority ?? 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.color3.withOpacity(0.4), width: 2),
                                  borderRadius: BorderRadius.circular(6)),
                              padding:
                                  const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: AppColors.color2,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: Text(
                      'Status'.i18n,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.color2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                width: 2.0,
                                color: AppColors.color3.withOpacity(0.4),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                (task.status == 0 ? '  opened' : '  closed'),
                                textAlign: TextAlign.left,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.color1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                            onTap: () => _changeStatus(task!.status ?? 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.color3.withOpacity(0.4), width: 2),
                                  borderRadius: BorderRadius.circular(6)),
                              padding:
                                  const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: AppColors.color2,
                                ),
                              ),
                            )),
                      ],
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
                                  if (widget.profile!.allowOwnProjects == true) {
                                    defaultProjects.add(Project.ownProject);
                                  }
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
                                              state is EditTaskReady ? state.selectedProject.id : 0,
                                          preferredProjects: widget.profile!.preferredProjects,
                                          lastProjects: snapshot.data?.sublist(
                                            0,
                                            widget.profile!.lastProjectsLimit! >
                                                    snapshot.data!.length
                                                ? snapshot.data!.length
                                                : widget.profile!.lastProjectsLimit,
                                          ),
                                        ).then((selectedProject) {
                                          if (selectedProject != null) {
                                            if (selectedProject.id == Project.ownProject.id) {
                                              OwnProjectDialog.show(context: context)
                                                  .then((project) {
                                                if (project != null) {
                                                  BlocProvider.of<EditTaskCubit>(context)
                                                      .selectProject(project, widget.profile!.id);
                                                }
                                              });
                                            } else {
                                              BlocProvider.of<EditTaskCubit>(context).selectProject(
                                                  selectedProject, widget.profile!.id);
                                            }
                                          } else {
                                            log.finer('selectedProject else');
                                          }
                                        });
                                      });
                                    },
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 200),
                                      margin: const EdgeInsets.only(
                                          left: 12, top: 4, bottom: 4, right: 12),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.color3.withOpacity(0.4), width: 2),
                                          borderRadius: BorderRadius.circular(6)),
                                      padding: const EdgeInsets.only(
                                          left: 12, top: 8, bottom: 8, right: 12),
                                      child: Text(
                                        state is EditTaskReady ? state.selectedProject.name : '',
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
                            SizedBox(
                              width: 6,
                            ),
                            InkWell(
                              onTap: () {
                                context.unFocus();
                                Future.delayed(Duration(milliseconds: 300), () {
                                  OwnProjectDialog.show(context: context).then((project) {
                                    if (project != null) {
                                      BlocProvider.of<EditTaskCubit>(context)
                                          .selectProject(project, widget.profile!.id);
                                    }
                                  });
                                });
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.color3.withOpacity(0.4), width: 2),
                                      borderRadius: BorderRadius.circular(6)),
                                  padding:
                                      const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 12),
                                  child: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: AppColors.color2,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0, right: 16.0, bottom: 0.0),
                    alignment: Alignment.centerLeft,
                    child: FutureBuilder<List<Profile>>(
                      future: injector.usersRepository.getAllEmployee(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData)
                          return DropdownSearch<Profile>.multiSelection(
                            key: _multiKey,
                            mode: Mode.DIALOG,
                            showSelectedItems: true,
                            items: snapshot.data ?? [],
                            validator: (List<Profile>? v) {
                              return v == null || v.isEmpty ? "Wymagane" : null;
                            },
                            autoValidateMode: AutovalidateMode.onUserInteraction,
                            itemAsString: (Profile? p) => p!.name!,
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Assigned Employees'.i18n,
                              hintText: "Select Employee".i18n,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.color2,
                                fontWeight: FontWeight.w600,
                              ),
                              contentPadding: EdgeInsets.fromLTRB(6, 12, 0, 0),
                            ),
                            dropdownBuilder: _customDropDownUI,
                            onChanged: _onChanged,
                            selectedItems: snapshot.data!
                                .where((element) => task!.assignees.contains(element.id))
                                .toList(),
                            showClearButton: true,
                            clearButtonSplashRadius: 20,
                            compareFn: (item, selectedItem) => item?.id == selectedItem?.id,
                          );
                        return Container();
                      },
                    ),
                  ),
                  if (!task.isCreate)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 18.0, top: 18.0, right: 16.0, bottom: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getCustomFieldView(task.customFields),
                      ),
                    ),
                  if (task.isCreate)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 18.0, top: 18.0, right: 16.0, bottom: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getCustomFieldView(task.customFields),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 18, 16, 0),
                    child: Text(
                      'Location'.i18n,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.color2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 10, 16, 0),
                    child: TextField(
                      controller: locationController,
                      enabled: processing == false,
                      decoration: InputDecoration(
                        isDense: true,
                        errorText: state is EditTaskValidator ? state.titleError : null,
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
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.color1,
                        fontWeight: FontWeight.bold,
                      ),
                      minLines: 1,
                      maxLines: 2,
                    ),
                  ),
                  if (task.isCreate != true)
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 18.0),
                      child: Text(
                        'Note'.i18n,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.color2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (task.isCreate != true)
                    Padding(
                      padding: EdgeInsets.fromLTRB(18, 10, 16, 0),
                      child: TextField(
                        controller: noteController,
                        enabled: processing == false,
                        decoration: InputDecoration(
                          isDense: true,
                          errorText: state is EditTaskValidator ? state.titleError : null,
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
                        minLines: 3,
                        maxLines: 10,
                      ),
                    ),
                  ...task.notes
                      .map((calendarNote) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AdminTaskFiles(
                                calendarNote.id,
                                calendarNote,
                                [calendarNote],
                                showAdd: false,
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                                onDeleted: (file) {
                                  BlocProvider.of<EditSessionCubit>(context).fileDeleted(file);
                                },
                              )
                            ],
                          ))
                      .toList(),
                  if (!task.isCreate)
                    BlocListener<FileUploadCubit, FileUploadState>(
                        listenWhen: (previous, current) => true,
                        listener: (context, state) {
                          log.fine('BlocListener - file upload: $state');
                          if (state is FileUploadInProgress) {
                            if (state.finishedUploads.isNotEmpty) {
                              final task = state.finishedUploads.first;
                              BlocProvider.of<FileUploadCubit>(context).taskConsumed(task);
                              final uploadResult = state.uploadResult[task];
                              if (uploadResult is AppFile) {
                                BlocProvider.of<EditTaskCubit>(context).fileChanged(uploadResult);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('%s - upload completed.'
                                        .i18n
                                        .fill([uploadResult.name ?? '']))));
                              } else {
                                if (uploadResult is AppError) {
                                  FailureDialog.show(
                                    context: context,
                                    content: Column(
                                      children: uploadResult.messages.map((e) => Text(e!)).toList(),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        child: AdminTaskFiles(
                          -1,
                          null,
                          [],
                          showAdd: true,
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                          onDeleted: (file) {
                            BlocProvider.of<EditSessionCubit>(context).fileDeleted(file);
                          },
                        )),
                  checkBoxRow(
                    'Send notification by email to employees'.i18n,
                    state is EditTaskReady ? state.sendEmail : true,
                    enabled: !processing,
                    highlight: !processing,
                    onChange: (newValue) {
                      context.unFocus();
                      BlocProvider.of<EditTaskCubit>(context).sendEmailChanged(newValue ?? true);
                    },
                  ),
                  checkBoxRow(
                    'Send PUSH notification to employees'.i18n,
                    state is EditTaskReady ? state.sendPush : true,
                    enabled: !processing,
                    highlight: !processing,
                    onChange: (newValue) {
                      context.unFocus();
                      BlocProvider.of<EditTaskCubit>(context).sendPushChanged(newValue ?? true);
                    },
                  ),
                  checkBoxRow(
                    'Send notification immediately (by default, notifications are sent at 8 am and 4 pm)'
                        .i18n,
                    state is EditTaskReady ? state.sendImmediately : true,
                    enabled: !processing,
                    highlight: !processing,
                    onChange: (newValue) {
                      context.unFocus();
                      BlocProvider.of<EditTaskCubit>(context)
                          .sendImmediatelyChanged(newValue ?? false);
                    },
                  ),
                  /*if (task.isCreate != false)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
                child: Text(
                  'Save task to upload files and notes'.i18n,
                  style: theme.textTheme.headline6,
                ),
              ),*/
                  if (task.isCreate == false && widget.profile?.allowRemove == true) Divider(),
                  if (task.isCreate == false &&
                      widget.profile?.allowRemove == true &&
                      (!widget.profile!.isSupervisor))
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: processing ? null : deleteTask,
                          icon: Icon(Icons.delete_forever),
                          label: Text('Delete Task'.i18n),
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                        ),
                      ),
                    ),
                ],
              );
      },
    );
  }

  void deleteTask() {
    ConfirmDialog.show(
            context: context,
            title: Text('Deleting a Task'.i18n),
            content: Text(
                "This action can't be undone. Are you sure you want to delete this task?".i18n))
        .then((result) {
      if (result == true) {
        cubit.deleteTask();
      }
    });
  }

  Widget _customDropDownUI(BuildContext context, List<Profile> selectedItems) {
    if (selectedItems.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text(
          "No employee selected",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.color2,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Wrap(
      children: selectedItems.map((e) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text(e.name ?? ''),
              leading: CircleAvatar(
                child: Text(e.name == null || e.name == '' ? '' : e.name!.substring(0, 1)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onChanged(List<Profile> value) {
    List<int> list = [];
    list.addAll(value.map((e) => e.id));
    cubit.updateAssignee(list);
  }

  List<Widget> getCustomFieldView(List<TaskCustomFiled> customFields) {
    List<Widget> arr = [];

    for (var element in customFields) {
      switch (element.type) {
        case 'text':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'int':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'float':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'date':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'datetime':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'textarea':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(
                _getTextFields(_controllerMap[element.fieldId]!, element.type, element, d: 0.0));
          }
          break;
        case 'check':
          if (element.available ?? true) {
            arr.add(CheckboxListTile(
              onChanged: (value) {
                setState(() {
                  cubit.updateCustomField(TaskCustomFiled(
                      element.fieldId, element.name, value == true ? '1' : '0', element.type));
                });
              },
              value: element.value == null || element.value == '0' ? false : true,
              activeColor: element.value == '0' ? Colors.grey : null,
              title: Text(
                element.name,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: element.value == '0' ? Colors.grey : AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ));
          }
          break;
        case 'select':
          if (element.available ?? true) {
            arr.add(DropdownSearch<String>(
              mode: Mode.MENU,
              showSelectedItems: true,
              items: valueDropdownList,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              itemAsString: (String? p) => p!,
              selectedItem: element.value ?? '',
              dropdownSearchDecoration: InputDecoration(
                labelText: element.name,
                hintText: "Select option".i18n,
                border: OutlineInputBorder(),
                constraints: BoxConstraints(maxHeight: 46),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.color2,
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: EdgeInsets.fromLTRB(8, 12, 0, 0),
              ),
              onChanged: (s) {
                cubit.updateCustomField(
                    TaskCustomFiled(element.fieldId, element.name, s, element.type));
              },
              showClearButton: true,
              clearButtonSplashRadius: 20,
            ));
          }
          break;
        case 'checklist':
          if (element.available ?? true) {
            arr.add(SizedBox(
              height: 16,
            ));
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));

            if (valueCheckList.isNotEmpty)
              valueCheckList.forEach((value) {
                arr.add(_getCheckBox(value, element));
              });
          }
          break;
        default:
          break;
      }
    }
    return arr;
  }

  TextEditingController _getControllerOf(TaskCustomFiled element, String s) {
    var controller = _controllerMap[element.fieldId];

    String value = s;

    switch (element.type) {
      case 'date':
        if (s.isNotEmpty) {
          try {
            value = DateFormat("yyyy-MM-dd").parse(s).format();
          } catch (e) {
            value = DateFormat("dd/MM/yyyy").parse(s).format();
          }
        }
        break;
      case 'datetime':
        if (s.isNotEmpty) {
          try {
            value = DateFormat("yyyy-MM-ddTHH:mm").parse(s).format('dd/MM/yyyy HH:mm a');
          } catch (e) {
            value = DateFormat("dd/MM/yyyy HH:mm a").parse(s).format('dd/MM/yyyy HH:mm a');
          }
        }
        break;
      case 'text':
        value = s;
        break;
      default:
        value = s;
        break;
    }

    if (controller == null) {
      controller = TextEditingController(text: value);
      _controllerMap[element.fieldId] = controller;
    }
    return controller;
  }

  _getTextFields(TextEditingController textController, String type, TaskCustomFiled element,
      {double d = 12.0}) {
    if (type == 'date' || type == 'datetime')
      return Padding(
        padding: EdgeInsets.only(bottom: d, top: 4.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: type == 'date' || type == 'datetime'
                    ? () {
                        if (type == 'date') {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2100), onChanged: (date) {
                            textController.text = date.format();
                          }, onConfirm: (date) {
                            textController.text = date.format();
                            String finalDate = textController.text;
                            try {
                              finalDate = DateFormat(
                                      "dd/MM/yyyy", AuthCubit.locale?.toLanguageTag() ?? 'en')
                                  .parse(finalDate)
                                  .format('yyyy-MM-dd');
                            } catch (e) {
                              finalDate;
                            }

                            cubit.updateCustomField(TaskCustomFiled(
                                element.fieldId, element.name, finalDate, element.type));
                          }, currentTime: DateTime.now());
                        } else {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2100), onChanged: (date) {
                            textController.text = date.format('dd/MM/yyyy HH:mm a');
                          }, onConfirm: (date) {
                            textController.text = date.format('dd/MM/yyyy HH:mm a');

                            String finalDate = textController.text;
                            try {
                              finalDate = DateFormat("dd/MM/yyyy HH:mm a",
                                      AuthCubit.locale?.toLanguageTag() ?? 'en')
                                  .parse(finalDate)
                                  .format('yyyy-MM-ddTHH:mm');
                            } catch (e) {
                              finalDate;
                            }

                            cubit.updateCustomField(TaskCustomFiled(
                                element.fieldId, element.name, finalDate, element.type));
                          }, currentTime: DateTime.now());
                        }
                      }
                    : null,
                child: TextField(
                  controller: textController,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.color1,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: type == 'text'
                      ? TextInputType.text
                      : type == 'textarea'
                          ? TextInputType.multiline
                          : type == 'int'
                              ? TextInputType.numberWithOptions(signed: false, decimal: false)
                              : TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    enabled: false,
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: AppColors.color3.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
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
                  minLines: type == 'textarea' ? 4 : 1,
                  maxLines: type == 'textarea' ? 4 : 2,
                  onChanged: (text) {
                    cubit.updateCustomField(
                        TaskCustomFiled(element.fieldId, element.name, text, element.type));
                  },
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  textController.text = '';
                  cubit.updateCustomField(
                      TaskCustomFiled(element.fieldId, element.name, '', element.type));
                },
                icon: Icon(Icons.clear))
          ],
        ),
      );

    return Padding(
      padding: EdgeInsets.only(bottom: d, top: 4.0),
      child: TextField(
        controller: textController,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.color1,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: type == 'text'
            ? TextInputType.text
            : type == 'textarea'
                ? TextInputType.multiline
                : type == 'int'
                    ? TextInputType.numberWithOptions(signed: false, decimal: false)
                    : TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(10),
          enabled: true,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.color3.withOpacity(0.4),
              width: 2,
            ),
          ),
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
        minLines: type == 'textarea' ? 4 : 1,
        maxLines: type == 'textarea' ? 4 : 2,
        onChanged: (text) {
          cubit.updateCustomField(
              TaskCustomFiled(element.fieldId, element.name, text, element.type));
        },
      ),
    );
  }

  _getCheckBox(String value, TaskCustomFiled element) {
    List<dynamic> list = element.value ?? [];

    return CheckboxListTile(
      onChanged: (b) {
        setState(() {
          if (b!) {
            list.add(value);
          } else {
            list.remove(value);
          }

          cubit.updateCustomField(
              TaskCustomFiled(element.fieldId, element.name, list, element.type));
        });
      },
      value: list.contains(value),
      activeColor: list.contains(value) ? null : Colors.grey,
      title: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: list.contains(value) ? AppColors.secondary : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
