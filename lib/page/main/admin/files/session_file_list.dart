part of 'admin_files_widget.dart';

class SessionFilesList extends StatelessWidget {
  const SessionFilesList({Key? key, required this.readFiles, required this.controller})
      : super(key: key);

  final Loadable<Map<DateTime, List<AdminSessionFile>>> Function(AdminFilesReady state) readFiles;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminFilesCubit, AdminFilesState>(
      builder: (context, state) {
        if (state is AdminFilesReady) {
          Loadable<Map<DateTime, List<AdminSessionFile>>> adminFiles = readFiles.call(state);

          if (adminFiles.inProgress && adminFiles.value?.isEmpty == true) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SpinKitCircle(
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          }
          if (adminFiles.error != null) {
            return Center(
              child: Text(
                adminFiles.error!.formatted()!,
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (adminFiles.value?.isNotEmpty != true) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('No files found'.i18n),
              ),
            );
          }
          final list = adminFiles.value?.entries.toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (adminFiles.inProgress) LinearProgressIndicator(),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: list?.length ?? 0,
                  itemBuilder: (context, index) {
                    return _AdminFilesRow(
                      date: list![index].key,
                      adminFiles: list[index].value,
                    );
                  },
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}

class _AdminFilesRow extends StatelessWidget {
  const _AdminFilesRow({required this.date, required this.adminFiles});

  final DateTime date;
  final List<AdminSessionFile> adminFiles;

  String formattedDate() {
    if (date.isToday) {
      return 'Today'.i18n;
    } else if (date.add(Duration(days: 1)).isToday) {
      return 'Yesterday'.i18n;
    }
    return date.format();
  }

  Function()? onFileTap(AdminSessionFile session) {
    return null;
  }

  void _showDetailFileCarousel(BuildContext ctx, int index, DateTime date) {
    final AdminFilesCubit adminFilesCubit = BlocProvider.of<AdminFilesCubit>(ctx);
    Navigator.of(ctx)
        .push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<AdminFilesCubit>.value(
          value: adminFilesCubit,
          child: DetailFileCarouselPage(initialIndex: index, keyDate: date),
        ),
      ),
    )
        .then((value) {
      if (value == DetailFileCarouselPage.NOTE_CHANGED ||
          value == DetailFileCarouselPage.ADMIN_FILE_DELETED) {
        BlocProvider.of<AdminFilesCubit>(ctx).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StickyHeader(
      header: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 2,
                color: AppColors.color3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                formattedDate(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color3,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: AppColors.color3,
              ),
            ),
          ],
        ),
      ),
      content: Container(
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: adminFiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            mainAxisExtent: 236,
          ),
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: InkWell(
                onTap: () => _showDetailFileCarousel(context, index, date),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AuthorizedImageWidget(
                        imageUrl: adminFiles[index].thumbnailDownloadUrl,
                        height: 140,
                        width: 140,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        adminFiles.elementAt(index).name!,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.color1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'File Type:'.i18n,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color3,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              adminFiles.elementAt(index).type!,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'File Size:'.i18n,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color3,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              FileSizeUtil.formatBytes(adminFiles.elementAt(index).size!, 2),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
