part of 'edit_nfc_cubit.dart';

abstract class EditNfcState extends Equatable {
  const EditNfcState();
}

class EditNfcInitial extends EditNfcState {
  @override
  List<Object> get props => [];
}

class EditNfcReady extends EditNfcState {
  EditNfcReady(this.task, this.requireSaving, this.changed, this.users, this.selectedUser);

  final AdminNfc? task;
  final bool requireSaving;
  final bool changed;
  final List<Profile>? users;
  final String selectedUser;

  @override
  List<Object?> get props => [
        this.task,
        this.requireSaving,
        this.changed,
        this.users,
        this.selectedUser,
      ];
}

class EditNfcProcessing extends EditNfcState {
  EditNfcProcessing(this.task);

  final AdminNfc? task;

  @override
  List<Object?> get props => [this.task];
}

class EditNfcError extends EditNfcState {
  EditNfcError(this.task, this.error);

  final AdminNfc? task;
  final AppError error;

  @override
  List<Object?> get props => [this.task, this.error];
}

class EditNfcValidator extends EditNfcState {
  EditNfcValidator(this.task, this.selectedUser, {this.titleError = ''});

  final AdminNfc? task;
  final String selectedUser;
  final String? titleError;

  @override
  List<Object?> get props => [this.task, this.selectedUser, this.titleError];
}

class EditNfcSaved extends EditNfcState {
  EditNfcSaved(this.task, {this.closePage = true});

  final AdminNfc? task;
  final bool closePage;

  @override
  List<Object?> get props => [this.task, this.closePage];
}

class EditNfcDeleted extends EditNfcSaved {
  EditNfcDeleted(AdminNfc? task) : super(task, closePage: true);
}