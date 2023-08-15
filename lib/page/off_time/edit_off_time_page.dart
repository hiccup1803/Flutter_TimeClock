import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/off_time/edit_off_time_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/admin_off_time.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';

import 'off_time.i18n.dart';

class EditOffTimePage extends BasePageWidget {
  static const int OFF_TIME_DELETED = 100;

  static const String START_DATE_KEY = 'start_day';
  static const String OFF_TIME_KEY = 'off_time';
  static const String ADMIN_KEY = 'admin';

  static Map<String, dynamic> buildArgs(
          {OffTime? offTime, DateTime? startDay, DateTime? date, bool admin = false}) =>
      {
        START_DATE_KEY: startDay,
        OFF_TIME_KEY: offTime,
        ADMIN_KEY: admin,
      };

  @override
  Widget buildSafe(BuildContext context, [profile]) {
    var args = readArgs(context)!;
    final theme = Theme.of(context);
    OffTime? paramOffTime = args[OFF_TIME_KEY];
    DateTime? paramDay = args[START_DATE_KEY];
    bool admin = args[ADMIN_KEY] ?? false;

    return BlocProvider<EditOffTimeCubit>(
      create: (context) =>
          EditOffTimeCubit(injector.offTimesRepository, injector.usersRepository, admin)
            ..init(paramOffTime, startDay: paramDay),
      child: Scaffold(
          appBar: AppBar(
            leading: BackIcon(),
            titleSpacing: 0,
            title: Text(
              paramOffTime?.type == null ? 'Add off-time'.i18n : 'Edit off-time'.i18n,
              style: theme.textTheme.headline4,
            ),
            actions: [
              Center(child: SaveOffTimeButton()),
              Container(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: OffTimeForm(paramOffTime?.note),
              ),
            ),
          )),
    );
  }
}

class BackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditOffTimeCubit, EditOffTimeState>(
      builder: (context, state) {
        bool changed = false;
        OffTime? offTimeResult;
        if (state is EditOffTimeReady) {
          changed = state.changed;
          offTimeResult = state.offTime;
        }
        return IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Dijkstra.goBack(changed ? offTimeResult : null),
        );
      },
    );
  }
}

class SaveOffTimeButton extends StatelessWidget {
  final log = Logger('SaveButton');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditOffTimeCubit, EditOffTimeState>(
      builder: (context, state) {
        bool enabled = false;
        bool loading = false;
        bool changed = false;
        OffTime? offTime;
        if (state is EditOffTimeReady) {
          enabled = state.requireSaving;
          changed = state.changed;
          offTime = state.savedOffTime;
        } else if (state is EditOffTimeProcessing) {
          loading = true;
        }
        log.fine('requireSaving: $enabled');

        return WillPopScope(
          onWillPop: () async {
            if (!loading) {
              if (changed) {
                Navigator.pop(context, offTime);
                return false;
              } else {
                return true;
              }
            }
            return false;
          },
          child: ElevatedButton(
            onPressed: enabled ? BlocProvider.of<EditOffTimeCubit>(context).save : null,
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

class OffTimeForm extends StatefulWidget {
  final String? initialNote;

  OffTimeForm(this.initialNote);

  @override
  _OffTimeFormState createState() => _OffTimeFormState();
}

class _OffTimeFormState extends State<OffTimeForm> {
  final log = Logger('SessionForm');

  TextEditingController? noteController;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.initialNote ?? '');
    noteController!.addListener(noteChanged);
  }

  @override
  void dispose() {
    noteController!.dispose();
    super.dispose();
  }

  EditOffTimeCubit get cubit => BlocProvider.of<EditOffTimeCubit>(context);

  void noteChanged() => cubit.noteChanged(noteController!.text);

  void deleteOffTime(OffTime offTime) {
    ConfirmDialog.show(
            context: context,
            title: Text(offTime.type == 0 ? 'Delete off-time'.i18n : 'Delete vacation'.i18n),
            content: Text(offTime.type == 0
                ? "This action can't be undone. Are you sure you want to delete this off-time?".i18n
                : "This action can't be undone. Are you sure you want to delete this vacation?"
                    .i18n))
        .then((result) {
      if (result == true) {
        cubit.deleteSession();
      }
    });
  }

  void changeType(int type) {
    cubit.changeType(type);
  }

  void _changeUser(int? userId) {
    if (userId != null) {
      cubit.changeUser(userId);
    }
  }

  void _changeStatus(int? status) {
    if (status != null) {
      cubit.changeStatus(status);
    }
  }

  void changeStartAt(OffTime offTime) {
    showDatePicker(
      context: context,
      initialDate: offTime.startDate!,
      firstDate: DateTime(1970),
      lastDate: DateTime(3000),
    ).then((date) {
      if (date != null) cubit.changeStartDate(date);
    });
  }

  void changeEndAt(OffTime offTime) {
    showDatePicker(
      context: context,
      initialDate: offTime.endDate!,
      firstDate: offTime.startDate!,
      lastDate: DateTime(3000),
    ).then((date) {
      if (date != null) cubit.changeEndDate(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<EditOffTimeCubit, EditOffTimeState>(
      listenWhen: (previous, current) => current is EditOffTimeError || current is EditOffTimeSaved,
      listener: (context, state) {
        if (state is EditOffTimeError) {
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
        } else if (state is EditOffTimeSaved) {
          final offTime = state.offTime;
          SuccessDialog.show(
            context: context,
            content: Text(state is EditOffTimeDeleted
                ? (offTime.type == 0 ? 'Off-time deleted'.i18n : 'Vacation deleted'.i18n)
                : (offTime.type == 0 ? 'Off-time saved!'.i18n : 'Vacation saved!'.i18n)),
          ).then((value) {
            if (state.closePage == true) {
              Dijkstra.goBack(EditOffTimePage.OFF_TIME_DELETED);
            } else {
              cubit.stateConsumed();
            }
          });
        }
      },
      builder: (context, state) {
        if (state is EditOffTimeInitial) {
          return Container();
        }

        late OffTime offTime;
        List<Profile>? users;
        bool processing = true;
        if (state is EditOffTimeReady) {
          offTime = state.offTime;
          users = state.users;
          processing = false;
        } else if (state is EditOffTimeProcessing) {
          offTime = state.offTime;
        } else if (state is EditOffTimeSaved) {
          offTime = state.offTime;
        } else if (state is EditOffTimeError) {
          offTime = state.offTime;
        }
        log.fine('build with offTime: $offTime');

        Widget button(bool selected, {Widget? label, Function? onTap}) {
          if (selected == true) {
            return ElevatedButton.icon(
                icon: Icon(Icons.check_box),
                style: ElevatedButton.styleFrom(primary: theme.colorScheme.primary),
                onPressed: onTap as void Function()?,
                label: label!);
          }
          return OutlinedButton.icon(
              icon: Icon(Icons.check_box_outline_blank),
              style: OutlinedButton.styleFrom(primary: theme.colorScheme.primary),
              onPressed: onTap as void Function()?,
              label: label!);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (users != null)
              Container(
                decoration: sharedDecoration,
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.only(left: 8.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: (offTime as AdminOffTime).userId == -1 ? null : offTime.userId,
                    hint: Text('Select user'.i18n),
                    onChanged: offTime.isCreate == true ? _changeUser : null,
                    items: users
                        .map((e) => DropdownMenuItem<int>(
                              value: e.id,
                              child: Text(e.name ?? '${e.id}'),
                            ))
                        .toList(),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: button(
                      offTime.type == 0,
                      onTap: processing
                          ? null
                          : () {
                              changeType(0);
                            },
                      label: Text('Off-time'.i18n),
                    ),
                  ),
                  Container(width: 8),
                  Expanded(
                    child: button(
                      offTime.type == 1,
                      onTap: processing
                          ? null
                          : () {
                              changeType(1);
                            },
                      label: Text('Vacation'.i18n),
                    ),
                  ),
                ],
              ),
            ),
            if (users == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                constraints: BoxConstraints(minHeight: 40),
                child: offTime.type == 0
                    ? null
                    : Text(
                        'Administrator will get new notification and will have to approve it to make it official.'
                            .i18n,
                      ),
              ),
            if (users != null && offTime.type == 1)
              Container(
                decoration: sharedDecoration,
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.only(left: 8.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: (offTime as AdminOffTime).status,
                    onChanged: _changeStatus,
                    items: [
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text('Waiting for approval'.i18n),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('Approved'.i18n),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text('Denied'.i18n),
                      ),
                    ],
                  ),
                ),
              ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start'.i18n,
                    style: theme.textTheme.subtitle2,
                  ),
                  Text(
                    '%d days'.plural(offTime.days),
                    style: theme.textTheme.caption!.copyWith(fontSize: 16),
                  ),
                  Text(
                    'End'.i18n,
                    style: theme.textTheme.subtitle2,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: processing
                        ? null
                        : () {
                            changeStartAt(offTime);
                          },
                    child: Text(offTime.startAt ?? 'Select'.i18n.toLowerCase())),
                TextButton(
                    onPressed: processing
                        ? null
                        : () {
                            changeEndAt(offTime);
                          },
                    child: Text(offTime.endAt ?? 'Select'.i18n.toLowerCase()))
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, top: 8.0),
              child: Text(
                'Note'.i18n,
                style: theme.textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: noteController,
                enabled: processing == false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 10,
              ),
            ),
            if (offTime.isCreate == false) Divider(),
            if (offTime.isCreate == false)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: processing
                        ? null
                        : () {
                            deleteOffTime(offTime);
                          },
                    icon: Icon(Icons.delete_forever),
                    label: Text('Delete'.i18n),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
