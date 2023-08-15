part of 'edit_terminal_cubit.dart';

abstract class EditTerminalState extends Equatable {
  const EditTerminalState();
}

class EditTerminalInitial extends EditTerminalState {
  @override
  List<Object> get props => [];
}

class EditTerminalReady extends EditTerminalState {
  EditTerminalReady(
      this.task, this.requireSaving, this.changed, this.selectedProject, this.photoVerification);

  final AdminTerminal? task;
  final bool requireSaving;
  final bool changed;
  final Project selectedProject;
  final bool photoVerification;

  @override
  List<Object?> get props => [
        this.task,
        this.requireSaving,
        this.changed,
        this.selectedProject,
        this.photoVerification,
      ];
}

class EditTerminalProcessing extends EditTerminalState {
  EditTerminalProcessing(this.task);

  final AdminTerminal? task;

  @override
  List<Object?> get props => [this.task];
}

class EditTerminalError extends EditTerminalState {
  EditTerminalError(this.task, this.error);

  final AdminTerminal? task;
  final AppError error;

  @override
  List<Object?> get props => [this.task, this.error];
}

class EditTerminalValidator extends EditTerminalState {
  EditTerminalValidator(this.task, this.selectedProject, {this.titleError = ''});

  final AdminTerminal? task;
  final Project selectedProject;
  final String? titleError;

  @override
  List<Object?> get props => [this.task, this.selectedProject, this.titleError];
}

class EditTerminalSaved extends EditTerminalState {
  EditTerminalSaved(this.task, {this.closePage = true});

  final AdminTerminal? task;
  final bool closePage;

  @override
  List<Object?> get props => [this.task, this.closePage];
}

class EditTerminalDeleted extends EditTerminalSaved {
  EditTerminalDeleted(AdminTerminal? task) : super(task, closePage: true);
}

class EditTerminalCodeSaved extends EditTerminalSaved {
  EditTerminalCodeSaved(AdminTerminal? task) : super(task, closePage: true);
}