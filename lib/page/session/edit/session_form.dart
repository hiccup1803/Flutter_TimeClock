import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/files/file_upload_cubit.dart';
import 'package:staffmonitor/bloc/session/edit/edit_session_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/my_start_stop/projects_dropdownbutton.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/count_time_widget.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/file_details_dialog.dart';
import 'package:staffmonitor/widget/dialog/file_size_over_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';

import '../../../dijkstra.dart';
import '../../../model/profile.dart';
import '../../../model/session.dart';
import '../../../widget/dialog/confirm_dialog.dart';
import '../../../widget/dialog/failure_dialog.dart';
import '../../../widget/dialog/success_dialog.dart';
import '../../../widget/dialog/users_picker_dialog.dart';
import '../sessions.i18n.dart';
import 'edit_session_page.dart';

part 'session_files.dart';

class SessionForm extends StatefulWidget {
  final String? initialNote;
  final String? sessionHourRate;
  final String? sessionBonus;
  final String? sessionNewBonus;
  final String? sessionCurrency;
  final Profile? profile;
  final bool admin;
  final bool isNew;

  const SessionForm(this.initialNote, this.sessionHourRate, this.profile, this.admin,
      this.sessionBonus, this.sessionNewBonus, this.sessionCurrency,
      {this.isNew = false});

  @override
  _SessionFormState createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final log = Logger('SessionForm');

  late TextEditingController noteController;
  late TextEditingController hourRateController;
  late TextEditingController rateCurrencyController;
  late TextEditingController sessionBonusController;
  late TextEditingController sessionNewBonusController;
  late TextEditingController startController;
  late TextEditingController startNewController;
  late TextEditingController endController;
  late TextEditingController endNewController;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.initialNote ?? '');
    noteController.addListener(noteChanged);

    hourRateController = TextEditingController(text: widget.sessionHourRate ?? '0.00');
    hourRateController.addListener(hourRateChanged);

    rateCurrencyController = TextEditingController(
        text: widget.sessionCurrency ?? widget.profile!.rateCurrency ?? 'PLN');
    rateCurrencyController.addListener(rateCurrencyChanged);

    sessionBonusController = TextEditingController(text: widget.sessionBonus ?? '0.00');
    sessionBonusController.addListener(sessionBonusChanged);

    sessionNewBonusController = TextEditingController(text: widget.sessionNewBonus ?? '0.00');
    sessionNewBonusController.addListener(sessionNewBonusChanged);

    startController = TextEditingController(text: '');
    startNewController = TextEditingController(text: '');
    endController = TextEditingController(text: '');
    endNewController = TextEditingController(text: '');

    isEditing = widget.isNew;
  }

  @override
  void dispose() {
    noteController.dispose();
    hourRateController.dispose();
    sessionBonusController.dispose();
    rateCurrencyController.dispose();
    startController.dispose();
    startNewController.dispose();
    endController.dispose();
    endNewController.dispose();
    super.dispose();
  }

  EditSessionCubit get cubit => BlocProvider.of<EditSessionCubit>(context);

  void noteChanged() => cubit.noteChanged(noteController.text);

  void hourRateChanged() => cubit.hourRateChanged(hourRateController.text);

  void rateCurrencyChanged() => cubit.rateCurrencyChanged(rateCurrencyController.text);

  void sessionBonusChanged() => cubit.sessionBonusChanged(sessionBonusController.text);

  void sessionNewBonusChanged() => cubit.sessionNewBonusChanged(sessionNewBonusController.text);

  void changeDate(DateTime date) {
    showDatePicker(
      context: context,
      initialDate: date.toUserTimeZone,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) cubit.changeDate(date);
    });
  }

  void changeClockIn(DateTime clockIn) {
    showTimePicker(
      context: context,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
      initialTime: TimeOfDay.fromDateTime(clockIn.toUserTimeZone),
    ).then((value) {
      if (value != null) cubit.changeClockInTime(value);
    });
  }

  void changeClockOut(DateTime? clockOut) {
    showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(clockOut?.toUserTimeZone ?? DateTime.now().toUserTimeZone),
    ).then((value) {
      if (value != null) cubit.changeClockOutTime(value);
    });
  }

  void deleteSession() {
    ConfirmDialog.show(
            context: context,
            title: Text('Delete session'.i18n),
            content: Text(
                "This action can't be undone. Are you sure you want to delete this session?".i18n))
        .then((result) {
      if (result == true) {
        cubit.deleteSession();
      }
    });
  }

  bool isEditing = false;

  Session? _savedSession;
  int? _changeType;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('_savedSession != null -> ${_savedSession != null}');
        if (_savedSession != null) {
          Navigator.pop(context, {
            EditSessionPage.CHANGE_TYPE_KEY: _changeType,
            EditSessionPage.SESSION_KEY: _savedSession,
          });
          return false;
        }
        return true;
      },
      child: BlocConsumer<EditSessionCubit, EditSessionState>(
        listenWhen: (previous, current) =>
            current is EditSessionError || current is EditSessionSaved,
        listener: (context, state) {
          if (state is EditSessionError) {
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
          } else if (state is EditSessionSaved) {
            SuccessDialog.show(
              context: context,
              content: Text(
                  state is EditSessionDeleted ? 'Session deleted!'.i18n : 'Session saved!'.i18n),
            ).then((_) {
              _changeType = state is EditSessionDeleted
                  ? EditSessionPage.SESSION_DELETED
                  : EditSessionPage.SESSION_CHANGED;
              _savedSession = state.session?.copyWith();
              log.fine('_savedSession not empty with change type: $_changeType');
              if (state.closePage == true) {
                Dijkstra.goBack(state is EditSessionDeleted
                    ? EditSessionPage.SESSION_DELETED
                    : EditSessionPage.SESSION_CHANGED);
              } else {
                BlocProvider.of<EditSessionCubit>(context).stateConsumed();
              }
            });
          }
        },
        builder: (context, state) {
          Session? session;
          bool processing = true;
          // bool canClearClockOut = false;
          // bool requireSaving = false;
          if (state is EditSessionReady) {
            session = state.session;
            // requireSaving = state.requireSaving;
            // canClearClockOut = state.hadClockOut == false;
            processing = false;
          } else if (state is EditSessionProcessing) {
            session = state.session;
          } else if (state is EditSessionSaved) {
            session = state.session;
          } else if (state is EditSessionError) {
            session = state.session;
          }

          startController.text = session?.clockIn?.format('HH:mm') ?? '--:--';
          startNewController.text = session?.clockInProposed?.format('HH:mm') ?? '--:--';
          endController.text = session?.clockOut?.format('HH:mm') ?? '--:--';
          endNewController.text = session?.clockOutProposed?.format('HH:mm') ?? '--:--';
          log.fine('build with session: $session');
          log.fine('build with session wage: ${session?.totalWage}');
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.admin == true) SizedBox(height: 20),
                if (widget.admin == true)
                  Text(
                    'Employee'.i18n,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.color3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (widget.admin == true &&
                    session is AdminSession &&
                    (!isEditing || session.isCreate != true))
                  FutureBuilder<Profile>(
                    future: injector.usersRepository.getUser(session.userId),
                    builder: (context, snapshot) {
                      Profile? profile;
                      if (snapshot.hasData) {
                        profile = snapshot.requireData;
                      }
                      return Text(
                        '${profile?.name ?? ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.color1,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                if (widget.admin == true &&
                    session is AdminSession &&
                    isEditing &&
                    session.isCreate)
                  FutureBuilder<Paginated<Profile>>(
                    future: injector.usersRepository.getAllUser(),
                    builder: (context, snapshot) {
                      String _employeeName = '...';
                      if (snapshot.hasData) {
                        snapshot.data!.list!.forEach((element) {
                          if (element.id == (session as AdminSession).userId) {
                            _employeeName = element.name!;
                          }
                        });
                        if (_employeeName.isEmpty) {
                          _employeeName = 'Select Employee'.i18n;
                        }
                      }
                      return InkWell(
                        onTap: () {
                          int selected = snapshot.data!.list!.indexWhere(
                              (element) => element.id == (session as AdminSession).userId);
                          Future.delayed(Duration(milliseconds: 300), () {
                            selectProfile(
                              context,
                              'Select Employee'.i18n,
                              snapshot.data!.list ?? [],
                              selected,
                            ).then((selectProfile) {
                              if (selectProfile != null) {
                                cubit.sessionUserSet(selectProfile.id);
                              }
                            });
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black26),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _employeeName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppColors.color1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(height: 20),
                Text(
                  'Project'.i18n,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.color3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isEditing)
                  ProjectsDropdownButton(
                    selectedProject: session?.project,
                    listProjects: [
                      null,
                      ...(widget.profile?.availableProjects ?? []),
                    ],
                    onChanged: (project) {
                      cubit.updateProject(project);
                    },
                  ),
                if (!isEditing)
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: session?.project?.color ?? Colors.white,
                          border: Border.all(color: session?.project?.color ?? Colors.black87),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          session?.project?.name ?? 'no project'.i18n,
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: AppColors.color1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session Details'.i18n,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.color3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: isEditing ? () => changeDate(session!.clockIn!) : null,
                          child: Text(
                            session?.clockIn?.format('MMM d yyyy') ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppColors.color1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!isEditing && session?.verified == true)
                      Container(
                        width: 85,
                        padding: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            'Approved'.i18n,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (!isEditing && session?.verified == false && widget.admin)
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<EditSessionCubit>(context).accept();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.secondary,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Accept'.i18n,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                if (widget.isNew == false && session?.verified == false)
                  Text(
                    'Original:'.i18n,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.color3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (widget.isNew == false) SizedBox(height: 8),
                Row(
                  children: [
                    CustomFormField(
                      label: 'Start'.i18n,
                      controller: startController,
                      // initValue: session?.clockIn?.format('HH:mm'),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      enabled: session?.isCreate == true || isEditing && session?.verified == true,
                      onTap: () => changeClockIn(session!.clockIn!),
                    ),
                    SizedBox(width: 5),
                    SizedBox(
                      width: 10,
                      child: Divider(
                        thickness: 1.5,
                        color: AppColors.color3,
                      ),
                    ),
                    SizedBox(width: 5),
                    CustomFormField(
                      label: 'End'.i18n,
                      controller: endController,
                      // initValue: session?.clockOut?.format('HH:mm'),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      enabled: session?.isCreate == true || isEditing && session?.verified == true,
                      onTap: () => changeClockOut(session!.clockOut),
                    ),
                    SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Session Duration'.i18n,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.color3,
                            ),
                          ),
                          if (session?.duration == null)
                            CountTimeWidget(
                              startTime: session?.clockIn,
                              format: DurationFormat.HMS,
                              builder: (context, formattedTime) {
                                return Text(
                                  formattedTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.color1,
                                  ),
                                );
                              },
                            ),
                          if (session?.duration != null)
                            Text(
                              session?.duration?.formatHoursMinutesSeconds ?? '--:--:--',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.isNew == false && session?.verified == false) SizedBox(height: 15),
                if (widget.isNew == false && session?.verified == false)
                  Text(
                    'New value:'.i18n,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.color3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (widget.isNew == false && session?.verified == false) SizedBox(height: 8),
                if (widget.isNew == false && session?.verified == false)
                  Row(
                    children: [
                      CustomFormField(
                        label: 'Start'.i18n,
                        controller: startNewController,
                        // initValue: session?.clockIn?.format('HH:mm'),
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        enabled: isEditing || session?.isCreate == true,
                        onTap: () => changeClockIn(session!.clockIn!),
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 10,
                        child: Divider(
                          thickness: 1.5,
                          color: AppColors.color3,
                        ),
                      ),
                      SizedBox(width: 5),
                      CustomFormField(
                        label: 'End'.i18n,
                        controller: endNewController,
                        // initValue: session?.clockOut?.format('HH:mm'),
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        enabled: isEditing || session?.isCreate == true,
                        onTap: () => changeClockOut(session!.clockOut),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                Row(
                  children: [
                    CustomFormField(
                      label: 'Hourly Rate'.i18n,
                      controller: hourRateController,
                      enabled: true,
                      keyboardType: TextInputType.number,
                      readOnly: (isEditing &&
                              (widget.admin == true ||
                                  widget.profile?.allowRateEdit == true ||
                                  (session?.isCreate == true &&
                                      widget.profile?.allowNewRate == true))) !=
                          true,
                    ),
                    SizedBox(width: 5),
                    SizedBox(
                      width: 10,
                      child: Divider(
                        thickness: 1.5,
                        color: AppColors.color3,
                      ),
                    ),
                    SizedBox(width: 5),
                    CustomFormField(
                      label: 'Currency'.i18n,
                      controller: rateCurrencyController,
                      // enabled: isEditing,
                      enabled: true,
                      keyboardType: TextInputType.text,
                      readOnly: (isEditing &&
                              (widget.admin == true ||
                                  widget.profile?.allowRateEdit == true ||
                                  (session?.isCreate == true &&
                                      widget.profile?.allowNewRate == true))) !=
                          true,
                    ),
                    SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget.profile!.allowWageView && session?.isCreate == false)
                            Text(
                              'Total Earned'.i18n,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color3,
                              ),
                            ),
                          if (widget.profile!.allowWageView &&
                              session?.isCreate == false &&
                              isEditing != true)
                            Text(
                              '${session?.totalWage == null ? '' : session?.totalWage == 'null' ? '' : session?.totalWage} ${session?.rateCurrency ?? '--'}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color1,
                              ),
                            ),
                          if (widget.profile!.allowWageView &&
                              session?.isCreate == false &&
                              isEditing == true)
                            Text(
                              '-- ${session?.rateCurrency ?? '--'}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (widget.isNew == false && session?.verified == false)
                  Text(
                    'Original:'.i18n,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.color3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (widget.isNew == false && session?.verified == false) SizedBox(height: 8),
                CustomFormField(
                  label: 'Bonus'.i18n,
                  keyboardType: TextInputType.text,
                  controller: sessionBonusController,
                  enabled: session?.isCreate == true || isEditing && session?.verified == true,
                  readOnly: widget.profile!.allowBonus != true,
                  width: 105,
                  suffix: Text(
                    session?.rateCurrency ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                if (widget.isNew == false && session?.verified == false) SizedBox(height: 20),
                if (widget.isNew == false && session?.verified == false)
                  Text(
                    'New value:'.i18n,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.color3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (widget.isNew == false && session?.verified == false) SizedBox(height: 8),
                if (widget.isNew == false && session?.verified == false)
                  CustomFormField(
                    label: 'Bonus'.i18n,
                    keyboardType: TextInputType.text,
                    controller: sessionNewBonusController,
                    enabled: session?.isCreate == true || isEditing && session?.verified == true,
                    readOnly: widget.profile!.allowBonus != true,
                    width: 105,
                    suffix: Text(
                      session?.rateCurrency ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Text(
                  'Note'.i18n,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.color1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  controller: noteController,
                  maxLines: 5,
                  readOnly: isEditing != true && session?.isCreate != true,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.color1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add Note'.i18n,
                    isDense: true,
                    // enabled: isEditing,
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
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    context.unFocus();
                    if (processing) {
                      return;
                    }
                    if (isEditing || session?.isCreate == true) {
                      setState(() {
                        isEditing = false;
                      });
                      BlocProvider.of<EditSessionCubit>(context).save();
                    } else {
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.secondary,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: processing
                      ? Center(
                          child: SpinKitWave(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 20,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEditing || session?.isCreate == true
                                  ? Icons.save_rounded
                                  : Icons.edit,
                              size: 24,
                              color: Colors.white,
                            ),
                            SizedBox(width: 15),
                            Text(
                              isEditing || session?.isCreate == true
                                  ? 'Save Session'.i18n
                                  : 'Edit Session'.i18n,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                ),
                SizedBox(height: 10),
                widget.profile!.isSupervisor == false ||
                        (widget.profile!.isSupervisor == true &&
                            widget.profile!.supervisorGpsAccess == true)
                    ? ElevatedButton(
                        onPressed: () => Dijkstra.openSessionLocations(
                          session!.id,
                          widget.admin == true,
                          session,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor.withOpacity(0.75),
                          shadowColor: Colors.transparent,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_rounded, size: 24, color: Colors.white),
                            SizedBox(width: 15),
                            Text(
                              'Show locations'.i18n,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                SizedBox(height: 20),
                Text(
                  '${'Files'.i18n} ${(session?.files.length)}/${widget.profile?.maxFilesInSession ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.color1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (session?.isCreate != false)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                    child: Text('Save session to upload files'.i18n),
                  ),
                if (session?.isCreate == false)
                  BlocListener<FileUploadCubit, FileUploadState>(
                    listenWhen: (previous, current) => true,
                    listener: (context, state) {
                      log.fine('BlocListener - file upload: $state');
                      if (state is FileUploadInProgress) {
                        if (state.finishedUploads.isNotEmpty) {
                          final task = state.finishedUploads.first;
                          BlocProvider.of<FileUploadCubit>(context)
                              .taskConsumed(task, sessionId: session!.id);
                          final uploadResult = state.uploadResult[task];
                          if (uploadResult is AppFile) {
                            _savedSession = BlocProvider.of<EditSessionCubit>(context)
                                .fileChanged(uploadResult);
                            _changeType = EditSessionPage.SESSION_CHANGED;
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
                    child: SessionFiles(
                      session!,
                      showAdd: (session.files.length) < (widget.profile?.maxFilesInSession ?? 0),
                      padding: const EdgeInsets.only(top: 8.0),
                      onDeleted: (file) {
                        _savedSession =
                            BlocProvider.of<EditSessionCubit>(context).fileDeleted(file);
                        _changeType = EditSessionPage.SESSION_CHANGED;
                      },
                      admin: widget.admin == true,
                    ),
                  ),
                // if (session?.isCreate == false && widget.profile?.allowRemove == true) Divider(),
                if (session?.isCreate == false &&
                    widget.profile?.allowRemove == true &&
                    ((widget.admin == true && widget.profile?.isAdmin == true) ||
                        widget.admin == false))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: processing ? null : deleteSession,
                        icon: Icon(Icons.delete_forever),
                        label: Text('Delete session'.i18n),
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                      ),
                    ),
                  ),
                SizedBox(height: kToolbarHeight),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Profile?> selectProfile(
      BuildContext context, String title, List<Profile> profiles, int selected) {
    return UsersPickerDialog.show(
      context: context,
      profiles: profiles,
      titleText: title,
      initialSelection: selected,
    );
  }
}

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    Key? key,
    this.controller,
    this.width,
    this.initValue,
    this.suffix,
    required this.label,
    required this.keyboardType,
    required this.readOnly,
    this.enabled = false,
    this.onTap,
  }) : super(key: key);

  final TextEditingController? controller;
  final double? width;
  final String label;
  final String? initValue;
  final Widget? suffix;
  final TextInputType keyboardType;
  final bool readOnly;
  final bool enabled;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 85,
      height: 40,
      child: TextFormField(
        controller: controller,
        onTap: onTap,
        initialValue: initValue,
        readOnly: readOnly,
        textAlign: TextAlign.center,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.color1,
        ),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          alignLabelWithHint: true,
          enabled: enabled,
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.color3,
            fontWeight: FontWeight.w600,
          ),
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.color3,
          ),
          hintText: "--:--",
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: readOnly ? AppColors.color3 : Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.color3,
              width: 1.5,
            ),
          ),
          suffix: suffix,
        ),
        onChanged: (value) {},
      ),
    );
  }
}
