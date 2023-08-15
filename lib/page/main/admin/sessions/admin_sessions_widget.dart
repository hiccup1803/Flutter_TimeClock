import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/bloc/main/sessions/admin/admin_sessions_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/employee_summary.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/sessions_day_summary.dart';
import 'package:staffmonitor/model/sessions_month_summary.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/sessions/employee_sessions_bottom_sheet.dart';
import 'package:staffmonitor/page/main/my_sessions/month_statistics_card.dart';
import 'package:staffmonitor/page/main/my_sessions/selected_month_widget.dart';
import 'package:staffmonitor/page/main/my_sessions/session_day_summary_widget.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import 'admin_sessions_widget.i18n.dart';
import 'user_month_summary_widget.dart';

class AdminSessionsWidget extends StatelessWidget {
  const AdminSessionsWidget(this.profile);

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminSessionsCubit>(
      create: (context) => AdminSessionsCubit(
        injector.sessionsRepository,
        injector.usersRepository,
      )..refresh(),
      child: _AdminSessionBuilderWidget(),
    );
  }
}

class _AdminSessionBuilderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<AdminSessionsCubit, AdminSessionsState>(
        builder: (context, state) {
          if (state is AdminSessionsReady) {
            DateTime selectedDate = state.selectedDate;
            Loadable<SessionsMonthSummary> monthSummary = state.monthSummary;
            Loadable<List<SessionsDaySummary<AdminSession>>> daySummaries =
                state.monthSessionDaySummaries;
            Loadable<List<EmployeeSummary>> userSummaries = state.userSummaries;
            Loadable<List<Profile>?>? users = state.users;
            Profile? userWith(int id) {
              return users.value?.firstWhereOrNull(
                (element) => element.id == id,
              );
            }

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
                          BlocProvider.of<AdminSessionsCubit>(context).changeMonth(date);
                        }
                      }),
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
                if (userSummaries.value?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Employees List'.i18n,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.color3,
                          ),
                        ),
                        Spacer(),
                        Container()
                      ],
                    ),
                  ),
                if (userSummaries.value?.isNotEmpty == true) SizedBox(height: 10),
                if (userSummaries.value?.isNotEmpty == true)
                  ListView.separated(
                    itemCount: userSummaries.value!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => UserMonthSummaryWidget(
                      userSummaries.value![index],
                      userWithId: userWith,
                      onTap: () {
                        List<AdminSession> list = List.from(userSummaries.value![index].sessions);
                        EmployeeSessionsBottomSheet.show(
                          context,
                          list,
                          userWith(userSummaries.value![index].userId)?.name ?? '???',
                          onChanged: ([session]) {
                            BlocProvider.of<AdminSessionsCubit>(context).refresh(force: true);
                          },
                          onDeleted: ([session]) {
                            if (session != null) {
                              BlocProvider.of<AdminSessionsCubit>(context).removeSession(session);
                            } else {
                              BlocProvider.of<AdminSessionsCubit>(context).refresh(force: true);
                            }
                          },
                        );
                      },
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
                if (userSummaries.value?.isNotEmpty == true) SizedBox(height: 20),
                if (daySummaries.value?.isNotEmpty == true)
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
                if (daySummaries.value?.isNotEmpty == true) SizedBox(height: 10),
                if (daySummaries.value?.isNotEmpty == true)
                  ListView.separated(
                    itemCount: daySummaries.value!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => SessionDaySummaryWidget<AdminSession>(
                      daySummaries.value![index],
                      userWithId: userWith,
                      onSessionTap: (session) => Dijkstra.editAdminSession(
                        session,
                        onChanged: ([session]) {
                          BlocProvider.of<AdminSessionsCubit>(context).refresh(force: true);
                        },
                        onDeleted: ([session]) {
                          if (session != null) {
                            BlocProvider.of<AdminSessionsCubit>(context).removeSession(session);
                          } else {
                            BlocProvider.of<AdminSessionsCubit>(context).refresh(force: true);
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
          }
          return Container();
        },
      ),
    );
  }
}
