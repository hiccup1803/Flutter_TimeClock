import 'package:staffmonitor/model/user_history.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import 'terminal.i18n.dart';

class UserActionInfoWidget extends StatelessWidget {
  const UserActionInfoWidget({
    required this.userHistory,
    required this.inProgress,
    required this.countDownSeconds,
  });

  final UserHistory userHistory;
  final bool inProgress;
  final int countDownSeconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      child: Column(
        children: [
          Text(
            userHistory.username,
            style: theme.textTheme.headline5,
          ),
          SizedBox(height: 20.0),
          if (userHistory.currentSessionStartedAt != null)
            Text(
              'Work time'.i18n,
              style: theme.textTheme.headline4,
            ),
          if (userHistory.currentSessionStartedAt != null)
            Text(
              DateTime.now()
                  .difference(userHistory.currentSessionStartedAt!)
                  .formatHoursMinutesSeconds,
              style: theme.textTheme.headline6,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 8,
              child: inProgress ? LinearProgressIndicator() : null,
            ),
          ),
          if (userHistory.currentSessionStartedAt != null)
            Card(
              color: theme.primaryColorDark,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your session will end in %ds'
                      .i18n
                      .fill([countDownSeconds > 0 ? countDownSeconds : 0]),
                  style: theme.textTheme.headline6?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          if (userHistory.currentSessionStartedAt == null)
            Card(
              color: AppColors.positiveGreen,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your session will start in %ds'
                      .i18n
                      .fill([countDownSeconds > 0 ? countDownSeconds : 0]),
                  style: theme.textTheme.headline6?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
