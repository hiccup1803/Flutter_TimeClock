part of 'admin_off_times_widget.dart';

class AdminOffTimeBottomSheet extends StatefulWidget {
  const AdminOffTimeBottomSheet(
    this.offTime,
    this.profile, {
    this.onAccept,
    this.onDeny,
    this.onDelete,
    this.onChanged,
  });

  final AdminOffTime offTime;
  final Profile profile;

  ///return updated session
  final Future<AdminOffTime> Function()? onAccept;

  ///return updated session
  final Future<AdminOffTime> Function()? onDeny;

  ///return true if deleted - it will pop bottom sheet
  final Future<bool> Function()? onDelete;

  final Function(AdminOffTime)? onChanged;

  @override
  _AdminOffTimeBottomSheetState createState() => _AdminOffTimeBottomSheetState();

  static void show(
    BuildContext context, {
    required AdminOffTime offTime,
    required Profile profile,
    Future<AdminOffTime> Function()? onAccept,
    Future<AdminOffTime> Function()? onDeny,
    Future<bool> Function()? onDelete,
    void Function(AdminOffTime)? onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AdminOffTimeBottomSheet(
          offTime,
          profile,
          onAccept: onAccept,
          onDeny: onDeny,
          onDelete: onDelete,
          onChanged: onChanged,
        );
      },
    );
  }
}

class _AdminOffTimeBottomSheetState extends State<AdminOffTimeBottomSheet> {
  final _log = Logger('AdminOffTimeBottomSheetState');
  bool _loading = false;

  late AdminOffTime _offTime;

  @override
  void initState() {
    super.initState();
    _offTime = widget.offTime;
  }

  void _accept() {
    setState(() {
      _loading = true;
    });
    widget.onAccept?.call().then(
      (value) {
        setState(() {
          _offTime = value;
          _loading = false;
        });
      },
      onError: (e, stack) {
        setState(() {
          _loading = false;
        });
        _log.shout('_accept() error', e, stack);
        _onError(e);
      },
    );
  }

  void _deny() {
    setState(() {
      _loading = true;
    });
    widget.onDeny?.call().then(
      (value) {
        setState(() {
          _offTime = value;
          _loading = false;
        });
      },
      onError: (e, stack) {
        setState(() {
          _loading = false;
        });
        _log.shout('_accept() error', e, stack);
        _onError(e);
      },
    );
  }

  void _delete() {
    setState(() {
      _loading = true;
    });
    widget.onDelete?.call().then((value) {
      Navigator.of(context).pop();
    }, onError: (e, stack) {
      _log.shout('_delete() error', e, stack);
      _onError(e);
    });
  }

  void _edit() {
    Dijkstra.editAdminOffTime(
      widget.offTime,
      onChanged: (value) {
        setState(() {
          _offTime = value;
        });
        widget.onChanged?.call(value);
      },
      onDeleted: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _onError(e) {
    FailureDialog.show(
            context: context,
            content: Text((e is AppError ? e.formatted() : null) ?? 'An error occurred'.i18n))
        .then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 3.0,
              vertical: 8,
            ),
            color: AppColors.color3,
          ),
          if (_loading) LinearProgressIndicator(),
          AdminOffTimeRowWidget(
            _offTime,
            widget.profile,
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          SizedBox(height: 16),
          Text('Note'.i18n,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.color3,
              )),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.color3.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(minHeight: 80),
            child: Text(
              _offTime.note ?? '',
              maxLines: 5,
            ),
          ),
          Container(height: 16.0),
          if (_offTime.isVacation)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(primary: AppColors.accept),
                    icon: Icon(Icons.check),
                    label: Text('Accept'.i18n),
                    onPressed: (_loading != true && _offTime.isApproved != true) ? _accept : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(primary: AppColors.delete),
                    icon: Icon(Icons.close),
                    label: Text('Deny'.i18n),
                    onPressed: (_loading != true && _offTime.isDenied != true) ? _deny : null,
                  ),
                ),
              ],
            ),
          Divider(color: AppColors.color3),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(primary: AppColors.edit),
                  icon: Icon(Icons.edit_outlined),
                  label: Text('Edit'.i18n),
                  onPressed: (_loading != true) ? _edit : null,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(primary: AppColors.delete),
                  icon: Icon(Icons.delete_outlined),
                  label: Text('Delete'.i18n),
                  onPressed: (_loading != true) ? _delete : null,
                ),
              ),
            ],
          ),
          Container(height: 16),
        ],
      ),
    );
  }
}
