import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/bloc/main/tasks/admin/admin_tasks_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/taks/admin_task_list_widget.dart';
import 'package:staffmonitor/page/main/my_sessions/selected_month_widget.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'admin_tasks_widget.i18n.dart';

class AdminTasksWidget extends StatelessWidget {
  const AdminTasksWidget(this.profile);

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _AdminTaskBuilderWidget(),
    );
  }
}

class _AdminTaskBuilderWidget extends StatefulWidget {
  @override
  State<_AdminTaskBuilderWidget> createState() => _AdminTaskBuilderWidgetState();
}

class _AdminTaskBuilderWidgetState extends State<_AdminTaskBuilderWidget> {
  DateTime selectedDate = DateTime.now();

  void onEditTaskChange() {
    BlocProvider.of<AdminTasksCubit>(context).init(selectedDate);
  }

  void onEditTaskDeleted([CalendarTask? task]) {
    BlocProvider.of<AdminTasksCubit>(context).taskDeleted(task);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<AdminTasksCubit, AdminTasksState>(
        builder: (context, state) {
          if (state is AdminTasksInitial) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Tasks List'.i18n,
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
                      isTask: true,
                      onDateSelected: (date) {
                        if (date != null) {
                          BlocProvider.of<AdminTasksCubit>(context).changeMonth(date);
                        }
                      }),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(),
              ],
            );
          }

          if (state is AdminTasksReady) {
            selectedDate = state.selectedDate;
            List<CalendarTask> tasks = state.tasks ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Tasks List'.i18n,
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
                      isTask: true,
                      onDateSelected: (date) {
                        if (date != null) {
                          BlocProvider.of<AdminTasksCubit>(context).changeMonth(date);
                        }
                      }),
                ),
                if (tasks.isNotEmpty == true) SizedBox(height: 20),
                if (tasks.isNotEmpty == true)
                  ListView.separated(
                    itemCount: tasks.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => AdminTaskListWidget(
                      tasks[index],
                      onTap: () {
                        Dijkstra.editAdminTask(tasks[index],
                            onChanged: onEditTaskChange, onDeleted: onEditTaskDeleted);
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
