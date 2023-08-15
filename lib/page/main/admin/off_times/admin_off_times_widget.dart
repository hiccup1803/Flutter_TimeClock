import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/main/off_time/admin/admin_off_times_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/admin_off_time.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';

import 'admin_off_times_widget.i18n.dart';

part 'admin_off_time_bottom_sheet.dart';
part 'admin_off_time_row_widget.dart';
part 'admin_off_times_summary.dart';

class AdminOffTimesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: BlocProvider<AdminOffTimesCubit>(
          create: (context) =>
              AdminOffTimesCubit(injector.offTimesRepository, injector.usersRepository)..refresh(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Manage Employees Vacations'.i18n,
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
                    _AdminOffTimesSummary(
                      filter: (List<AdminOffTime> offTimes) => offTimes
                          .where((element) => element.isVacation && element.isWaiting)
                          .toList(),
                    ),
                    _AdminOffTimesSummary(
                      filter: (List<AdminOffTime> offTimes) => offTimes
                          .where((element) => element.isVacation && element.isApproved)
                          .toList(),
                    ),
                    _AdminOffTimesSummary(
                      filter: (List<AdminOffTime> offTimes) => offTimes
                          .where((element) => element.isVacation && element.isDenied)
                          .toList(),
                    ),
                    _AdminOffTimesSummary(
                      filter: (List<AdminOffTime> offTimes) =>
                          offTimes.where((element) => element.isShort).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YearSelectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOffTimesCubit, AdminOffTimesState>(
      builder: (context, state) {
        bool inProgress = true;
        if (state is AdminOffTimesReady) {
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
                              BlocProvider.of<AdminOffTimesCubit>(context).changeYear(value);
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
