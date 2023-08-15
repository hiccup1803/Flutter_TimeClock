import 'package:flutter/material.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';

import '../../dijkstra.dart';
import 'dialogs.i18n.dart';

class FileDetailsDialog extends AlertDialog {
  static const int FILE_DELETED = 99;

  FileDetailsDialog(BuildContext context, AppFile file, Color error, Color primary,
      {bool isTask = false})
      : super(
          title: Text(file.name!),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: %s'.i18n.fill([file.type ?? ''])),
              Text('Size: %s B'.i18n.fill([file.size ?? ''])),
              Text('Uploaded: %s'.i18n.fill([file.createdAt?.format('MM.dd.yyyy'.i18n) ?? ''])),
              Text('Edited: %s'.i18n.fill([file.updatedAt?.format('MM.dd.yyyy'.i18n) ?? ''])),
              Container(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete_forever),
                      style: ElevatedButton.styleFrom(primary: error),
                      onPressed: () {
                        ConfirmDialog.show(
                          context: context,
                          title: Text('Confirm deleting'.i18n),
                          content: Text(
                              'This action cannot be undone. Are you sure you want to delete this file?'
                                  .i18n),
                        ).then(
                          (value) {
                            if (value == true && file.id != null) {
                              Future future;
                              if (isTask) {
                                future = injector.filesRepository.deleteTaskFile(file.id!);
                              } else {
                                future = injector.filesRepository.deleteSessionFile(file.id!);
                              }
                              future.then(
                                (value) {
                                  if (value == true) Dijkstra.goBack(FILE_DELETED);
                                },
                                onError: (e, stack) {
                                  if (e is AppError)
                                    FailureDialog.show(
                                        context: context,
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: e.messages.map((e) => Text(e!)).toList(),
                                        ));
                                },
                              );
                            }
                          },
                        );
                      },
                      label: Text('Delete'.i18n),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: primary),
                      onPressed: () {
                        injector.filesRepository.downloadAdminSessionFile(file).then((value) {
                          if (value?.isNotEmpty == true)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Downloading: %s'.i18n.fill([value ?? '']))));
                          Dijkstra.goBack();
                        });
                      },
                      child: Text('Download'.i18n),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Dijkstra.goBack(),
              child: Text('Close'.i18n),
            ),
          ],
        );

  static Future<dynamic> show({
    required BuildContext context,
    required AppFile file,
    bool isTask = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: _Wrapper(file, isTask: isTask),
      ),
    );
  }
}

class _Wrapper extends StatelessWidget {
  _Wrapper(this.file, {this.isTask = false});

  final AppFile file;
  final bool isTask;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return FileDetailsDialog(
        context, file, themeData.colorScheme.error, themeData.colorScheme.primary,
        isTask: isTask);
  }
}
