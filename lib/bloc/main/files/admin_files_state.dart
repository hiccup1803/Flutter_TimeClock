part of 'admin_files_cubit.dart';

abstract class AdminFilesState extends Equatable {
  const AdminFilesState();
}

class AdminFilesInitial extends AdminFilesState {
  @override
  List<Object> get props => [];
}

class AdminFilesReady extends AdminFilesState {
  AdminFilesReady(this.selectedDate, this.files, this.taskFiles);

  final DateTime selectedDate;
  final Loadable<Map<DateTime, List<AdminSessionFile>>> files;

  final Loadable<Map<DateTime, List<AdminTaskFile>>> taskFiles;

  @override
  List<Object?> get props => [this.selectedDate, this.files, this.taskFiles];
}
