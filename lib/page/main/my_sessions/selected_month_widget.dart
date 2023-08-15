import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:staffmonitor/bloc/main/tasks/admin/admin_tasks_cubit.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/taks/admin_task_filter_widget.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

class SelectedMonthWidget extends StatelessWidget {
  const SelectedMonthWidget({this.selectedDate, required this.onDateSelected, this.isTask = false});

  final DateTime? selectedDate;
  final bool isTask;
  final Function(DateTime? date) onDateSelected;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Row(
      children: [
        Text(
          selectedDate?.format('MMM yyyy') ?? '--',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.color1,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            showMonthPicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
            ).then(onDateSelected);
          },
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
        if (isTask == true)
          Container(
            height: 36,
            width: 36,
            margin: EdgeInsets.fromLTRB(12, 9, 10, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: themeData.primaryColor.withOpacity(0.1),
            ),
            child: InkWell(
              onTap: () {
                AdminTasksCubit myBloc = BlocProvider.of<AdminTasksCubit>(context);

                int profileId = myBloc.assignee;

                showModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                  builder: (context) {
                    return BlocProvider<AdminTasksCubit>.value(
                      value: myBloc,
                      child: AdminTaskFilterWidget(profileId),
                    );
                  },
                );
              },
              child: Icon(
                Icons.filter_list_sharp,
                size: 24,
                color: themeData.primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
