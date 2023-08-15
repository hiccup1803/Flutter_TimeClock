import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/main/off_time/my_off_times_cubit.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import '../../off_time/off_time.i18n.dart';

part 'my_off_time_bottom_sheet.dart';
part 'my_off_time_row_widget.dart';
part 'my_off_times_summary.dart';

class MyOffTimesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: BlocBuilder<MyOffTimesCubit, MyOffTimesState>(
        builder: (context, state) {
          if (state is MyOffTimesReady) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Manage Vacations'.i18n,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.color3,
                      ),
                    ),
                  ),
                  _YearSelectorWidget(),
                  TabBar(
                    indicatorColor: theme.primaryColor,
                    labelColor: theme.primaryColor,
                    isScrollable: true,
                    unselectedLabelColor: AppColors.color3,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(text: 'Pending'.i18n),
                      Tab(text: 'Accepted'.i18n),
                      Tab(text: 'Denied'.i18n),
                      Tab(text: 'Non Vacation'.i18n),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _MyOffTimesSummary(
                          filter: (List<OffTime> offTimes) => offTimes
                              .where((element) => element.isVacation && element.isWaiting)
                              .toList(),
                        ),
                        _MyOffTimesSummary(
                          filter: (List<OffTime> offTimes) => offTimes
                              .where((element) => element.isVacation && element.isApproved)
                              .toList(),
                        ),
                        _MyOffTimesSummary(
                          filter: (List<OffTime> offTimes) => offTimes
                              .where((element) => element.isVacation && element.isDenied)
                              .toList(),
                        ),
                        _MyOffTimesSummary(
                          filter: (List<OffTime> offTimes) =>
                              offTimes.where((element) => element.isShort).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  static Map<DateTime, List> mapListToDates(Paginated? paginated) {
    final log = Logger('mapListToDates(OffTimes)');
    if (paginated == null || paginated.totalCount == 0) return Map();
    final Map<DateTime, List<OffTime>> result = Map();
    paginated.list!.forEach((element) {
      OffTime offTime = element as OffTime;
      DateTime? day; // = offTime.startDate.noon;
      int count = offTime.days;
      while (count > 0) {
        if (day == null) {
          day = offTime.startDate!.noon;
        } else
          day = day.add(Duration(days: 1));
        final List<OffTime> list = List.from(result[day] ?? List.empty());
        list.add(offTime);
        result[day] = list;
        count--;
      }
    });
    log.finest('map => result $result');
    return result;
  }
}

class _YearSelectorWidget extends StatelessWidget {
  final DateTime _dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyOffTimesCubit, MyOffTimesState>(
      builder: (context, state) {
        bool inProgress = true;
        if (state is MyOffTimesReady) {
          inProgress = state.offTimes.inProgress;
        }
        final themeData = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  state.selectedDate.format('yyyy'),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeData.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: inProgress != true
                    ? () => Future.delayed(
                          Duration(milliseconds: 300),
                          () => _showYearDialog(context: context, selectedDate: state.selectedDate)
                              .then((value) {
                            if (value != null)
                              BlocProvider.of<MyOffTimesCubit>(context).changeYear(value);
                          }),
                        )
                    : null,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: themeData.primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 24,
                    color: themeData.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int?> _showYearDialog({required BuildContext context, required DateTime selectedDate}) {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context1) {
        return AlertDialog(
          title: Text('Select Year'.i18n),
          content: Container(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 100, 1),
              lastDate: DateTime(DateTime.now().year + 100, 1),
              initialDate: selectedDate,
              selectedDate: selectedDate,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context1, dateTime.year);
              },
            ),
          ),
        );
      },
    ).then((value) => value);
  }
}
