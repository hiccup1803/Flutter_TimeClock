import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:pushy_flutter/pushy_flutter.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitial()) {
    _log.fine('init');
    Pushy.setNotificationIcon('ic_notification');
    Pushy.toggleInAppBanner(true);
    Pushy.toggleNotifications(true);
  }

  final _log = Logger('NotificationsCubit');

  void initListeners() {
    _log.fine('init Listeners');
    Pushy.setNotificationListener(backgroundNotificationListener);
    Pushy.setNotificationClickListener(notificationOnClick);
  }

  void notificationOnClick(Map<String, dynamic> data) {
    _log.fine('notificationOnClick: $data');
    // Extract notification message

    if (data.containsKey('message')) {
      String message = data['message']!;
      List<String> contentList = message.split("\n");

      if (data.containsKey('taskId')) {
        var taskId = data["taskId"] as int;
        emit(NotificationsOpenTask(taskId));
      } else {
        String title = contentList[1];
        String body = contentList[2];
        _log.fine('emit(NotificationsShowDialog($title, $body))');
        emit(NotificationsShowDialog(title, body));
      }
      // Clear iOS app badge number
      Pushy.clearBadge();
    }
  }
}

void backgroundNotificationListener(Map<String, dynamic> data) {
  if (data.containsKey('message')) {
    String notificationTitle = 'Staff';
    String notificationText = data['message'] ?? 'You received notification!';

    String message = data['message']!;

    List<String> contentList = message.split("\n");
    if (contentList.length == 1) {
      contentList.add("No title");
      contentList.add("There is no body");
    }
    notificationTitle = contentList[0];
    notificationText = contentList[1];
    // Android: Displays a system notification
    // iOS: Displays an alert dialog
    Pushy.notify(notificationTitle, notificationText, data);
    // Clear iOS app badge number
    Pushy.clearBadge();
  }
}
