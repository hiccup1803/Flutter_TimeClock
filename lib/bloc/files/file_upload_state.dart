part of 'file_upload_cubit.dart';

abstract class FileUploadState extends Equatable {
  const FileUploadState();
}

class FileUploadIdle extends FileUploadState {
  @override
  List<Object> get props => [];
}

class FileUploadInProgress extends FileUploadState {
  final Map<String, List<String>> sessionUploads;
  final List<String> finishedUploads;
  final Map<String, PlatformFile> uploadFiles;

  final Map<String, int> uploadStatus;
  final Map<String, dynamic> uploadResult;

  List<String> activeUploadsOfSession(int sessionId) {
    List<String> list = List.from(sessionUploads[_buildTag(sessionId: sessionId)] ?? []);
    list.removeWhere((element) => finishedUploads.contains(element));
    return list;
  }

  List<String> activeUploadsOfTask(int taskId) {
    List<String> list = List.from(sessionUploads[_buildTag(taskId: taskId)] ?? []);
    list.removeWhere((element) => finishedUploads.contains(element));
    return list;
  }

  PlatformFile? file(String task) => uploadFiles[task];

  int progress(String task) => uploadStatus[task] ?? 0;

  dynamic result(String task) => uploadResult[task];

  FileUploadInProgress(
    this.sessionUploads,
    this.finishedUploads,
    this.uploadFiles,
    this.uploadStatus,
    this.uploadResult,
  );

  @override
  List<Object?> get props => [
        this.sessionUploads,
        this.finishedUploads,
        this.uploadFiles,
        this.uploadStatus,
        this.uploadResult,
      ];
}
