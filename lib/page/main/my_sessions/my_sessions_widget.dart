import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/main/sessions/my_sessions_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/model/sessions_day_summary.dart';
import 'package:staffmonitor/model/sessions_month_summary.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/my_sessions/selected_month_widget.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import 'month_statistics_card.dart';
import 'my_sessions.i18n.dart';
import 'session_day_summary_widget.dart';

class MySessionsWidget extends StatelessWidget {
  MySessionsWidget(this.profile);

  final Profile profile;
  final log = Logger('SessionsWidget');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<MySessionsCubit, MySessionsState>(
        builder: (context, state) {
          DateTime? selectedDate;
          Loadable<SessionsMonthSummary> monthSummary = Loadable.inProgress();
          Loadable<List<SessionsDaySummary>> sessionsList = Loadable.inProgress([]);
          if (state is SessionsReady) {
            selectedDate = state.selectedDate;
            monthSummary = state.monthSummary;
            sessionsList = state.monthSessionDaySummaries;
          }
          final themeData = Theme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Check all your sessions'.i18n,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.color3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SelectedMonthWidget(
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    if (date != null) {
                      BlocProvider.of<MySessionsCubit>(context).changeMonth(date);
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MonthStatisticsCard(
                  loading: monthSummary.inProgress,
                  monthSummary: monthSummary.value,
                ),
              ),
              SizedBox(height: 20),
              if (sessionsList.inProgress && sessionsList.value?.isEmpty == true)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: SpinKitCircle(
                    color: themeData.primaryColor,
                    size: 40,
                  ),
                ),
              if (sessionsList.value?.isEmpty == true && sessionsList.inProgress != true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 200, width: 1),
                    Icon(
                      Icons.info_outline,
                      size: 24,
                      color: AppColors.color2,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No sessions this month'.i18n,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.color2,
                      ),
                    ),
                  ],
                ),
              if (sessionsList.value?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Sessions List'.i18n,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.color3,
                    ),
                  ),
                ),
              if (sessionsList.value?.isNotEmpty == true) SizedBox(height: 10),
              if (sessionsList.value?.isNotEmpty == true)
                ListView.separated(
                  itemCount: sessionsList.value!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => SessionDaySummaryWidget<Session>(
                    sessionsList.value![index],
                    onSessionTap: (session) => Dijkstra.editSession(
                      session,
                      onChanged: ([session]) {
                        if (session != null) {
                          BlocProvider.of<MySessionsCubit>(context).sessionChanged(session);
                        }
                      },
                      onDeleted: ([session]) {
                        if (session != null) {
                          BlocProvider.of<MySessionsCubit>(context).sessionDeleted(session);
                        }
                      },
                    ),
                  ),
                  separatorBuilder: (context, index) {
                    return Divider(
                      thickness: 1.5,
                      height: 1.5,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.color4,
                    );
                  },
                ),
              SizedBox(height: kToolbarHeight),
            ],
          );
        },
      ),
    );
  }
}
