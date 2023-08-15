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
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/model/task_customfiled.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/task/edit/note_author_date_widget.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/file_details_dialog.dart';
import 'package:staffmonitor/widget/dialog/file_size_over_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../task.i18n.dart';

part 'task_files.dart';

class EditTaskPage extends BasePageWidget {
  static const String TASK_KEY = 'task';
  static const String SESSION_KEY = 'session';
  static const String DATE_KEY = 'date';
  static const int TASK_DELETED = 100;
  static const int TASK_CHANGED = 101;

  static Map<String, dynamic> buildArgs(CalendarTask? task, Session? session, {DateTime? date}) => {
        TASK_KEY: task,
        SESSION_KEY: session,
        DATE_KEY: date,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    final theme = Theme.of(context);
    Session? paramSession = args[SESSION_KEY];
    CalendarTask? paramTask = args[TASK_KEY];
    DateTime? paramDate = args[DATE_KEY];

    return MultiBlocProvider(
      providers: [
        BlocProvider<EditTaskCubit>(
            create: (context) => EditTaskCubit(
                injector.projectsRepository, injector.profileCompanyRepository, profile, false)
              ..init(
                paramTask,
                date: paramDate,
              )),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: BackIcon(),
          titleSpacing: 0,
          title: Text(
            (paramSession != null || paramTask != null) ? 'Task Details'.i18n : 'New Task'.i18n,
            style: theme.textTheme.headline4,
          ),
          actions: [
            if ((profile!.allowClosingOwnTasks || profile.allowClosingAssignedTasks) &&
                (profile.id == paramTask!.authorId))
              Center(child: SaveTaskButton()),
            Container(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: TaskContent(paramSession?.note, profile),
          ),
        ),
      ),
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
          onPressed: () => Dijkstra.goBack(changed ? EditTaskPage.TASK_CHANGED : null),
        );
      },
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
              Navigator.pop(context, changed ? EditTaskPage.TASK_CHANGED : null);
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

class TaskContent extends StatefulWidget {
  final String? initialNote;
  final Profile? profile;

  const TaskContent(this.initialNote, this.profile);

  @override
  _TaskContentState createState() => _TaskContentState();
}

class _TaskContentState extends State<TaskContent> {
  final log = Logger('TaskContent');

  late TextEditingController noteController;

  Map<int, TextEditingController> _controllerMap = Map();
  List<String> valueDropdownList = ['option1', 'option2'];
  List<String> valueCheckList = ['option1', 'option2', 'option3'];

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.initialNote ?? '');
    noteController.addListener(noteChanged);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  EditTaskCubit get cubit => BlocProvider.of<EditTaskCubit>(context);

  void noteChanged() => cubit.noteChanged(noteController.text);

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
      BlocProvider.of<EditTaskCubit>(context).changePriority(value);
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
      BlocProvider.of<EditTaskCubit>(context).changeStatus(value);
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
          noteController.text = "";
          BlocProvider.of<EditTaskCubit>(context).refresh();
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Text(
                'Title'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.color3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                task?.title ?? 'Task name'.i18n,
                // 'task'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.color1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Start'.i18n,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.color3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        task?.start
                                ?.format(
                                    task.wholeDay ? 'MM-dd-yyyy'.i18n : 'MM-dd-yyyy HH:mm'.i18n)
                                .toString() ??
                            DateTime.now().format(task?.wholeDay == true
                                ? 'MM-dd-yyyy'.i18n
                                : 'MM-dd-yyyy HH:mm'.i18n),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date End'.i18n,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.color3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        task?.end
                                ?.format(
                                    task.wholeDay ? 'MM-dd-yyyy'.i18n : 'MM-dd-yyyy HH:mm'.i18n)
                                .toString() ??
                            DateTime.now().format(task?.wholeDay == true
                                ? 'MM-dd-yyyy'.i18n
                                : 'MM-dd-yyyy HH:mm'.i18n),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.color1,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ],
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
                          (task?.priority == 0
                              ? '  low'
                              : task?.priority == 1
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
                  if (task!.authorId == widget.profile!.id)
                    InkWell(
                        onTap: () => _changePriority(task!.priority ?? 0),
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.color3.withOpacity(0.4), width: 2),
                              borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 12),
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
                  if (widget.profile!.allowClosingAssignedTasks &&
                      task.authorId == widget.profile!.id)
                    InkWell(
                        onTap: () => _changeStatus(task!.status ?? 0),
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.color3.withOpacity(0.4), width: 2),
                              borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 12),
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
              padding: EdgeInsets.fromLTRB(18, 8, 18, 2),
              child: Text(
                'Project'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.color3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Row(
                children: [
                  SizedBox(width: 2),
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.project?.color ?? Colors.white,
                      border: Border.all(color: task.project?.color ?? Colors.black87),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.project?.name ?? 'no project'.i18n,
                      softWrap: true,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.color1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Text(
                'Location'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.color3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 18.0, right: 16.0, bottom: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getCustomFieldView(task.customFields),
              ),
            ),
            InkWell(
              highlightColor: Colors.lightBlue.shade50,
              onTap: task.location?.isNotEmpty == true
                  ? () => launch('geo:0,0?q=${task!.location!.trim().split(r'\w').join('+')}')
                  : null,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 10.0, left: 18.0),
                child: Text(
                  task.location?.isNotEmpty == true ? task.location! : 'none'.i18n,
                  overflow: TextOverflow.visible,
                  style: task.location?.isNotEmpty == true
                      ? GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.color1,
                          fontWeight: FontWeight.bold,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, top: 8.0),
              child: Text(
                'Notes'.i18n,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.color1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...task.notes.map((calendarNote) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey, width: 1.5)),
                    margin: EdgeInsets.fromLTRB(10, 8, 10, 8),
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NoteAuthorAndDateWidget(calendarNote),
                        SizedBox(height: 4),
                        SelectableText(calendarNote.note ?? ""),
                      ],
                    ),
                  ),
                  calendarNote.id != task!.notes.last.id
                      ? TaskFiles(
                          calendarNote.id,
                          [calendarNote],
                          showAdd: task.notes.last.id != calendarNote.id ? false : true,
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                          onDeleted: (file) {
                            BlocProvider.of<EditSessionCubit>(context).fileDeleted(file);
                          },
                        )
                      : BlocListener<FileUploadCubit, FileUploadState>(
                          listenWhen: (previous, current) => true,
                          listener: (context, state) {
                            if (state is FileUploadInProgress) {
                              if (state.finishedUploads.isNotEmpty) {
                                final uploadTask = state.finishedUploads.first;
                                BlocProvider.of<FileUploadCubit>(context)
                                    .taskConsumed(uploadTask, taskId: calendarNote.id);
                                final uploadResult = state.uploadResult[uploadTask];
                                log.finest('$uploadResult');
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
                                        children:
                                            uploadResult.messages.map((e) => Text(e!)).toList(),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: TaskFiles(
                            calendarNote.id,
                            [calendarNote],
                            showAdd: task.notes.last.id != calendarNote.id
                                ? false
                                : task.notes.last.file != null
                                    ? false
                                    : true,
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                            onDeleted: (file) {
                              BlocProvider.of<EditTaskCubit>(context).fileDeleted(file);
                            },
                          ),
                        ),
                ],
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: noteController,
                enabled: processing == false,
                decoration: InputDecoration(
                  hintText: 'Add Note'.i18n,
                  isDense: true,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.color3,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.color3,
                      width: 1.5,
                    ),
                  ),
                ),
                minLines: 4,
                maxLines: 10,
              ),
            ),
            Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.topRight,
                child: saveNoteButton()),
          ],
        );
      },
    );
  }

  Widget saveNoteButton() {
    return BlocBuilder<EditTaskCubit, EditTaskState>(
      builder: (context, state) {
        bool enabled = false;
        bool loading = false;
        bool changed = false;
        if (state is EditTaskReady) {
          enabled = state.requireSaving;
          changed = state.changed;
        } else if (state is EditTaskProcessing) {
          loading = true;
        }
        if (noteController.text == "") {
          enabled = false;
        }
        log.fine('requireSaving: $enabled');

        return WillPopScope(
          onWillPop: () async {
            if (!loading) {
              if (changed) {
                ScaffoldMessenger.of(context).clearSnackBars();
                Navigator.pop(context, EditTaskPage.TASK_CHANGED);
                return false;
              } else {
                return true;
              }
            }
            return false;
          },
          child: ElevatedButton(
            onPressed: enabled
                ? () async {
                    bool result = await BlocProvider.of<EditTaskCubit>(context).saveNote();
                    if (result) noteController.text = "";
                  }
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  enabled ? 'Send note'.i18n : 'Sent'.i18n,
                ),
                if (loading) CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> getCustomFieldView(List<TaskCustomFiled> customFields) {
    List<Widget> arr = [];

    for (var element in customFields) {
      switch (element.type) {
        case 'text':
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
          break;
        case 'int':
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
          break;
        case 'float':
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
          break;
        case 'date':
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
          break;
        case 'datetime':
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
          break;
        case 'textarea':
          _getControllerOf(element, element.value ?? '');
          arr.add(Text(
            element.name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.color2,
              fontWeight: FontWeight.w600,
            ),
          ));
          arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element, d: 0.0));
          break;
        case 'check':
          arr.add(CheckboxListTile(
            onChanged: (value) => null,
            value: element.value == '0' ? false : true,
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
          break;
        case 'select':
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
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
              enabled: false,
              contentPadding: EdgeInsets.fromLTRB(8, 12, 0, 0),
            ),
            enabled: false,
            onChanged: (s) => null,
            showClearButton: true,
            clearButtonSplashRadius: 20,
          ));

          break;
        case 'checklist':
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
          value = DateFormat("yyyy-MM-dd").parse(s).format();
        }
        break;
      case 'datetime':
        if (s.isNotEmpty) {
          DateFormat("yyyy-MM-ddTHH:mm").parse(s).format('dd/MM/yyyy HH:mm a');
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
        readOnly: true,
        enableInteractiveSelection: true,
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
      onChanged: (b) {},
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
