part of 'calendar_widget.dart';

class CalendarsListWidget extends StatefulWidget {
  CalendarsListWidget();

  @override
  _CalendarsListWidgetState createState() => _CalendarsListWidgetState();
}

class _CalendarsListWidgetState extends State<CalendarsListWidget> {
  final log = Logger('ProjectsListWidget');

  String _chosenValue = 'month';

  List<String> filterList = ['month', 'week', 'day'];
  DateTime selectedDate = DateTime.now();

  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarsCubit, CalendarsState>(
      builder: (context, state) {
        Map<DateTime, List> offTimes = Map<DateTime, List>();
        List<CalendarTask> tasks = List.empty();
        List<bool> filterShowList = [true, false, false];
        Loadable<Paginated> sessions = Loadable.inProgress();

        if (state is CalendarsReady) {
          tasks = state.tasks ?? [];
          offTimes = state.offTimes.value ?? const {};
          sessions = state.sessions;
          filterShowList = state.filter ?? [true, false, false];
        }

        return Stack(
          children: [
            SfCalendar(
              view: CalendarView.month,
              controller: _controller,
              showDatePickerButton: false,
              headerHeight: 40,
              dataSource: MeetingDataSource(_getDataSource(tasks, offTimes, sessions)),
              // firstDayOfWeek: 1,
              onViewChanged: (ViewChangedDetails value) {
                Future.delayed(Duration(milliseconds: 100), () {
                  BlocProvider.of<CalendarsCubit>(context)
                      .changeMonth(value.visibleDates[(value.visibleDates.length / 2).floor()]);
                });
              },
              onTap: (CalendarTapDetails value) {
                if (value.targetElement == CalendarElement.appointment) {
                  if (value.appointments![0].type == 0) {
                    Future.delayed(
                        Duration(milliseconds: 250),
                        () => Dijkstra.editAdminTask(value.appointments![0].task,
                            onChanged: onEditTaskChange, onDeleted: onEditTaskDeleted));
                  } else if (value.appointments![0].type == 1) {
                    Future.delayed(
                        Duration(milliseconds: 250),
                        () => Dijkstra.editAdminSession(
                              value.appointments![0].session,
                              onChanged: onEditChange,
                              onDeleted: onEditDeleted,
                            ));
                  } else {
                    Future.delayed(
                        Duration(milliseconds: 250),
                        () => Dijkstra.detailOffTime(
                              value.appointments![0].offTime,
                            ));
                  }
                }
              },
              // onLongPress: (CalendarLongPressDetails value) {},
              timeSlotViewSettings: const TimeSlotViewSettings(
                  timeInterval: Duration(minutes: 60),
                  timeFormat: 'h:mm a',
                  nonWorkingDays: <int>[DateTime.friday, DateTime.saturday]),
              monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                  agendaViewHeight: 140,
                  showTrailingAndLeadingDates: true,
                  appointmentDisplayCount: 2,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
            ),
            Container(
                alignment: Alignment.topRight,
                child: Container(
                  height: 40,
                  width: 200,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.0)),
                        height: 30,
                        width: 80,
                        alignment: Alignment.center,
                        child: DropdownButton<String>(
                          underline: Container(),
                          focusColor: Colors.white,
                          value: _chosenValue,
                          //elevation: 5,
                          style: const TextStyle(color: Colors.white),
                          iconEnabledColor: Colors.black,
                          items: filterList.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value.i18n,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),

                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _chosenValue = value;
                              if (value == filterList[0])
                                _controller.view = CalendarView.month;
                              else if (value == filterList[1])
                                _controller.view = CalendarView.week;
                              else
                                _controller.view = CalendarView.day;
                            });
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () => filterDialog(filterShowList),
                        child: Container(
                          width: 40,
                          margin: EdgeInsets.fromLTRB(5, 9, 10, 9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Icon(Icons.filter_list_sharp, size: 25),
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        );
      },
    );
  }

  void onEditChange([Session? session]) {
    if (session == null) BlocProvider.of<AdminSessionsCubit>(context).refresh(force: true);
  }

  void onEditDeleted([AdminSession? session]) {
    BlocProvider.of<AdminSessionsCubit>(context).deleteSession(session!);
  }

  void onEditTaskChange() {
    BlocProvider.of<CalendarsCubit>(context).init(selectedDate);
  }

  void onEditTaskDeleted(CalendarTask? task) {
    BlocProvider.of<CalendarsCubit>(context).init(selectedDate);
  }

  List<Meeting> _getDataSource(
      List<CalendarTask> tasks, Map<DateTime, List> offTimes, Loadable<Paginated> sessions) {
    final List<Meeting> meetings = <Meeting>[];
    tasks.forEach((element) {
      meetings.add(Meeting(
        element.title ?? "",
        element.start ?? DateTime(1970),
        element.end ?? DateTime.now(),
        const Color(0xFF0F8644),
        element.wholeDay == true,
        element.id,
        0,
        task: element,
        session: Session.create(),
        offTime: OffTime.create(DateTime.now()),
      ));
    });
    List offTimeList = offTimes.values.toList();
    int tmpId = 0;
    offTimeList.forEach((element) {
      if (tmpId != element[0].id) {
        tmpId = element[0].id;
        meetings.add(Meeting(
            element[0].type == 1 ? "Off-time" : "Vacation",
            DateTime.parse(element[0].startAt),
            DateTime.parse(element[0].endAt),
            const Color(0xFF995577),
            false,
            element[0].id,
            element[0].type == 1 ? 2 : 3,
            task: CalendarTask.create(DateTime.now(),[]),
            session: Session.create(),
            offTime: element[0]));
      }
    });

    List sessionList = sessions.value != null ? sessions.value!.list ?? [] : [];
    sessionList.forEach((element) {
      meetings.add(Meeting(
          element.project != null ? element.project!.name : "",
          element.clockIn ?? DateTime.now(),
          element.clockOut ?? DateTime.now(),
          Color(0xff0077FF),
          false,
          element.id,
          1,
          task: CalendarTask.create(DateTime.now(),[]),
          session: element,
          offTime: OffTime.create(DateTime.now())));
    });
    return meetings;
  }

  void filterDialog(List<bool> filterValue) {
    CalendarsCubit myBloc = BlocProvider.of<CalendarsCubit>(context);

    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      builder: (context) {
        return BlocProvider<CalendarsCubit>.value(
          value: myBloc,
          child: AdminCalendarFilterWidget(filterValue: filterValue),
        );
      },
    );
  }
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from.toUserTimeZone;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to.toUserTimeZone;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  @override
  Object getId(int index) {
    return _getMeetingData(index).id;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }
    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(
    this.eventName,
    this.from,
    this.to,
    this.background,
    this.isAllDay,
    this.id,
    this.type, {
    required this.task,
    required this.session,
    required this.offTime,
  });

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;

  int id;

  int type;

  ///0:task,1:session,2:off-time,3:holiday

  CalendarTask task;

  Session session;

  OffTime offTime;
}
