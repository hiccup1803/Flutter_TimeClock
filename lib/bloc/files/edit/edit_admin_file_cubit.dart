import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/model/admin_task_file.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/repository/files_repository.dart';

part 'edit_admin_file_state.dart';

class EditAdminFileCubit extends Cubit<EditAdminFileState> {
  EditAdminFileCubit(this._filesRepository, [this.isTaskFile = false])
      : super(EditAdminFileInitial());

  final FilesRepository _filesRepository;
  bool isTaskFile;
  final log = Logger('EditAdminFileCubit');

  late AdminSessionFile _adminSessionFile;
  late AdminSessionFile _editedAdminSessionFile;
  late AdminTaskFile _adminTaskFile;
  late AdminTaskFile _editedAdminTaskFile;
  bool _hasChanged = false;

  bool get requireSaving => isTaskFile
      ? _editedAdminTaskFile != _adminTaskFile
      : _editedAdminSessionFile != _adminSessionFile;

  void init({AdminSessionFile? sessionFile, AdminTaskFile? taskFile}) {
    if (taskFile != null) {
      isTaskFile = true;
      _adminTaskFile = taskFile.copyWithTaskFile(note: taskFile.note ?? '');
      _editedAdminTaskFile = _adminTaskFile;
      emit(EditAdminFileReady(false, false,
          adminTaskFile: _adminTaskFile, savedAdminTaskFile: _editedAdminTaskFile));
    } else if (sessionFile != null) {
      _adminSessionFile = sessionFile.copyWithSessionFile(note: sessionFile.note ?? '');
      _editedAdminSessionFile = _adminSessionFile;
      emit(EditAdminFileReady(false, false,
          adminSessionFile: _adminSessionFile, savedAdminSessionFile: _editedAdminSessionFile));
    }
  }

  void _updateState() {
    if (isTaskFile) {
      emit(EditAdminFileReady(requireSaving, _hasChanged,
          adminTaskFile: _adminTaskFile, savedAdminTaskFile: _editedAdminTaskFile));
    } else {
      emit(EditAdminFileReady(requireSaving, _hasChanged,
          adminSessionFile: _adminSessionFile, savedAdminSessionFile: _editedAdminSessionFile));
    }
  }

  void noteChanged(String text) {
    if (isTaskFile) {
      log.fine('noteChanged task: $text, pre requireSave: $requireSaving');
      _editedAdminTaskFile = _adminTaskFile.copyWithTaskFile(note: text);
      log.fine('noteChanged task: $text, requireSave: $requireSaving');
    } else {
      _editedAdminSessionFile = _adminSessionFile.copyWithSessionFile(note: text);
    }
    _updateState();
  }

  void deleteFile() {
    Future<bool> deleteRequest;

    if (isTaskFile) {
      deleteRequest = _filesRepository.deleteAdminTaskFile(_adminTaskFile.id!);
    } else
      deleteRequest = _filesRepository.deleteAdminSessionFile(_adminSessionFile.id!);

    deleteRequest.then(
      (result) {
        if (isTaskFile) {
          emit(EditAdminFileDeleted(taskFile: _editedAdminTaskFile));
        } else
          emit(EditAdminFileDeleted(sessionFile: _editedAdminSessionFile));
      },
      onError: (e, stack) {
        emit(EditAdminFileError(_editedAdminSessionFile, AppError.from(e)));
      },
    );
  }

  void save() {
    if (isTaskFile) {
      emit(EditAdminFileProcessing(adminTaskFile: _editedAdminTaskFile));

      _filesRepository.updateAdminTaskFileNote(_editedAdminTaskFile).then((value) {
        _editedAdminTaskFile = value;
        _hasChanged = true;
        emit(EditAdminFileSaved(adminTaskFile: _editedAdminTaskFile, closePage: true));
      }).onError((error, stackTrace) {
        log.shout('save', error, stackTrace);
        emit(EditAdminFileError(_editedAdminTaskFile, AppError.from(error)));
      });
    } else {
      emit(EditAdminFileProcessing(adminSessionFile: _editedAdminSessionFile));
      _filesRepository.updateAdminSessionFileNote(_editedAdminSessionFile).then((value) {
        _editedAdminSessionFile = value;
        _hasChanged = true;
        emit(EditAdminFileSaved(adminSessionFile: _editedAdminSessionFile, closePage: true));
      }).onError((error, stackTrace) {
        log.shout('save', error, stackTrace);
        emit(EditAdminFileError(_editedAdminSessionFile, AppError.from(error)));
      });
    }
  }

  void errorConsumed() => stateConsumed();

  void stateConsumed() {
    _updateState();
  }
}
