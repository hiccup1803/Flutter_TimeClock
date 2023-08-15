import 'package:flutter/material.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/utils/time_utils.dart';

import '../../page/off_time/off_time.i18n.dart';

class OffTimeRow extends StatelessWidget {
  const OffTimeRow(
    this.offTime, {
    this.padding,
    this.onChanged,
    this.onDeleted,
  });

  final OffTime offTime;
  final EdgeInsetsGeometry? padding;
  final Function([OffTime? offTime])? onChanged;
  final Function()? onDeleted;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: padding,
      margin: EdgeInsets.only(left: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        offTime.isVacation ? 'Urlop'.i18n : 'Wolne'.i18n,
                        style: theme.textTheme.headline6,
                      ),
                      Text(
                        ' - ' + '%d days'.plural(offTime.days),
                        style: theme.textTheme.headline6,
                      ),
                    ],
                  ),
                  if (offTime.days == 1)
                    Text(
                      '${offTime.startDate!.format('EEEE')}',
                      style: theme.textTheme.subtitle1,
                    ),
                  if (offTime.days > 1)
                    Text(
                      '${offTime.startDate!.format('EEEE')} - ${offTime.endDate!.format('EEEE')}',
                      style: theme.textTheme.subtitle1,
                    ),
                  if (offTime.days == 1)
                    Text(
                      '${offTime.startAt}',
                      style: theme.textTheme.subtitle1,
                    ),
                  if (offTime.days > 1)
                    Text(
                      '${offTime.startAt} - ${offTime.endAt}',
                      style: theme.textTheme.subtitle1,
                    ),
                ],
              ),
              offTime.type == 1
                  ? Container()
                  : ElevatedButton(
                      onPressed: () => Dijkstra.editOffTime(
                        offTime,
                        onChanged: onChanged,
                        onDeleted: onDeleted,
                      ),
                      child: Text('Edit'.i18n),
                    ),
            ],
          ),
          if (offTime.isVacation)
            Container(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    offTime.isApproved
                        ? 'Confirmed'.i18n
                        : offTime.isDenied
                            ? 'Rejected'.i18n
                            : offTime.isWaiting
                                ? 'Requires approval'.i18n
                                : '',
                    style: theme.textTheme.headline6,
                  ),
                  Container(width: 4),
                  if (offTime.isApproved) Icon(Icons.check_circle, color: Colors.green),
                  if (offTime.isDenied) Icon(Icons.dangerous, color: Colors.red),
                  if (offTime.isWaiting) Icon(Icons.help, color: Colors.amber),
                ],
              ),
            ),
          if (offTime.note?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
              child: Text(
                'Note'.i18n,
                style: theme.textTheme.overline!.copyWith(fontSize: 14),
              ),
            ),
          if (offTime.note?.isNotEmpty == true)
            Container(
              decoration: BoxDecoration(border: Border.all()),
              padding: const EdgeInsets.all(6.0),
              child: Text(
                offTime.note ?? '',
                style: theme.textTheme.bodyText2,
              ),
            ),
        ],
      ),
    );
  }
}
