part of 'edit_task_page.dart';

class TaskFiles extends StatelessWidget {
  TaskFiles(
    this.noteId,
    this.notes, {
    this.padding,
    this.showAdd = false,
    this.onDeleted,
    this.admin = false,
  });

  final log = Logger('TaskFiles');
  final int noteId;
  final EdgeInsets? padding;
  final List<CalendarNote> notes;
  final bool showAdd;
  final bool admin;
  final Function(AppFile file)? onDeleted;

  final List<String> nameList = [];

  void pickFile(BuildContext context) async {
    log.finer('pickFile');
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    result?.files.toList().asMap().forEach((key, value) {
      if (result.files[key].size > 1024 * 1000 * 10) {
        nameList.add(result.files[key].name);
      } else {
        BlocProvider.of<FileUploadCubit>(context).uploadFile(result.files[key], taskId: noteId, admin: admin);
      }
    });
    if (nameList.length > 0) showSizeDialog(context);
  }

  void showSizeDialog(BuildContext context) {
    FileSizeOverDialog.show(context: context, nameList: nameList).then((value) => nameList.clear());
  }

  void showFileDetails(BuildContext context, AppFile appFile) {
    FileDetailsDialog.show(context: context, file: appFile, isTask: true).then((value) {
      if (value == FileDetailsDialog.FILE_DELETED) {
        onDeleted?.call(appFile);
      }
    });
  }

  List<Widget> _buildRowChildren(BuildContext context, List<dynamic> mixedFilesAndNotes) {
    final theme = Theme.of(context);
    final children = List<Widget>.of([
      if (showAdd)
        FileWidget(
          name: 'Upload file'.i18n,
          type: FileWidget.uploadType,
          backgroundColor: theme.colorScheme.primary,
          onColor: theme.colorScheme.onPrimary,
          onTap: (context) => pickFile(context),
        ),
    ]);
    final list = mixedFilesAndNotes.map((e) {
      if (e is AppFile)
        return FileWidget(
          file: e,
          type: e.type,
          name: e.name,
          onTapFile: showFileDetails,
        );
      if (e is UploadInProgress) {
        return FileWidget(
          uploading: true,
          name: e.name,
          progress: e.progress,
          backgroundColor: Colors.grey,
          type: FileWidget.uploadType,
        );
      }
      return FileWidget();
    }).toList();

    children.addAll(list);
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileUploadCubit, FileUploadState>(
      builder: (context, state) {
        List<dynamic> fileStates = List.empty(growable: true);
        if (state is FileUploadInProgress) {
          List<String> sessionUploads = state.activeUploadsOfTask(notes.last.id);
          fileStates = sessionUploads.map<dynamic>((task) {
            if (state.file(task) != null)
              return UploadInProgress(
                state.file(task)!.name,
                state.progress(task),
              );
          }).toList();
        }
        var fileAndNotesList = [];
        notes.forEach((element) {
          if (element.file != null) fileAndNotesList.add(element.file);
        });
        fileStates.addAll(fileAndNotesList);
        return Container(
          padding: padding,
          child: Stack(
            children: [
              Wrap(
                children: _buildRowChildren(context, fileStates),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UploadInProgress extends Equatable {
  final String name;
  final int progress;

  UploadInProgress(this.name, this.progress);

  @override
  List<Object> get props => [this.name, this.progress];

  @override
  String toString() => 'UploadInProgress{name: $name}';
}

class FileWidget extends StatelessWidget {
  static final padding = const EdgeInsets.symmetric(vertical: 12.0);
  static final iconSize = 40.0;
  static final uploadType = 'upload';

  FileWidget({
    this.name,
    this.type,
    this.file,
    this.onTapFile,
    this.onTap,
    this.backgroundColor,
    this.onColor,
    this.uploading = false,
    this.progress = 0,
  });

  final AppFile? file;
  final String? name;
  final String? type;
  final bool uploading;
  final Color? backgroundColor;
  final Color? onColor;
  final int progress;

  //if file is not null this function should be called
  final Function(BuildContext context, AppFile appFile)? onTapFile;

  //if file is null then this function should be called
  final Function(BuildContext context)? onTap;

  IconData getIcon() {
    if (type == uploadType) {
      return Icons.file_upload;
    }
    if (type?.toLowerCase().contains('text') == true) {
      return MdiIcons.fileDocumentOutline;
    }
    if (type?.toLowerCase().contains('image') == true) {
      return MdiIcons.fileImageOutline;
    }
    if (type?.toLowerCase().contains('pdf') == true) return MdiIcons.filePdfOutline;
    return Icons.insert_drive_file_outlined;
  }

  //this function is misleading in name as it is returning access token - not a thumbnail image I suppose
  Future<String?> getThumb(BuildContext context) async {
    String? token = await BlocProvider.of<AuthCubit>(context).getAccessToken();
    return token;
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = (MediaQuery.of(context).size.width - 65) / 3;
    return Card(
      child: InkWell(
        onTap: (onTapFile == null && onTap == null)
            ? null
            : () {
                Future.delayed(Duration(milliseconds: 300), () {
                  if (file != null)
                    onTapFile?.call(context, file!);
                  else
                    onTap?.call(context);
                });
              },
        child: Container(
          width: cardWidth,
          decoration: backgroundColor != null
              ? BoxDecoration(
                  border: Border.all(color: backgroundColor!, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: Column(
            children: [
              type?.toLowerCase().contains('image') == true
                  ? FutureBuilder<String?>(
                      future: getThumb(context),
                      builder: (BuildContext context, projectSnap) {
                        if (projectSnap.connectionState == ConnectionState.none || projectSnap.hasData == false) {
                          return Container(
                            height: 40,
                            width: 60,
                            child: Icon(Icons.image),
                          );
                        }
                        if (projectSnap.data == null)
                          return Container(
                            height: 40,
                            width: 60,
                            child: Icon(Icons.image),
                          );
                        return Container(
                          height: 65,
                          width: cardWidth - 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: file!.thumbnailDownloadUrl != null
                              ? Image.network(file!.thumbnailDownloadUrl!,
                                  headers: {'Authorization': "Bearer ${projectSnap.data}"}, fit: BoxFit.cover)
                              : Icon(
                                  Icons.image,
                                  size: 50,
                                ),
                        );
                      },
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 4,
                        ),
                        Icon(
                          getIcon(),
                          size: iconSize - 10,
                          color: backgroundColor ?? Colors.black,
                        ),
                        Container(
                          height: 8,
                          child: uploading ? LinearProgressIndicator() : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
                          child: Text(
                            name ?? 'a file'.i18n,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: backgroundColor != null ? TextStyle(color: backgroundColor) : null,
                          ),
                        ),
                      ],
                    ),
              Container(
                height: 2,
                child: uploading
                    ? LinearProgressIndicator(
                        value: progress / 100.0,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
