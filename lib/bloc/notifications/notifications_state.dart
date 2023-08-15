part of 'notifications_cubit.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  @override
  List<Object> get props => [];
}

class NotificationsOpenTask extends NotificationsState {
  const NotificationsOpenTask(this.taskId);

  final int taskId;

  @override
  List<Object?> get props => [taskId];
}

class NotificationsShowDialog extends NotificationsState {
  const NotificationsShowDialog(this.title, this.body);

  final String title;
  final String body;

  @override
  List<Object?> get props => [title, body];
}
