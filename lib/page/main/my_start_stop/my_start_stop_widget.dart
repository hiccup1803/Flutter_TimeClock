import 'dart:core';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/connect/connect_status_cubit.dart';
import 'package:staffmonitor/bloc/files/file_upload_cubit.dart';
import 'package:staffmonitor/bloc/main/break/session_break_cubit.dart';
import 'package:staffmonitor/bloc/main/sessions/my_sessions_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/model/session_break.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/count_time_widget.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';

import '../../../model/loadable.dart';
import '../../../model/wage.dart';
import '../../../utils/functions.dart';
import '../../../widget/custom_elevated_button.dart';
import '../../../widget/dialog/location_permission_reason_dialog.dart';
import 'break_tile.dart';
import 'modal_bottom_sheets/create_note_widget.dart';
import 'modal_bottom_sheets/create_project_widget.dart';
import 'my_start_stop.i18n.dart';
import 'projects_dropdownbutton.dart';

class MyStartStopWidget extends StatefulWidget {
  const MyStartStopWidget(this.profile);

  final Profile profile;

  @override
  _MySessionsWidgetState createState() => _MySessionsWidgetState();
}

class _MySessionsWidgetState extends State<MyStartStopWidget> {
  final log = Logger('SessionsWidget');

  late TextEditingController hourRateController;
  bool _netStatus = false;

  @override
  void initState() {
    super.initState();
    hourRateController = TextEditingController(text: widget.profile.hourRate ?? '');
    _netStatus = BlocProvider.of<ConnectStatusCubit>(context).state;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return BlocListener<ConnectStatusCubit, bool>(
      listener: (context, netStatus) {
        setState(() {
          _netStatus = netStatus;
        });
      },
      child: BlocConsumer<MySessionsCubit, MySessionsState>(
        listener: (context, state) {
          if (state is SessionsReady) {
            hourRateController.text =
                state.currentSession.value?.hourRate ?? widget.profile.hourRate ?? '';
            if (state.currentSession.hasError) {
              FailureDialog.show(
                context: context,
                content: Text(state.currentSession.error?.formatted() ?? ''),
              );
            }
          }
        },
        builder: (context, state) {
          bool trackGPS = const bool.fromEnvironment('always_track_gps') || widget.profile.trackGps;

          Loadable<Session?> currentSession = Loadable.ready(null);
          Project? selectedProject;
          bool hasLocationPermission = false;
          bool sessionStarted = false;

          if (state is SessionsReady) {
            hasLocationPermission = state.hasLocationPermission;
            currentSession = state.currentSession;
            sessionStarted = currentSession.value != null;
            selectedProject = state.selectedProject;
            if (currentSession.value != null && currentSession.inProgress != true) {
              log.fine('SessionBreakCubit init');
              BlocProvider.of<SessionBreakCubit>(context).init(currentSession.value!.id);
            }
          }

          return BlocListener<FileUploadCubit, FileUploadState>(
            listenWhen: (previous, current) =>
            current is FileUploadInProgress && current.finishedUploads.isNotEmpty,
            listener: (context, state) {
              log.fine('BlocListener - file upload: $state');
              if (state is FileUploadInProgress) {
                if (state.finishedUploads.isNotEmpty) {
                  final task = state.finishedUploads.first;
                  if (sessionStarted)
                    BlocProvider.of<FileUploadCubit>(context)
                        .taskConsumed(task, sessionId: currentSession.value!.id);
                  final uploadResult = state.uploadResult[task];
                  if (uploadResult is AppFile) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('%s - upload completed.'.i18n.fill([uploadResult.name ?? ''])),
                    ));
                    log.fine('BlocListener - file upload: uploadResult $uploadResult');
                    BlocProvider.of<MySessionsCubit>(context).refreshCurrent(trackGPS: trackGPS);
                  } else {
                    log.fine('BlocListener - file upload: error $uploadResult');
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 28),
                  Text(
                    'Current Project'.i18n,
                    style: GoogleFonts.poppins(
                      color: themeData.textTheme.headline2!.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.profile.availableProjects?.isNotEmpty != true)
                    SizedBox(
                      child: Text('Loading'.i18n),
                    ),
                  if (widget.profile.availableProjects?.isNotEmpty == true)
                    ProjectsDropdownButton(
                      selectedProject: selectedProject,
                      listProjects: [
                        null,
                        ...(widget.profile.availableProjects ?? []),
                      ],
                      onChanged: sessionStarted
                          ? null
                          : (pickedProject) {
                        BlocProvider.of<MySessionsCubit>(context)
                            .selectProject(pickedProject);
                      },
                    ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: widget.profile.allowOwnProjects != true ||
                        sessionStarted ||
                        _netStatus != true
                        ? null
                        : () => showCustomModalBottomSheet(
                      context: context,
                      builder: (modelContext) => CreateProjectWidget(
                        createProject: (name, color) {
                          return BlocProvider.of<MySessionsCubit>(context).createProject(
                            Project.create(name: name, color: color),
                          );
                        },
                      ),
                    ).then(
                          (pickedProject) async {
                        await BlocProvider.of<AuthCubit>(context).refreshProfile();
                        if (pickedProject != null) {
                          BlocProvider.of<MySessionsCubit>(context)
                              .selectProject(pickedProject);
                        }
                      },
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.profile.allowOwnProjects != true ||
                              sessionStarted ||
                              _netStatus != true
                              ? Colors.grey.shade400
                              : themeData.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Add new project'.i18n,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.profile.allowOwnProjects != true ||
                              sessionStarted ||
                              _netStatus != true
                              ? Colors.grey.shade400
                              : themeData.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  CountTimeWidget(
                    key: ValueKey(currentSession.value?.id),
                    startTime: currentSession.value?.clockIn,
                    builder: (context, text) => Text(
                      text,
                      style: GoogleFonts.poppins(
                          fontSize: 50,
                          fontWeight: FontWeight.w500,
                          color: themeData.textTheme.headline1!.color),
                    ),
                  ),
                  Text(
                    sessionStarted
                        ? '${'Started at'.i18n}: ${currentSession.value!.clockIn!.format('d MMM, yyyy HH:mm:ss')}'
                        : 'Select a project or create new one'.i18n,
                    style: GoogleFonts.poppins(
                      color: themeData.textTheme.headline2!.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 30),
                  if (widget.profile.allowWageView)
                    Text(
                      'Hourly Rate'.i18n,
                      style: GoogleFonts.poppins(
                        color: themeData.textTheme.headline1!.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (widget.profile.allowWageView) SizedBox(height: 5),
                  if (widget.profile.allowWageView)
                    SizedBox(
                      width: 100,
                      height: 36,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        enabled: widget.profile.allowNewRate && sessionStarted == false,
                        inputFormatters: [decimalFormatter],
                        keyboardType: TextInputType.number,
                        controller: hourRateController,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeData.textTheme.headline1!.color,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 8, right: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: themeData.textTheme.headline2!.color,
                          ),
                          hintText: '00.00',
                          suffix: widget.profile.rateCurrency?.trim().isNotEmpty == true ||
                              currentSession.value?.rateCurrency?.isNotEmpty == true
                              ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              currentSession.value?.rateCurrency ??
                                  widget.profile.rateCurrency!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: themeData.textTheme.headline2!.color,
                              ),
                            ),
                          )
                              : null,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: themeData.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: themeData.textTheme.headline3!.color!,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 35),
                  BlocBuilder<SessionBreakCubit, SessionBreakState>(
                    builder: (context, state) {
                      bool breakUpdating = state is SessionBreakApiProcess;
                      bool breakStarted = false;
                      SessionBreak? currentBreak;
                      if (state is SessionBreakOpen) {
                        currentBreak = state.currentBreak;
                        breakStarted = state.currentBreak != null;
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Spacer(),
                          Expanded(
                            flex: 5,
                            child: CustomElevatedButton(
                              label: sessionStarted ? 'End session'.i18n : 'Start session'.i18n,
                              fontColor: Colors.white,
                              minimumSize: Size(120, 45),
                              color:
                              sessionStarted ? const Color(0xFFEE4936) : themeData.primaryColor,
                              enabled: !breakStarted,
                              loading: currentSession.inProgress,
                              onPressed: () {
                                if (currentSession.value != null) {
                                  BlocProvider.of<MySessionsCubit>(context)
                                      .finishSession(currentSession.value!)
                                      .then((value) {
                                    BlocProvider.of<SessionBreakCubit>(context).clear();
                                  });
                                } else {
                                  context.unFocus();
                                  if (trackGPS && hasLocationPermission == false) {
                                    LocationPermissionReasonDialog.show(
                                      context: context,
                                      onApprove: () => BlocProvider.of<MySessionsCubit>(context)
                                          .requestPermission()
                                          .then((value) {
                                        if (value)
                                          BlocProvider.of<MySessionsCubit>(context)
                                              .quickStartSession(
                                            selectedProject,
                                            trackGPS: trackGPS,
                                            hourWage: widget.profile.allowNewRate
                                                ? Wage(hourRateController.text,
                                                widget.profile.rateCurrency)
                                                : null,
                                          );
                                      }),
                                    );
                                  } else {
                                    BlocProvider.of<MySessionsCubit>(context).quickStartSession(
                                      selectedProject,
                                      trackGPS: trackGPS,
                                      hourWage: widget.profile.allowNewRate
                                          ? Wage(
                                          hourRateController.text, widget.profile.rateCurrency)
                                          : null,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          Spacer(),
                          Expanded(
                            flex: 5,
                            child: CustomElevatedButton(
                              label: breakStarted ? 'End break'.i18n : 'Start break'.i18n,
                              fontColor: Colors.white,
                              minimumSize: Size(120, 45),
                              color: sessionStarted
                                  ? breakStarted
                                  ? const Color(0xFFEE4936)
                                  : const Color(0xFF00D599)
                                  : themeData.textTheme.headline3!.color,
                              enabled: sessionStarted,
                              loading: breakUpdating,
                              onPressed: () {
                                if (currentBreak == null) {
                                  BlocProvider.of<SessionBreakCubit>(context)
                                      .startSessionBreak(currentSession.value!.id);
                                } else {
                                  BlocProvider.of<SessionBreakCubit>(context)
                                      .endSessionBreak(currentBreak);
                                }
                              },
                            ),
                          ),
                          Spacer(),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 25),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Action(
                              icon: Icons.camera_alt_rounded,
                              label: 'Photo'.i18n,
                              started: sessionStarted,
                              onTap: sessionStarted &&
                                  currentSession.inProgress != true &&
                                  (currentSession.value?.files.length ?? 0) <
                                      (widget.profile.maxFilesInSession ?? 0) &&
                                  _netStatus == true
                                  ? () async {
                                final file =
                                await _pickPhoto(ImageSource.camera, context: context);
                                if (file != null) {
                                  showCustomModalBottomSheet(
                                    context: context,
                                    builder: (modalContext) => CreateNote(
                                      initialNote: '',
                                      createNote: (text) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('Uploading file'.i18n),
                                          duration: Duration(seconds: 1),
                                        ));
                                        return BlocProvider.of<FileUploadCubit>(context)
                                            .uploadFile(file, sessionId: currentSession.value!.id, note: text);
                                      },
                                      onClose: () {
                                        BlocProvider.of<FileUploadCubit>(context).uploadFile(
                                            file,
                                            sessionId: currentSession.value!.id);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('Uploading file'.i18n),
                                          duration: Duration(seconds: 1),
                                        ));
                                      },
                                    ),
                                  );
                                }
                              }
                                  : null,
                            ),
                            const VerticalDivider(thickness: 1.5),
                            Action(
                              icon: Icons.description_rounded,
                              label: 'Files'.i18n,
                              started: sessionStarted,
                              onTap: sessionStarted && currentSession.inProgress != true
                                  ? () => Dijkstra.editSession(
                                currentSession.value,
                                onChanged: ([session]) {
                                  if (session != null) {
                                    BlocProvider.of<MySessionsCubit>(context).refresh(
                                      force: true,
                                      trackGPS: trackGPS,
                                    );
                                  }
                                },
                                onDeleted: ([s]) => null,
                              )
                                  : null,
                            ),
                            const VerticalDivider(thickness: 1.5),
                            Action(
                              icon: Icons.sticky_note_2_rounded,
                              label: 'Note'.i18n,
                              started: sessionStarted,
                              onTap: sessionStarted && currentSession.inProgress != true
                                  ? () => showCustomModalBottomSheet(
                                context: context,
                                builder: (modalContext) => CreateNote(
                                  initialNote: currentSession.value?.note,
                                  createNote: (text) {
                                    return BlocProvider.of<MySessionsCubit>(context)
                                        .updateSessionNote(text);
                                  },
                                ),
                              )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (sessionStarted)
                    BlocBuilder<SessionBreakCubit, SessionBreakState>(
                      builder: (context, state) {
                        List<SessionBreak> breakList = state.breakList;
                        bool loading = state is SessionBreakApiProcess;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                'Breaks'.i18n,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: themeData.textTheme.headline1!.color,
                                ),
                              ),
                            ),
                            if (breakList.isEmpty && !loading)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text(
                                    'You have no breaks so far.'.i18n,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: themeData.textTheme.headline2!.color,
                                    ),
                                  ),
                                ),
                              ),
                            if (breakList.isEmpty && loading)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: SpinKitWave(
                                  color: Theme.of(context).primaryColor,
                                  size: 32,
                                ),
                              ),
                            if (breakList.isNotEmpty)
                              ListView.separated(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: breakList.length,
                                itemBuilder: (context, i) {
                                  return BreakTile(
                                    sessionBreak: breakList[i],
                                  );
                                },
                                separatorBuilder: (context, _) => SizedBox(height: 12),
                              ),
                            if (breakList.isNotEmpty) SizedBox(height: kToolbarHeight),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Action extends StatelessWidget {
  const Action({
    Key? key,
    required this.icon,
    required this.label,
    required this.started,
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final bool started;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: (started && onTap != null)
                ? themeData.primaryColor
                : themeData.textTheme.headline2!.color,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: (started && onTap != null)
                  ? themeData.primaryColor
                  : themeData.textTheme.headline2!.color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Future<PlatformFile?> _pickPhoto(ImageSource source, {BuildContext? context}) async {
  try {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      var size = await pickedFile.length();
      var byte = await pickedFile.readAsBytes();
      PlatformFile result = PlatformFile(
          readStream: null, path: pickedFile.path, size: size, name: pickedFile.name, bytes: byte);
      return result;
    }
  } catch (e) {
    print('e: $e');
  }
  return null;
}
