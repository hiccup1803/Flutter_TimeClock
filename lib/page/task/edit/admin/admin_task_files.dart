part of 'edit_admin_task_page.dart';

class AdminTaskFiles extends StatelessWidget {
  AdminTaskFiles(
    this.noteId,
    this.note,
    this.notes, {
    this.padding,
    this.showAdd = false,
    this.onDeleted,
  });

  final log = Logger('AdminTaskFiles');
  final int noteId;
  final CalendarNote? note;
  final EdgeInsets? padding;
  final List<CalendarNote> notes;
  final bool showAdd;
  final Function(AppFile file)? onDeleted;

  final List<String> nameList = [];

  void pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    result?.files.toList().asMap().forEach((key, value) {
      if (result.files[key].size > 1024 * 1000 * 10) {
        nameList.add(result.files[key].name);
      } else {
        if (noteId < 0) {
          BlocProvider.of<EditTaskCubit>(context).createNote('Attached: ' + result.files[key].name).then(
            (note) {
              BlocProvider.of<FileUploadCubit>(context).uploadFile(result.files[key], taskId: note.id, admin: true);
            },
            onError: (e, stack) {
              log.shout('createNote', e, stack);
            },
          );
        } else {
          BlocProvider.of<FileUploadCubit>(context).uploadFile(result.files[key], taskId: noteId, admin: true);
        }
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

  List<Widget> _buildRowChildren(
    BuildContext context,
    List<dynamic> mixedFiles,
  ) {
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

    final list = mixedFiles.map((e) {
      return Container(
        width: MediaQuery.of(context).size.width - 20,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: AppColors.color3.withOpacity(0.4), width: 2)),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        padding: EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note != null) NoteAuthorAndDateWidget(note!),
                    if (note != null) SizedBox(height: 4),
                    if (e is String)
                      SelectableText(
                        e,
                        style: TextStyle(fontSize: 14),
                      ),
                    if (e is AppFile)
                      Text(
                        note?.note ?? 'Attached: ${e.name}',
                        style: TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
            if (e is AppFile)
              FileWidget(
                file: e,
                type: e.type,
                name: e.name,
                onTapFile: showFileDetails,
              ),
          ],
        ),
      );
    }).toList();

    children.addAll(list);

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileUploadCubit, FileUploadState>(
      builder: (context, state) {
        List<dynamic> fileStates = List.empty(growable: true);
        var fileList = [];
        notes.forEach((element) {
          if (element.file != null) {
            fileList.add(element.file);
          } else if (element.note != null) {
            fileList.add(element.note);
          }
        });
        fileStates.addAll(fileList);
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
          padding: EdgeInsets.symmetric(vertical: 5.0),
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
                            height: 65,
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
                        Icon(
                          getIcon(),
                          size: iconSize,
                          color: backgroundColor ?? Colors.black,
                        ),
                        Container(
                          height: 8,
                          child: uploading ? LinearProgressIndicator() : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
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
