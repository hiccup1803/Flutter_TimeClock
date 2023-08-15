import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/repository/files_repository.dart';
import 'package:staffmonitor/uploader.dart';
import 'package:synchronized/synchronized.dart';

part 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  FileUploadCubit(this.filesRepository) : super(FileUploadIdle());

  final log = Logger('FileUploadCubit');
  final FilesRepository filesRepository;

  late StreamSubscription _progressSubscription;
  late StreamSubscription _resultSubscription;

  final Map<String, List<String>> activeUploads = Map();
  final List<String> finishedUploads = List.empty(growable: true);
  final Map<String, PlatformFile> uploadFiles = Map();
  final Map<String, int?> uploadStatus = Map();
  final Map<String, dynamic> uploadResult = Map();
  final _lock = Lock();

  void init() {
    _progressSubscription = filesRepository.flutterUploader.progress.listen(onProgress);
    _resultSubscription = filesRepository.flutterUploader.result.listen(onResult);
    log.isLoggable(Level.OFF);
  }

  @override
  Future<Function?> close() {
    _progressSubscription.cancel();
    _resultSubscription.cancel();
    return super.close().then((value) => value as Function?);
  }

  void onProgress(UploadTaskProgress progress) {
    SharedPreferences.getInstance().then((preferences) {
      onUploadProgress(preferences, progress);
    });
    if ((progress.progress ?? -1) > -1) {
      uploadStatus[progress.taskId] = progress.progress;
    }
  }

  bool isActiveUpload(String taskId) {
    bool active =
        activeUploads.values.firstWhereOrNull((element) => element.contains(taskId)) != null;
    return active;
  }

  void onResult(UploadTaskResponse result) {
    SharedPreferences.getInstance().then((preferences) {
      onUploadResult(preferences, result);
    });

    if (isActiveUpload(result.taskId) == false) {
      log.fine('onResult taskId: [${result.taskId}] is not active');
      return;
    }

    if (result.status == UploadTaskStatus.complete) {
      log.finest('onResult completed');
      if (finishedUploads.contains(result.taskId) == false) {
        finishedUploads.add(result.taskId);
      }
      if (uploadStatus.containsKey(result.taskId)) {
        uploadStatus[result.taskId] = 100;
      } else {
        log.fine('onResult: task does not exist in uploadStatuses');
      }
      if (result.response?.isNotEmpty == true) {
        uploadResult[result.taskId] = AppFile.fromJson(jsonDecode(result.response!));
      }
      log.fine(
          'onResult | taskId: ${result.taskId}, status: ${result.status}, code: ${result.statusCode}');
      updateState();
    } else if (result.status == UploadTaskStatus.failed) {
      log.finest('onResult failed');
      uploadStatus.remove(result.taskId);
      if (result.response?.isNotEmpty == true) {
        uploadResult[result.taskId] = ApiError.fromJson(jsonDecode(result.response ?? ''));
      }
    }
  }

  void uploadManyFiles(List<PlatformFile> files,
      {int? sessionId, int? taskId, bool admin = false}) async {
    if (sessionId == null && taskId == null) {
      return;
    }
    try {
      var uploadIds = files.map((file) async {
        Future<String> future;
        String tag = _buildTag(sessionId: sessionId, taskId: taskId);
        if (sessionId != null) {
          future = filesRepository.uploadSessionFile(file, sessionId, admin);
        } else if (taskId != null) {
          future = filesRepository.uploadTaskFile(file, taskId, admin);
        } else {
          return null;
        }
        return future.then((uploadId) async {
          log.fine('uploadFile: $sessionId + ${file.name} -> $uploadId');
          await _lock.synchronized(() {
            activeUploads[tag] = [
              uploadId,
              ...(activeUploads[tag] ?? []),
            ];
            uploadFiles[uploadId] = file;
            uploadStatus[uploadId] = 0;
          });
          return uploadId;
        });
      });
      Future.wait(uploadIds).then((value) {
        List<String> taskIds = [];
        value.forEach((element) {
          if (element != null) {
            taskIds.add(element);
          }
        });
        SharedPreferences.getInstance().then((preferences) async {
          await uploadNotificationLock.synchronized(() async {
            await preferences.reload();
            var list = preferences.getStringList(ACTIVE_UPLOADS_KEY) ?? [];
            bool showPrepare = list.isEmpty;
            list += taskIds;
            log.fine('uploadFiles ACTIVE_UPLOADS_KEY: $list');
            await preferences.setStringList(ACTIVE_UPLOADS_KEY, list);
            if (showPrepare) {
              prepareUploadNotification();
            }
          });
          updateState();
        });
      });
    } catch (e) {
      log.shout('uploadFile: $e');
    }
  }

  Future uploadFile(PlatformFile file,
      {int? sessionId,
      int? taskId,
      int? clockId,
      String? pin,
      String? terminalId,
      String? note,
      bool admin = false}) async {
    if (sessionId == null && taskId == null && clockId == null) {
      return;
    }

    try {
      Future<String> future;
      String tag = _buildTag(sessionId: sessionId, taskId: taskId);
      if (sessionId != null) {
        future = filesRepository.uploadSessionFile(file, sessionId, admin, note);
        tag = 'session_$sessionId';
      } else if (taskId != null) {
        future = filesRepository.uploadTaskFile(file, taskId, admin, note);
        tag = 'task_$taskId';
      } else if (clockId != null && pin != null && terminalId != null) {
        future = filesRepository.uploadTerminalFile(file, pin, terminalId, clockId, admin, note);
        tag = 'task_$clockId';
      } else {
        return;
      }
      future.then((uploadId) async {
        log.fine('uploadFile: $sessionId + ${file.name} -> $uploadId');
        await _lock.synchronized(() {
          activeUploads[tag] = [uploadId, ...(activeUploads[tag] ?? [])];
          uploadFiles[uploadId] = file;
          uploadStatus[uploadId] = 0;
        });
        SharedPreferences.getInstance().then((preferences) async {
          updateState();
          await uploadNotificationLock.synchronized(() async {
            await preferences.reload();
            var list = preferences.getStringList(ACTIVE_UPLOADS_KEY) ?? [];
            bool showPrepare = list.isEmpty;
            log.fine('uploadFile ACTIVE_UPLOADS_KEY: $list');
            await preferences.setStringList(ACTIVE_UPLOADS_KEY, list..add(uploadId));
            if (showPrepare) {
              prepareUploadNotification();
            }
          });
        });
      });
    } catch (e) {
      log.shout('uploadFile: $e');
    }
  }

  Future<bool> deleteSessionFile(int fileId) {
    return filesRepository.deleteSessionFile(fileId);
  }

  Future<bool> deleteTaskFile(int fileId) {
    return filesRepository.deleteTaskFile(fileId);
  }

  void taskConsumed(
    String task, {
    int? sessionId,
    int? taskId,
  }) async {
    await _lock.synchronized(() {
      uploadStatus.remove(task);
      uploadResult.remove(task);
      uploadFiles.remove(task);
      finishedUploads.remove(task);
      String tag = _buildTag(sessionId: sessionId, taskId: taskId);
      if (tag.isNotEmpty) {
        List<String> list = List.from(activeUploads[tag] ?? []);
        list.remove(task);
        activeUploads[tag] = list;
      }
      updateState();
    });
  }

  void updateState() {
    emit(FileUploadInProgress(
      Map.from(activeUploads),
      List.from(finishedUploads),
      Map.from(uploadFiles),
      Map.from(uploadStatus),
      Map.from(uploadResult),
    ));
  }
}

String _buildTag({int? sessionId, int? taskId}) {
  if (sessionId != null) {
    return 'session_$sessionId';
  } else if (taskId != null) {
    return 'task_$taskId';
  }
  return '';
}
