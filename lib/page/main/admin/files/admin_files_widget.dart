import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/main/files/admin_files_cubit.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/model/admin_task_file.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/files/admin_files_filter_widget.dart';
import 'package:staffmonitor/utils/file_size_utils.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/authorized_image_widget.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../file/detail_file_carousel_page_modal.dart';
import '../../../file/detail_task_carousel_page_modal.dart';
import 'admin_files_widget.i18n.dart';

part 'session_file_list.dart';

part 'task_file_list.dart';

class AdminFilesWidget extends StatefulWidget {
  const AdminFilesWidget(this.tabController);

  final TabController tabController;

  @override
  _AdminFilesWidgetState createState() => _AdminFilesWidgetState();
}

class _AdminFilesWidgetState extends State<AdminFilesWidget> {
  late ScrollController _controller;

  TabController get _tabController => widget.tabController;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  _handleTabSelection() {
    BlocProvider.of<AdminFilesCubit>(context).tabChange(_tabController.index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (widget.tabController.index == 0) {
        BlocProvider.of<AdminFilesCubit>(context).loadMoreFiles();
      } else if (widget.tabController.index == 1) {
        BlocProvider.of<AdminFilesCubit>(context).loadMoreTaskFiles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TabBarView(
        controller: widget.tabController,
        children: [
          SessionFilesList(
            readFiles: (state) => state.files,
            controller: _controller,
          ),
          TaskFilesList(
            readFiles: (state) => state.taskFiles,
            controller: _controller,
          ),
        ],
      ),
    );
  }
}

class FilterFileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AdminFilesCubit adminFilesBloc = BlocProvider.of<AdminFilesCubit>(context);
        List<dynamic> filterList = adminFilesBloc.currentFilter();

        showModalBottomSheet(
          context: context,
          enableDrag: true,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          builder: (context) {
            return BlocProvider<AdminFilesCubit>.value(
              value: adminFilesBloc,
              child: AdminFilesFilterWidget(filterValue: filterList),
            );
          },
        );
      },
      child: Icon(
        Icons.filter_list_outlined,
        size: 28,
        color: const Color(0xFF001F7E),
      ),
    );
  }
}
