import 'package:flutter/material.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import 'dialogs.i18n.dart';

class ConfirmDialog extends AlertDialog {
  ConfirmDialog({
    required BuildContext context,
    Widget? title,
    Widget? content,
    Widget? confirmAction,
    String? confirmLabel,
    ButtonStyle? confirmActionStyle,
    String? cancelLabel,
    ButtonStyle? cancelActionStyle,
  }) : super(
          title: title,
          content: content,
          actions: [
            TextButton(
              style: cancelActionStyle,
              onPressed: () => Navigator.pop(context),
              child: Text(cancelLabel ?? 'No'.i18n),
            ),
            confirmAction ??
                TextButton(
                  style: confirmActionStyle,
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmLabel ?? 'Yes'.i18n),
                ),
          ],
        );

  static Future<bool> show({
    required BuildContext context,
    Widget? title,
    Widget? content,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        context: context,
        title: title,
        content: SizedBox(width: MediaQuery.of(context).size.width, child: content),
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    ).then((value) => value == true);
  }

  static Future<bool> showDanger({
    required BuildContext context,
    Widget? title,
    Widget? content,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        context: context,
        title: title,
        content: SizedBox(width: MediaQuery.of(context).size.width, child: content),
        confirmAction: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: AppColors.danger),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? 'Yes'.i18n),
        ),
        cancelLabel: cancelLabel,
      ),
    ).then((value) => value == true);
  }
}
