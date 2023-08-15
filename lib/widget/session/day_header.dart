import 'package:flutter/material.dart';
import 'package:staffmonitor/model/sessions_day_summary.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/widget/decorated_value_widget.dart';

import '../../page/session/sessions.i18n.dart';

class DayHeader extends StatelessWidget {
  const DayHeader(this.summary, {this.padding = EdgeInsets.zero});

  final SessionsDaySummary summary;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    String label;
    if (summary.day!.isToday) {
      label = 'Today'.i18n;
    } else if (summary.day!.add(Duration(days: 1)).isToday) {
      label = 'Yesterday'.i18n;
    } else {
      label = summary.day!.format('MMMM dd'.i18n);
    }

    return Column(
      children: [
        Divider(),
        Container(
          color: theme.colorScheme.primaryVariant.withAlpha(33),
          padding: EdgeInsets.only(left: 12) + (padding as EdgeInsets),
          child: Row(
            children: [
              Text(
                label,
                style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w300),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DecoratedValueWidget(
                  summary.count.toString() ,
                  type: DecoratedValue.SESSIONS,
                ),
              ),
              Spacer(),
              DecoratedValueWidget(
                summary.time.formatHmShrink,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
