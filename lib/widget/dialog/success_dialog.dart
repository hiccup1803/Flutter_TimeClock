import 'dart:async';

import 'package:flutter/material.dart';

import 'dialogs.i18n.dart';

class SuccessDialog extends AlertDialog {
  SuccessDialog(BuildContext context, {Widget? content})
      : super(
          title: Text('Success'.i18n),
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'.i18n),
            )
          ],
        );

  static Future show({required BuildContext context, Widget? content, Duration? autoHideDuration}) {
    bool closed = false;
    Future? hideFuture;
    return showDialog(
      context: context,
      builder: (context) {
        if (autoHideDuration != null) {
          hideFuture?.ignore();
          hideFuture = Future.delayed(autoHideDuration, () {
            if (closed == false) {
              Navigator.pop(context);
            }
          });
        }
        return SuccessDialog(
          context,
          content: content,
        );
      },
    ).then((value) {
      closed = true;
      hideFuture?.ignore();
    });
  }
}
