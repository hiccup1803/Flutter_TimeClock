part of 'edit_admin_file_cubit.dart';

abstract class EditAdminFileState extends Equatable {
  const EditAdminFileState();
}

class EditAdminFileInitial extends EditAdminFileState {
  @override
  List<Object> get props => [];
}

class EditAdminFileReady extends EditAdminFileState {
  EditAdminFileReady(
    this.requireSaving,
    this.changed, {
    this.savedAdminSessionFile,
    this.adminSessionFile,
    this.adminTaskFile,
    this.savedAdminTaskFile,
  });

  final AdminSessionFile? savedAdminSessionFile;
  final AdminSessionFile? adminSessionFile;
  final AdminTaskFile? adminTaskFile;
  final AdminTaskFile? savedAdminTaskFile;
  final bool requireSaving;
  final changed;

  @override
  List<Object?> get props => [
        this.requireSaving,
        this.changed,
        this.adminSessionFile,
        this.savedAdminSessionFile,
        this.adminTaskFile,
        this.savedAdminTaskFile,
      ];
}

class EditAdminFileProcessing extends EditAdminFileState {
  EditAdminFileProcessing({
    this.adminSessionFile,
    this.adminTaskFile,
  });

  final AdminSessionFile? adminSessionFile;
  final AdminTaskFile? adminTaskFile;

  @override
  List<Object?> get props => [
        this.adminSessionFile,
        this.adminTaskFile,
      ];
}

class EditAdminFileError extends EditAdminFileState {
  EditAdminFileError(this.adminSessionFile, this.error);

  final AppFile adminSessionFile;
  final AppError error;

  @override
  List<Object?> get props => [this.adminSessionFile, this.error];
}

class EditAdminFileSaved extends EditAdminFileState {
  EditAdminFileSaved({this.adminSessionFile, this.adminTaskFile, this.closePage = false});

  final AdminSessionFile? adminSessionFile;
  final AdminTaskFile? adminTaskFile;
  final bool closePage;

  @override
  List<Object?> get props => [this.adminSessionFile, this.adminTaskFile, this.closePage];
}

class EditAdminFileDeleted extends EditAdminFileSaved {
  EditAdminFileDeleted({
    AdminSessionFile? sessionFile,
    AdminTaskFile? taskFile,
  }) : super(adminSessionFile: sessionFile, adminTaskFile: taskFile, closePage: true);
}
