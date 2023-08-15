import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/files/edit/edit_admin_file_cubit.dart';
import 'package:staffmonitor/bloc/main/files/admin_files_cubit.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/file/file_carousel_view.dart';
import 'package:staffmonitor/utils/file_size_utils.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';

import 'file.i18n.dart';

part 'detail_file_form.dart';

class DetailFileCarouselPage extends StatelessWidget {
  final DateTime keyDate;
  final int initialIndex;

  DetailFileCarouselPage({
    required this.keyDate,
    this.initialIndex = 0,
  });

  static const int ADMIN_FILE_DELETED = 110;
  static const int NOTE_CHANGED = 111;

  static const String ADMIN_FILE_KEY = 'admin_file';
  static const String ADMIN_FILE_INDEX = 'admin_file_index';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminFilesCubit, AdminFilesState>(
      builder: (context, state) {
        if (state is AdminFilesReady) {
          Loadable<Map<DateTime, List<AdminSessionFile>>> adminFiles = state.files;

          if (adminFiles.inProgress) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (adminFiles.error != null) {
            return Center(
              child: Text(
                adminFiles.error!.formatted()!,
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (adminFiles.value?.isNotEmpty != true) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('No files found'.i18n),
              ),
            );
          }
          List<AdminSessionFile> fileList = [];
          bool setIndex = false;
          int realIndex = 0;
          bool incIndex = false;
          adminFiles.value?.entries.forEach((element) {
            incIndex = false;
            if (element.key != keyDate && !setIndex) {
              incIndex = true;
            } else if (element.key == keyDate && !setIndex) {
              realIndex += initialIndex;
              setIndex = true;
            }
            element.value.forEach((element) {
              if (incIndex) realIndex++;
              fileList.add(element);
            });
          });

          return Scaffold(
            body: FileCarouselView(
              sessionFileList: fileList,
              initialIndex: realIndex,
            ),
          );
        }
        return Container();
      },
    );
  }
}
