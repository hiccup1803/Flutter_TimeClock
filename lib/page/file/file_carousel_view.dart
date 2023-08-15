import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/files/admin_files_cubit.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/model/admin_task_file.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/file/file_detail_view.dart';

class FileCarouselView extends StatefulWidget {
  const FileCarouselView({
    Key? key,
    this.initialIndex = 0,
    this.sessionFileList,
    this.taskFileList,
  })  : assert(taskFileList != null || sessionFileList != null),
        super(key: key);

  final int initialIndex;
  final List<AdminSessionFile>? sessionFileList;
  final List<AdminTaskFile>? taskFileList;

  @override
  State<FileCarouselView> createState() => _FileCarouselViewState();
}

class _FileCarouselViewState extends State<FileCarouselView> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sessionFileList != null) {
      return PageView(
        onPageChanged: (page) {
          if (page > widget.sessionFileList!.length - 2) {
            BlocProvider.of<AdminFilesCubit>(context).loadMoreFiles();
          }
          _controller.animateToPage(page,
              duration: const Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
        },
        controller: _controller,
        children: widget.sessionFileList!
            .map((value) => FileDetailView(adminSessionFile: value))
            .toList(),
      );
    }

    return PageView(
      onPageChanged: (page) {
        if (page > widget.taskFileList!.length - 2) {
          BlocProvider.of<AdminFilesCubit>(context).loadMoreFiles();
        }
        _controller.animateToPage(page,
            duration: const Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
      },
      controller: _controller,
      children: widget.taskFileList!.map((value) => FileDetailView(adminTaskFile: value)).toList(),
    );
  }
}
