part of 'detail_file_carousel_page_modal.dart';

class _SaveButton extends StatelessWidget {
  final log = Logger('SaveButton');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditAdminFileCubit, EditAdminFileState>(
      builder: (context, state) {
        bool enabled = false;
        bool loading = false;
        bool changed = false;
        if (state is EditAdminFileReady) {
          enabled = state.requireSaving;
          changed = state.changed;
        } else if (state is EditAdminFileProcessing) {
          loading = true;
        } else if (state is EditAdminFileSaved) {
          changed = true;
        }
        log.fine('requireSaving: $enabled');
        log.fine('changed: $changed');

        return WillPopScope(
          onWillPop: () async {
            log.fine('WillPopScope: loading $loading, changed $changed');
            if (!loading) {
              if (changed) {
                Navigator.pop(context, DetailFileCarouselPage.NOTE_CHANGED);
                return false;
              } else {
                return true;
              }
            }
            return false;
          },
          child: OutlinedButton(
            onPressed: enabled
                ? () {
                    context.unFocus();
                    BlocProvider.of<EditAdminFileCubit>(context).save();
                  }
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  enabled ? 'Save note'.i18n : 'Saved'.i18n,
                ),
                if (loading) SpinKitWave(size: 18, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OffTimeForm extends StatefulWidget {
  final String? initialNote;

  OffTimeForm(this.initialNote);

  @override
  _OffTimeFormState createState() => _OffTimeFormState();
}

class _OffTimeFormState extends State<OffTimeForm> {
  final log = Logger('SessionForm');

  late TextEditingController noteController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.initialNote ?? '');
    noteController.addListener(noteChanged);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  EditAdminFileCubit get cubit => BlocProvider.of<EditAdminFileCubit>(context);

  void noteChanged() => cubit.noteChanged(noteController.text);

  void deleteFile() {
    ConfirmDialog.show(
            context: context,
            title: Text('Confirm deleting'.i18n),
            content: Text(
                "This action cannot be undone. Are you sure you want to delete this file?".i18n))
        .then((result) {
      if (result == true) {
        cubit.deleteFile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditAdminFileCubit, EditAdminFileState>(
      listenWhen: (previous, current) =>
          current is EditAdminFileError || current is EditAdminFileSaved,
      listener: (context, state) {
        if (state is EditAdminFileError) {
          //
        } else if (state is EditAdminFileDeleted) {
          Navigator.of(context).pop(DetailFileCarouselPage.ADMIN_FILE_DELETED);
        } else if (state is EditAdminFileSaved) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Success the action.'.i18n)));
        }
      },
      builder: (context, state) {
        if (state is EditAdminFileInitial) {
          return Container();
        }

        late AppFile adminSessionFile;
        bool processing = true;
        if (state is EditAdminFileReady) {
          adminSessionFile = state.adminSessionFile!;
          processing = false;
        } else if (state is EditAdminFileProcessing) {
          adminSessionFile = state.adminSessionFile!;
        } else if (state is EditAdminFileSaved) {
          adminSessionFile = state.adminSessionFile!;
        } else if (state is EditAdminFileError) {
          adminSessionFile = state.adminSessionFile;
        }
        final expandedHeight = MediaQuery.of(context).size.height / 2.7;
        final borderRadius = BorderRadius.vertical(bottom: Radius.circular(16));

        final labelStyle = GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.color3,
        );
        final valueStyle = GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.color6,
        );

        const labelPadding = const EdgeInsets.only(left: 32.0, right: 32.0, top: 8.0);
        const valuePadding = const EdgeInsets.only(left: 40.0, right: 40.0);
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: expandedHeight,
              pinned: true,
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: [StretchMode.zoomBackground],
                background: Container(
                  height: expandedHeight,
                  decoration: BoxDecoration(borderRadius: borderRadius),
                  child: adminSessionFile.thumbnailDownloadUrl != null
                      ? ClipRRect(
                          borderRadius: borderRadius,
                          child: ExtendedImage.network(
                            adminSessionFile.thumbnailDownloadUrl!,
                            height: expandedHeight,
                            cache: true,
                            fit: BoxFit.contain,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: labelPadding,
                  child: Text('File Name'.i18n, style: labelStyle),
                ),
                Padding(
                  padding: valuePadding,
                  child: Text(adminSessionFile.name ?? '', style: valueStyle),
                ),
                Padding(
                  padding: labelPadding,
                  child: Text('Project'.i18n, style: labelStyle),
                ),
                Padding(
                  padding: valuePadding,
                  child: Text(
                    adminSessionFile.project?.name ?? '-',
                    style: valueStyle,
                  ),
                ),
                Padding(
                  padding: labelPadding,
                  child: Text('Uploader'.i18n, style: labelStyle),
                ),
                Padding(
                  padding: valuePadding,
                  child: Text(
                    adminSessionFile.uploader?.name ?? '',
                    style: valueStyle,
                  ),
                ),
                Padding(
                  padding: labelPadding,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Upload date'.i18n, style: labelStyle),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                adminSessionFile.createdAt?.format('yyyy-MM-dd') ?? '',
                                style: valueStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Upload Time'.i18n, style: labelStyle),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                adminSessionFile.createdAt?.format('HH:mm') ?? '',
                                style: valueStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: labelPadding,
                  child: Text('File Size'.i18n, style: labelStyle),
                ),
                Padding(
                  padding: valuePadding,
                  child: Text(
                    FileSizeUtil.formatBytes(adminSessionFile.size!, 2),
                    style: valueStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Text(
                    'Note'.i18n,
                    style: labelStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: noteController,
                    enabled: processing == false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 10,
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _SaveButton(),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.delete_forever),
                          style: ElevatedButton.styleFrom(primary: AppColors.delete),
                          onPressed: () {
                            deleteFile();
                          },
                          label: Text('Delete File'.i18n),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(primary: AppColors.accept),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await injector.filesRepository
                                      .downloadAdminSessionFile(adminSessionFile)
                                      .then((value) async {
                                    if (value?.isNotEmpty == true) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content:
                                              Text('Downloaded: %s'.i18n.fill([value ?? '']))));
                                    }
                                  });
                                },
                                child: isLoading
                                    ? SpinKitWave(size: 16, color: Colors.white)
                                    : Text('Download File'.i18n),
                              ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}
