import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/main/calendars/my_calendars_cubit.dart';
import 'package:staffmonitor/bloc/main/sessions/my_sessions_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/my_calendars/calendar_filter_widget.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:staffmonitor/page/settings/settings.i18n.dart';

part 'my_calendar_list_widget.dart';

class MyCalendarsWidget extends StatelessWidget {
  MyCalendarsWidget(this.preferredProjects, this.allowWageView);

  final List<int>? preferredProjects;
  final bool allowWageView;
  final log = Logger('ProjectsWidget');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<MyCalendarsCubit, MyCalendarsState>(
            builder: (context, state) {
              return Container(
                height: 4,
                child: (state is CalendarsInitial || state is CalendarsLoading)
                    ? LinearProgressIndicator()
                    : null,
              );
            },
          ),
          Expanded(
            child: MyCalendarsListWidget(),
          ),
        ],
      ),
    );
  }
}
