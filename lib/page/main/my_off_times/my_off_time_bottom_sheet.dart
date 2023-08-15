part of 'my_off_times_widget.dart';

class MyOffTimeBottomSheet extends StatelessWidget {
  const MyOffTimeBottomSheet(this._offTime);

  final OffTime _offTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MyOffTimeRowWidget(
            _offTime,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              border: Border.all(color: AppColors.color3.withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(minHeight: 80),
            child: Text(
              _offTime.note ?? '',
              maxLines: 5,
            ),
          ),
          Container(height: kToolbarHeight),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required OffTime offTime,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MyOffTimeBottomSheet(
          offTime,
        );
      },
    );
  }
}
