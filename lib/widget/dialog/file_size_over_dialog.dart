import 'package:flutter/material.dart';

import 'dialogs.i18n.dart';

class FileSizeOverDialog extends AlertDialog {
  FileSizeOverDialog(BuildContext context, List<String> nameLst)
      : super(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("File to large, file size limit is 10 MB".i18n),
              SizedBox(height: 8),
              Container(
                height: 90,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...nameLst
                          .asMap()
                          .map((key, value) =>
                              MapEntry(key, Text("${key + 1}:  " + " ${nameLst[key]}")))
                          .values
                          .toList(),
                    ],
                  ),
                ),
              ),
              Container(
                height: 8,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'.i18n),
            ),
          ],
        );

  static Future<dynamic> show({required BuildContext context, required List<String> nameList}) =>
      showDialog(
        context: context,
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: FileSizeOverDialog(context, nameList),
        ),
      );
}
