part of 'session_form.dart';

class SessionFiles extends StatelessWidget {
  SessionFiles(
    this.session, {
    this.padding,
    this.showAdd = false,
    this.onDeleted,
    this.admin = false,
  });

  final log = Logger('SessionFiles');
  final EdgeInsets? padding;
  final Session session;
  final bool showAdd;
  final bool admin;
  final Function(AppFile file)? onDeleted;

  void pickFile(BuildContext context) async {
    log.finer('pickFile');
    final List<String> nameList = [];
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );
    List<PlatformFile> list = List.from(result?.files ?? []);
    list.removeWhere((element) {
      if (element.size > 1024 * 1000 * 10) {
        nameList.add(element.name);
        return true;
      }
      return false;
    });
    if (list.length > 1) {
      BlocProvider.of<FileUploadCubit>(context)
          .uploadManyFiles(list, sessionId: session.id, admin: admin);
    } else if (list.isNotEmpty) {
      BlocProvider.of<FileUploadCubit>(context)
          .uploadFile(list.first, sessionId: session.id, admin: admin);
    }
    if (nameList.isNotEmpty) {
      FileSizeOverDialog.show(context: context, nameList: nameList)
          .then((value) => nameList.clear());
    }
  }

  void showFileDetails(BuildContext context, AppFile appFile) {
    FileDetailsDialog.show(context: context, file: appFile).then((value) {
      if (value == FileDetailsDialog.FILE_DELETED) {
        onDeleted?.call(appFile);
      }
    });
  }

  List<Widget> _buildRowChildren(
    BuildContext context,
    List<dynamic> mixedFiles,
  ) {
    log.fine('build files: $mixedFiles');
    final List<FileWidget> list = mixedFiles.map<FileWidget>((e) {
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
          borderColor: AppColors.color2,
          type: FileWidget.uploadType,
        );
      }
      return FileWidget();
    }).toList();
    list.sort((a, b) => a.uploading ? (b.uploading ? 0 : -1) : (b.uploading ? 1 : 0));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileUploadCubit, FileUploadState>(
      builder: (context, state) {
        List<dynamic> fileStates = List.empty(growable: true);
        if (state is FileUploadInProgress) {
          List<String> sessionUploads = state.activeUploadsOfSession(session.id);
          log.fine('state is FileUploadInProgress sessionUploads: $sessionUploads');
          fileStates = sessionUploads
              .map<dynamic>((task) => UploadInProgress(
                    state.file(task)!.name,
                    state.progress(task),
                  ))
              .toList();
        }
        fileStates.addAll(session.files);

        return Wrap(
          children: [
            if (showAdd)
              FileWidget(
                name: 'Upload file'.i18n,
                type: FileWidget.uploadType,
                borderColor: Theme.of(context).primaryColor.withOpacity(0.75),
                onColor: Theme.of(context).primaryColor.withOpacity(0.75),
                onTap: (context) => pickFile(context),
              ),
            ..._buildRowChildren(context, fileStates),
          ],
        );
      },
    );
  }
}

class UploadInProgress extends Equatable {
  final String name;
  final int progress;

  const UploadInProgress(this.name, this.progress);

  @override
  List<Object> get props => [this.name, this.progress];

  @override
  String toString() => 'UploadInProgress{name: $name}';
}

class FileWidget extends StatelessWidget {
  static final padding = const EdgeInsets.symmetric(vertical: 12.0);
  static final iconSize = 40.0;
  static final uploadType = 'upload';

  const FileWidget({
    this.name,
    this.type,
    this.file,
    this.onTapFile,
    this.onTap,
    this.borderColor,
    this.onColor,
    this.uploading = false,
    this.progress = -1,
  });

  final AppFile? file;
  final String? name;
  final String? type;
  final bool uploading;
  final Color? borderColor;
  final Color? onColor;
  final int progress;

  //if file is not null this function should be called
  final Function(BuildContext context, AppFile appFile)? onTapFile;

  //if file is null then this function should be called
  final Function(BuildContext context)? onTap;

  IconData getIcon() {
    if (type == uploadType) {
      if (uploading) {
        return Icons.cloud_upload_outlined;
      }
      return Icons.upload_rounded;
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
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: (onTapFile == null && onTap == null)
            ? null
            : () => Future.delayed(Duration(milliseconds: 300), () {
                  if (file != null) {
                    onTapFile?.call(context, file!);
                  } else {
                    onTap?.call(context);
                  }
                }),
        child: Container(
          height: 80,
          width: cardWidth,
          decoration: borderColor != null
              ? BoxDecoration(
                  border: Border.all(color: borderColor!, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (type?.toLowerCase().contains('image') == true)
                FutureBuilder<String?>(
                  future: getThumb(context),
                  builder: (BuildContext context, snap) {
                    if (snap.connectionState == ConnectionState.none || snap.hasData == false) {
                      return Container(
                        height: 40,
                        width: 60,
                        child: Icon(Icons.image),
                      );
                    }
                    if (snap.data == null) {
                      return Container(
                        height: 40,
                        width: 60,
                        child: Icon(Icons.image),
                      );
                    }
                    return Container(
                      height: 65,
                      width: cardWidth,
                      child: file!.thumbnailDownloadUrl != null
                          ? Image.network(
                              file!.thumbnailDownloadUrl!,
                              headers: {'Authorization': "Bearer ${snap.data}"},
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, size: 50),
                    );
                  },
                ),
              if (type?.toLowerCase().contains('image') != true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(
                            getIcon(),
                            size: iconSize - 10,
                            color: borderColor ?? Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              name ?? 'a file'.i18n,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: borderColor != null ? TextStyle(color: borderColor) : null,
                            ),
                          ),
                        ],
                      ),
                      if (uploading)
                        SpinKitCircle(
                          color: Theme.of(context).colorScheme.secondary,
                          size: 55,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
