import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/main/projects/my_projects_cubit.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/sessions_summary.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/decorated_value_widget.dart';

import 'my_projects.i18n.dart';

part 'my_projects_list_widget.dart';

class MyProjectsWidget extends StatelessWidget {
  MyProjectsWidget(this.preferredProjects, this.allowWageView);

  final List<int>? preferredProjects;
  final bool allowWageView;
  final log = Logger('ProjectsWidget');

  @override
  Widget build(BuildContext context) {
    // ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<MyProjectsCubit, MyProjectsState>(
            builder: (context, state) {
              return Container(
                height: 4,
                child: (state is ProjectsInitial || state is ProjectsLoading)
                    ? LinearProgressIndicator()
                    : null,
              );
            },
          ),
          Expanded(
            child: MyProjectsListWidget(preferredProjects ?? [], allowWageView == true),
          ),
        ],
      ),
    );
  }

// void _changeDate(BuildContext context, DateTime dateTime) {
//   showMonthPicker(
//     context: context,
//     firstDate: DateTime(1999),
//     lastDate: DateTime(3000),
//     initialDate: dateTime,
//   ).then((date) {
//     BlocProvider.of<ProjectsCubit>(context).changeMonth(date);
//   }, onError: (e, stack) {
//     log.shout('_changeDate', e, stack);
//   });
// }
}
