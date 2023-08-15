import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/off_time/edit_off_time_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';

import 'off_time.i18n.dart';

class DetailOffTimePage extends BasePageWidget {
  static const int OFF_TIME_DELETED = 100;
  static const int OFF_TIME_CHANGED = 101;

  static const String START_DATE_KEY = 'start_day';
  static const String OFF_TIME_KEY = 'off_time';

  static Map<String, dynamic> buildArgs({OffTime? offTime, DateTime? startDay, DateTime? date}) => {
        START_DATE_KEY: startDay,
        OFF_TIME_KEY: offTime,
      };

  @override
  Widget buildSafe(BuildContext context, [profile]) {
    var args = readArgs(context)!;
    final theme = Theme.of(context);
    OffTime? paramOffTime = args[OFF_TIME_KEY];
    DateTime? paramDay = args[START_DATE_KEY];

    return BlocProvider<EditOffTimeCubit>(
      create: (context) =>
          EditOffTimeCubit(injector.offTimesRepository, injector.usersRepository, false)
            ..init(paramOffTime, startDay: paramDay),
      child: Scaffold(
          appBar: AppBar(
            leading: BackIcon(),
            titleSpacing: 0,
            title: Text(
              paramOffTime?.type == null ? 'Add off-time'.i18n : 'OffTime Detail'.i18n,
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
        if (state is EditOffTimeReady) {
          changed = state.changed;
        }
        return IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Dijkstra.goBack(changed ? DetailOffTimePage.OFF_TIME_CHANGED : null),
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
        if (state is EditOffTimeReady) {
          enabled = state.requireSaving;
          changed = state.changed;
        } else if (state is EditOffTimeProcessing) {
          loading = true;
        }
        log.fine('requireSaving: $enabled');

        return WillPopScope(
          onWillPop: () async {
            if (!loading) {
              if (changed) {
                Navigator.pop(context, DetailOffTimePage.OFF_TIME_CHANGED);
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

  void changeStartAt(OffTime offTime) {
    showDatePicker(
      context: context,
      initialDate: offTime.startDate!.toUserTimeZone,
      firstDate: DateTime(1970),
      lastDate: DateTime(3000),
    ).then((date) {
      if (date != null) cubit.changeStartDate(date);
    });
  }

  void changeEndAt(OffTime offTime) {
    showDatePicker(
      context: context,
      initialDate: offTime.endDate!.toUserTimeZone,
      firstDate: offTime.startDate!.toUserTimeZone,
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
              Dijkstra.goBack(DetailOffTimePage.OFF_TIME_DELETED);
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
        bool processing = true;
        if (state is EditOffTimeReady) {
          offTime = state.offTime;
          processing = false;
        } else if (state is EditOffTimeProcessing) {
          offTime = state.offTime;
        } else if (state is EditOffTimeSaved) {
          offTime = state.offTime;
        } else if (state is EditOffTimeError) {
          offTime = state.offTime;
        }
        log.fine('build with offTime: $offTime');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    offTime.isApproved
                        ? "Confirmed".i18n
                        : offTime.isWaiting
                            ? "Waiting".i18n
                            : "Denied".i18n,
                    style: TextStyle(fontSize: 25),
                  ),
                  Container(width: 8),
                  Icon(
                    offTime.isApproved
                        ? Icons.check_circle
                        : offTime.isWaiting
                            ? Icons.timelapse
                            : Icons.close,
                    color: offTime.isApproved
                        ? Colors.green
                        : offTime.isWaiting
                            ? Colors.lightBlueAccent
                            : Colors.orange,
                  ),
                ],
              ),
            ),
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
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start'.i18n,
                    style: theme.textTheme.subtitle2,
                  ),
                  Text(offTime.startAt ?? 'Select'.i18n.toLowerCase()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'End'.i18n,
                    style: theme.textTheme.subtitle2,
                  ),
                  Text(offTime.endAt ?? 'Select'.i18n.toLowerCase()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Duration'.i18n,
                    style: theme.textTheme.subtitle2,
                  ),
                  Text(
                    '%d days'.plural(offTime.days),
                    style: theme.textTheme.caption!.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Included in year'.i18n,
                    style: theme.textTheme.subtitle2,
                  ),
                  Text(
                    offTime.startDate!.year.toString(),
                    style: theme.textTheme.caption!.copyWith(fontSize: 16),
                  ),
                ],
              ),
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
