import 'package:flutter/material.dart';

import '../../dijkstra.dart';
import 'dialogs.i18n.dart';

class FailureDialog extends AlertDialog {
  FailureDialog({Widget? content})
      : super(
          title: Text('Failure'.i18n),
          content: content,
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
      builder: (context) => FailureDialog(
        content: content,
      ),
    );
  }
}
