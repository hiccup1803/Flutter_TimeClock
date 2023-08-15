import 'package:flutter/material.dart';

import '../../dijkstra.dart';
import 'dialogs.i18n.dart';

class LoginErrorDialog extends AlertDialog {
  LoginErrorDialog({Widget? content})
      : super(
          title: Text('Error'.i18n),
          content: content == null ? Text('Wrong login or password'.i18n) : content,
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
      builder: (context) => LoginErrorDialog(
        content: content,
      ),
    );
  }
}