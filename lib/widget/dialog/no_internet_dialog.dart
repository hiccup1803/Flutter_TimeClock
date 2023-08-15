import 'package:flutter/material.dart';

import '../../dijkstra.dart';
import 'dialogs.i18n.dart';

class NoInternetDialog extends AlertDialog {
  NoInternetDialog({Widget? content})
      : super(
          title: Text('Oops!'.i18n),
          content: Text('No internet connection'.i18n),
          actions: [
            TextButton(
              onPressed: () => Dijkstra.goBack(),
              child: Text('Ok'.i18n),
            )
          ],
        );

  static Future show({required BuildContext context, Widget? content}) {
    return showDialog(
      context: context,
      builder: (context) => NoInternetDialog(
        content: content,
      ),
    );
  }
}