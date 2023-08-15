part of 'my_off_times_widget.dart';

class MyOffTimeRowWidget extends StatelessWidget {
  const MyOffTimeRowWidget(
    this.offTime, {
    this.onTap,
    this.padding = const EdgeInsets.all(8),
  });

  final OffTime offTime;
  final Function()? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.color3,
    );
    var valueStyle = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.color6,
    );
    Profile? profile;
    if (BlocProvider.of<AuthCubit>(context).state is AuthAuthorized) {
      profile = (BlocProvider.of<AuthCubit>(context).state as AuthAuthorized).profile;
    }
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${profile?.name ?? ''}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.color6,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start in'.i18n,
                      style: labelStyle,
                    ),
                    Text(
                      '${offTime.startAt}',
                      style: valueStyle,
                    ),
                  ],
                ),
                SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End in'.i18n,
                      style: labelStyle,
                    ),
                    Text(
                      '${offTime.endAt}',
                      style: valueStyle,
                    ),
                  ],
                ),
                SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration'.i18n,
                      style: labelStyle,
                    ),
                    Text(
                      '%d days'.plural(offTime.days),
                      style: valueStyle,
                    ),
                  ],
                ),
                const Spacer(),
                if (offTime.note?.isNotEmpty == true)
                  Icon(
                    Icons.insert_drive_file_outlined,
                    color: theme.primaryColor,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
