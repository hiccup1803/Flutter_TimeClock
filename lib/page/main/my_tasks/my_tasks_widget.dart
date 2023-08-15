import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/bloc/main/tasks/admin/admin_tasks_cubit.dart';
import 'package:staffmonitor/bloc/main/tasks/my_tasks_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/taks/admin_task_list_widget.dart';
import 'package:staffmonitor/page/main/my_sessions/selected_month_widget.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'my_tasks_widget.i18n.dart';

class MyTasksWidget extends StatelessWidget {
  const MyTasksWidget(this.profile);

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyTasksCubit>(
      create: (context) => MyTasksCubit(injector.projectsRepository, DateTime.now()),
      child: _AdminTaskBuilderWidget(),
    );
  }
}

class _AdminTaskBuilderWidget extends StatelessWidget {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    void onEditTaskChange([Session? session]) {
      BlocProvider.of<MyTasksCubit>(context).init(selectedDate);
    }

    void onEditTaskDeleted([Session? session]) {
      BlocProvider.of<MyTasksCubit>(context).init(selectedDate);
    }

    return SingleChildScrollView(
      child: BlocBuilder<MyTasksCubit, MyTasksState>(
        builder: (context, state) {
          if (state is MyTasksInitial) {
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
                      isTask: false,
                      onDateSelected: (date) {
                        if (date != null) {
                          BlocProvider.of<MyTasksCubit>(context).changeMonth(date);
                        }
                      }),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(),
              ],
            );
          }

          if (state is MyTasksReady) {
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
                      isTask: false,
                      onDateSelected: (date) {
                        if (date != null) {
                          BlocProvider.of<MyTasksCubit>(context).changeMonth(date);
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
                        Dijkstra.editTask(tasks[index], null,
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
