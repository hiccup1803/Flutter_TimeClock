part of 'edit_task_cubit.dart';

abstract class EditTaskState extends Equatable {
  const EditTaskState();
}

class EditTaskInitial extends EditTaskState {
  @override
  List<Object> get props => [];
}

class EditTaskReady extends EditTaskState {
  EditTaskReady(this.task, this.requireSaving, this.hadClockOut, this.changed, this.selectedProject,
      this.sendEmail, this.sendPush, this.sendImmediately);

  final CalendarTask? task;
  final bool requireSaving;
  final bool hadClockOut;
  final bool changed;
  final Project selectedProject;
  final bool sendEmail;
  final bool sendPush;
  final bool sendImmediately;

  @override
  List<Object?> get props => [
        this.task,
        this.requireSaving,
        this.hadClockOut,
        this.changed,
        this.selectedProject,
        this.sendEmail,
        this.sendPush,
        this.sendImmediately,
      ];
}

class EditTaskProcessing extends EditTaskState {
  EditTaskProcessing(this.task);

  final CalendarTask? task;

  @override
  List<Object?> get props => [this.task];
}

class EditTaskError extends EditTaskState {
  EditTaskError(this.task, this.error);

  final CalendarTask? task;
  final AppError error;

  @override
  List<Object?> get props => [this.task, this.error];
}

class EditTaskValidator extends EditTaskState {
  EditTaskValidator(this.task, {this.titleError = '', this.isAssignee = false});

  final CalendarTask? task;
  final String? titleError;
  final bool isAssignee;

  @override
  List<Object?> get props => [this.task, this.titleError, this.isAssignee];
}

class EditTaskSaved extends EditTaskState {
  EditTaskSaved(this.task, {this.closePage = false});

  final CalendarTask? task;
  final bool closePage;

  @override
  List<Object?> get props => [this.task, this.closePage];
}

class EditTaskDeleted extends EditTaskSaved {
  EditTaskDeleted(CalendarTask? task) : super(task, closePage: true);
}
