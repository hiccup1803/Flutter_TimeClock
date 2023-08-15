import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

void setupUploaderBackground() {
  FlutterUploader().setBackgroundHandler(uploadBackgroundHandler);
}

void clearUploaderBackground() {
  FlutterUploader().setBackgroundHandler(inactiveBackgroundHandler);
}

void inactiveBackgroundHandler() {
  //do nothing
}

const String _UPLOADS_KEY = 'uploads_key';

const String ACTIVE_UPLOADS_KEY = 'active_uploads_key_40';
const String PROCESSED_UPLOADS_KEY = 'processed_key_40';

var uploadNotificationLock = Lock();

void uploadBackgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();

  // Notice these instances belong to a forked isolate.
  final uploader = FlutterUploader();

  // Only show notifications for unprocessed uploads.
  SharedPreferences.getInstance().then(
    (preferences) {
      uploader.progress.listen((progress) {
        onUploadProgress(preferences, progress);
      });

      uploader.result.listen(
        (result) {
          onUploadResult(preferences, result);
        },
      );
    },
  );
}

void onUploadProgress(SharedPreferences preferences, UploadTaskProgress progress) async {
  await uploadNotificationLock.synchronized(() async {
    await preferences.reload();
    List<String> processed = preferences.getStringList(PROCESSED_UPLOADS_KEY) ?? <String>[];
    List<String> active = preferences.getStringList(ACTIVE_UPLOADS_KEY) ?? <String>[];

    if (processed.contains(progress.taskId)) {
      return;
    }

    if (active.contains(progress.taskId) != true && (progress.progress ?? -1) < 100) {
      active.add(progress.taskId);
    }

    if (updateNotification(active, processed, progress) != true) {
      await preferences.setStringList(ACTIVE_UPLOADS_KEY, []);
    }
  });
}

Future onUploadResult(SharedPreferences preferences, UploadTaskResponse result) async {
  if ([UploadTaskStatus.complete, UploadTaskStatus.canceled, UploadTaskStatus.failed]
      .contains(result.status)) {
    await uploadNotificationLock.synchronized(() async {
      await preferences.reload();
      List<String> processed = preferences.getStringList(PROCESSED_UPLOADS_KEY) ?? <String>[];
      List<String> active = preferences.getStringList(ACTIVE_UPLOADS_KEY) ?? <String>[];
      if (processed.contains(result.taskId)) {
        return;
      }

      processed.add(result.taskId);
      await preferences.setStringList(PROCESSED_UPLOADS_KEY, processed);

      if (updateNotification(active, processed) != true) {
        await preferences.setStringList(ACTIVE_UPLOADS_KEY, []);
        FlutterUploader().clearUploads();
        await preferences.setStringList(PROCESSED_UPLOADS_KEY, []);
      }
    });
  }
}

//returns true if not canceled notification
bool updateNotification(List<String> active, List<String> processed,
    [UploadTaskProgress? taskProgress]) {
  int allActive = active.length;
  int count = active.where((element) => processed.contains(element)).length;
  active.removeWhere((element) => processed.contains(element));
  if (active.isNotEmpty) {
    _updateInProgressNotification(allActive, count);
    return true;
  } else {
    _cancelInProgressNotification();
    return false;
  }
}

Future prepareUploadNotification() async {
  return FlutterLocalNotificationsPlugin().show(
    _UPLOADS_KEY.hashCode,
    'StaffMonitor',
    'Preparing to upload files',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'StaffMonitor_upload',
        'StaffMonitorUploader',
        indeterminate: true,
        enableVibration: false,
        playSound: false,
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        onlyAlertOnce: true,
        channelShowBadge: false,
      ),
      iOS: IOSNotificationDetails(),
    ),
  );
}

void _updateInProgressNotification(int active, int finished, [int? progress]) {
  FlutterLocalNotificationsPlugin().show(
    _UPLOADS_KEY.hashCode,
    'StaffMonitor',
    'Uploading files ($finished/$active)',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'StaffMonitor_upload',
        'StaffMonitorUploader',
        progress: progress ?? 0,
        indeterminate: progress == null,
        enableVibration: false,
        playSound: false,
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        onlyAlertOnce: true,
        channelShowBadge: false,
      ),
      iOS: IOSNotificationDetails(),
    ),
  );
}

void _cancelInProgressNotification() {
  FlutterLocalNotificationsPlugin().cancel(_UPLOADS_KEY.hashCode);
}
