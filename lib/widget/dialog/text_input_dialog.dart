import 'package:flutter/material.dart';
import 'package:staffmonitor/page/base_page.dart';

import 'dialogs.i18n.dart';

class TextInputDialog extends AlertDialog {
  TextInputDialog({
    required BuildContext context,
    Widget? title,
    Widget? content,
    Function()? close,
    Function()? save,
    String? saveText,
  }) : super(
          title: title,
          content: content,
          // titlePadding: EdgeInsets.all(8),
          // contentPadding: EdgeInsets.all(8),
          actions: [
            TextButton(
              onPressed: close,
              child: Text('Close'.i18n),
            ),
            TextButton(
              onPressed: save,
              child: Text(saveText ?? 'Save'.i18n),
            ),
          ],
        );

  static Future<String?> show({
    required BuildContext context,
    String text = '',
    Widget? title,
    String? hint,
    String? submitText,
    TextInputType? inputType,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String currentValue = text;
        bool canSave = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return TextInputDialog(
              context: context,
              close: () => Navigator.pop(context),
              saveText: submitText,
              save: canSave
                  ? () {
                      Navigator.pop(context, currentValue);
                    }
                  : null,
              title: title,
              content: TextFormField(
                minLines: 1,
                maxLines: 10,
                initialValue: currentValue,
                keyboardType: inputType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  hintText: hint ?? '',
                  border: OutlineInputBorder(),
                ),
                textAlignVertical: TextAlignVertical.top,
                onChanged: (value) {
                  setState(() {
                    currentValue = value;
                    canSave = text != value;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
