import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/files/edit/edit_admin_file_cubit.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/model/admin_task_file.dart';

import 'detail_file_carousel_page_modal.dart' as sessionFile;
import 'detail_task_carousel_page_modal.dart' as taskFile;

class FileDetailView extends StatefulWidget {
  const FileDetailView({Key? key, this.adminSessionFile, this.adminTaskFile})
      : assert(adminTaskFile != null || adminSessionFile != null),
        super(key: key);
  final AdminSessionFile? adminSessionFile;
  final AdminTaskFile? adminTaskFile;

  @override
  _FileDetailViewState createState() => _FileDetailViewState();
}

class _FileDetailViewState extends State<FileDetailView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditAdminFileCubit>(
      create: (context) => EditAdminFileCubit(injector.filesRepository)
        ..init(sessionFile: widget.adminSessionFile, taskFile: widget.adminTaskFile),
      child: widget.adminSessionFile != null
          ? sessionFile.OffTimeForm(widget.adminSessionFile!.note)
          : taskFile.OffTimeForm(widget.adminTaskFile!.note),
    );
  }
}
