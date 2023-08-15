import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/history/history_cubit.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/color_utils.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:table_calendar/table_calendar.dart';

import 'history_widget.i18n.dart';

class HistoryWidget extends StatefulWidget {
  HistoryWidget({
    required this.buildItemRow,
    required this.buildEmpty,
    required this.locale,
    this.eventsToString,
    this.style,
  });

  final Widget Function(BuildContext context, dynamic item) buildItemRow;
  final Widget Function(BuildContext context, DateTime day) buildEmpty;
  final String Function(List events)? eventsToString;
  final Locale? locale;
  final HistoryCalendarStyle? style;

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> with TickerProviderStateMixin {
  final log = Logger('HistoryWidget');

  late AnimationController _animationController;

  bool loading = false;
  AppError? error;
  Map<DateTime, List> _events = Map<DateTime, List>();
  List _selectedEvents = List.empty();
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
    loading = true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    log.fine('_onDaySelected $selectedDay');
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _events[_selectedDay.noon] ?? [];
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    BlocProvider.of<HistoryCubit>(context).changeMonth(focusedDay);
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    final Color color = isSameDay(_selectedDay, date)
        ? (widget.style?.eventsToColor?.call(events, true) ??
            widget.style?.selectedEvents ??
            Colors.brown.shade500)
        : (widget.style?.eventsToColor?.call(events, false) ??
            widget.style?.events ??
            Colors.blue.shade400);
    final contrast = color.contrastColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: color,
      ),
      width: (widget.style?.square == true) ? 20.0 : 50.0,
      height: 20.0,
      child: Center(
        child: Text(
          widget.eventsToString?.call(events) ?? '${events.length}',
          style: TextStyle().copyWith(
            color: contrast,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day.noon] ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistoryCubit, HistoryState>(
      listener: (context, state) {
        if (state is HistoryReady) {
          setState(() {
            _events = state.list.value ?? const {};
            loading = state.list.inProgress == true;
            error = state.list.error;
            print('loading = $loading');
          });
        }
      },
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TableCalendar<dynamic>(
              key: ValueKey('calendars'),
              locale: widget.locale?.toString() ?? 'en_US',
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2099, 12, 31),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged,
              availableCalendarFormats: {
                CalendarFormat.month: 'Month'.i18n.toLowerCase(),
                // CalendarFormat.week: 'Week'.i18n.toLowerCase(),
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableGestures: AvailableGestures.horizontalSwipe,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                // contentPadding: const EdgeInsets.all(4.0),
              ),
              headerStyle: HeaderStyle(
                headerPadding: const EdgeInsets.all(0.0),
              ),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                todayBuilder: (context, date, focusedDay) {
                  bool hasSelectedEvent = date == _selectedDay && _selectedEvents.isNotEmpty;
                  Color? bgColor = (date == _selectedDay && _selectedEvents.isNotEmpty == true)
                      ? (widget.style?.hasEvents ?? Colors.blueGrey.shade200)
                      : null;
                  if (hasSelectedEvent) {
                    bgColor = widget.style?.selected ?? Colors.blue.shade400;
                    bgColor = bgColor.withAlpha(140);
                  }

                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(top: 1.0, left: 4.0),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: Colors.red, width: 4),
                    ),
                    width: 100,
                    height: 100,
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 16.0),
                    ),
                  );
                },
                selectedBuilder: (context, date, focusedDay) {
                  Color color2 = widget.style?.selected ?? Colors.blue.shade400;
                  Color contrast = color2.contrastColor();
                  return FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                    child: Container(
                      margin:
                          widget.style?.borderSelection == true ? null : const EdgeInsets.all(4.0),
                      padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                      color: widget.style?.borderSelection == true ? null : color2,
                      decoration: widget.style?.borderSelection == true
                          ? BoxDecoration(
                              border: Border.all(color: color2, width: 4),
                            )
                          : null,
                      width: 100,
                      height: 100,
                      // alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle().copyWith(fontSize: 16.0, color: contrast),
                      ),
                    ),
                  );
                },
                defaultBuilder: (context, date, focusedDay) {
                  bool weekend =
                      date.weekday == DateTime.sunday || date.weekday == DateTime.saturday;
                  bool hasSelectedEvent = isSameDay(_selectedDay, date);

                  Color? bgColor;
                  if (date.isBeforeToday) {
                    bgColor = widget.style?.pastDay;
                  }

                  bgColor = _events[date.noon]?.isNotEmpty == true
                      ? (widget.style?.hasEvents ?? Colors.blueGrey.shade200)
                      : bgColor;
                  if (hasSelectedEvent) {
                    bgColor = widget.style?.selected ?? Colors.blue.shade400;
                    bgColor = bgColor.withAlpha(140);
                  }
                  Color textColor = weekend
                      ? (widget.style?.weekend ?? Colors.red)
                      : bgColor?.contrastColor() ?? Colors.black;
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                    color: bgColor,
                    width: 100,
                    height: 100,
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 16.0, color: textColor),
                    ),
                  );
                },
                outsideBuilder: (context, date, focusedDay) {
                  Color textColor = Colors.black.withAlpha(70);
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                    width: 100,
                    height: 100,
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 16.0, color: textColor),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 2,
                      left: widget.style?.square == true ? null : 6,
                      bottom: 2,
                      child: _buildEventsMarker(date, events),
                    );
                  }
                  return null;
                },
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      Divider(),
                      if (loading) LinearProgressIndicator(),
                    ],
                  ),
                  Center(
                    child: Text(
                      _selectedDay.format('EEEE\ndd MMMM'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: _selectedEvents.isNotEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _selectedEvents
                                  .map((e) => widget.buildItemRow.call(context, e))
                                  .toList(),
                            ),
                          )
                        : widget.buildEmpty.call(context, _focusedDay),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryCalendarStyle {
  HistoryCalendarStyle({
    this.today,
    this.selected,
    this.events,
    this.selectedEvents,
    this.hasEvents,
    this.weekend,
    this.pastDay,
    this.square = false,
    this.borderSelection = false,
    this.eventsToColor,
  });

  final Color? today, selected, events, selectedEvents, hasEvents, weekend, pastDay;
  final bool square, borderSelection;
  final Color? Function(List events, [bool? selected])? eventsToColor;
}
