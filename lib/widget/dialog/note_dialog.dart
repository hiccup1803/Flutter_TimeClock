import 'package:flutter/material.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/session.dart';

import 'dialogs.i18n.dart';

class NoteDialog extends AlertDialog {
  NoteDialog({
    required BuildContext context,
    Widget? title,
    Widget? content,
    Function()? close,
    Function()? save,
  }) : super(
          title: title,
          content: content,
          actions: [
            TextButton(
              onPressed: close,
              child: Text('Close'.i18n),
            ),
            TextButton(
              onPressed: save,
              child: Text(save == null ? 'Saved'.i18n : 'Save'.i18n),
            ),
          ],
        );

  static Future<Session?> show({required BuildContext context, required Session session}) {
    return showDialog<Session>(
      context: context,
      builder: (context) {
        bool saved = true;
        bool processing = false;
        Session? sessionSaved = session;
        Session? editedSession = session.copyWith();

        return WillPopScope(
          onWillPop: () async {
            if (!processing) Navigator.pop(context, sessionSaved);
            return false;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return NoteDialog(
                context: context,
                close: processing
                    ? null
                    : () {
                        Navigator.pop(context, sessionSaved);
                      },
                save: (saved || processing)
                    ? null
                    : () {
                        setState(() {
                          processing = true;
                        });
                        injector.sessionsRepository.updateSession(editedSession!).then(
                          (value) {
                            setState(() {
                              sessionSaved = value;
                              editedSession = value;
                              saved = sessionSaved == editedSession;
                              processing = false;
                            });
                          },
                          onError: (e, stack) {
                            setState(() {
                              processing = false;
                            });
                          },
                        );
                      },
                title: Text('Notatka'.i18n),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      minLines: 2,
                      maxLines: 10,
                      initialValue: session.note,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          editedSession = editedSession!.copyWith(note: value);
                          saved = sessionSaved == editedSession;
                        });
                      },
                      enabled: !processing,
                    ),
                    Container(
                      height: 10,
                      child: processing == false
                          ? null
                          : Center(
                              child: LinearProgressIndicator(),
                            ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
