import 'dart:io';

import 'package:flutter/material.dart';

import 'dialogs.i18n.dart';

class LocationPermissionReasonDialog extends AlertDialog {
  LocationPermissionReasonDialog({
    required BuildContext context,
  }) : super(
          title: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Theme.of(context).primaryColor,
              ),
              Text('Location Permission'.i18n),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'StaffMonitor collects your location data during active sessions even when the app is closed or not in use. In order to track your activity efficiently please grand location and physical activity permissions.'
                      .i18n),
            ],
          ),
          actions: [
            if (Platform.isAndroid)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No, thanks'.i18n),
              ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Ok, I understand'.i18n),
            ),
          ],
        );

  static show({required BuildContext context, required Function() onApprove}) {
    showDialog<bool>(
      context: context,
      builder: (context) => LocationPermissionReasonDialog(
        context: context,
      ),
    ).then((value) {
      if (value == true) {
        onApprove.call();
      }
    });
  }
}
