import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:staffmonitor/bloc/main/employees/employees_cubit.dart';
import 'package:staffmonitor/bloc/main/main_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/invitation.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';

import 'employees_widget.i18n.dart';

part 'invitations_widget.dart';

part 'users_widget.dart';

class EmployeesWidget extends StatelessWidget {
  const EmployeesWidget(this.tabController);

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    tabController.addListener(() {
      if (tabController.index == 1) {
        BlocProvider.of<MainCubit>(context).openInvites();
      } else if (tabController.index == 0) {
        BlocProvider.of<MainCubit>(context).openEmployees();
      }
    });

    return SafeArea(
      child: TabBarView(
        controller: tabController,
        children: [
          UsersWidget(),
          InvitationsWidget(),
        ],
      ),
    );
  }
}
