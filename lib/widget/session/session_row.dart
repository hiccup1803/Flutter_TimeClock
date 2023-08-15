import 'package:flutter/material.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/decorated_value_widget.dart';

import '../../page/session/sessions.i18n.dart';

class SessionRow extends StatelessWidget {
  SessionRow(
    this.session, {
    this.padding = EdgeInsets.zero,
    this.allowWageView,
    required this.onChanged,
    required this.onDeleted,
  });

  final Session? session;
  final EdgeInsetsGeometry padding;
  final Function([Session? session]) onChanged;
  final Function([Session? session]) onDeleted;
  final bool? allowWageView;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Future.delayed(
            Duration(milliseconds: 250),
            () => Dijkstra.editSession(
                  session,
                  onChanged: onChanged,
                  onDeleted: onDeleted,
                ));
      },
      child: Container(
        // color: session.project?.color?.withAlpha(90) ?? Colors.white,
        decoration: projectDecoration(session?.project?.color),
        margin: EdgeInsets.only(left: 2),
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session!.clockIn!.format('HH:mm')} - ${session!.clockOut?.format('HH:mm') ?? ''}',
                    style: theme.textTheme.subtitle1,
                  ),
                  Text(
                    '${session!.project?.name ?? 'No project'.i18n}',
                    style: theme.textTheme.bodyText1,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (session!.files.isNotEmpty == true) Icon(Icons.file_copy, color: Colors.blueGrey),
                      if (session!.note?.isNotEmpty == true) Container(width: 8.0),
                      if (session!.note?.isNotEmpty == true) Icon(Icons.comment, color: Colors.blueGrey),
                      if (session!.clockIn!.isToday == false && session!.duration == null) Container(width: 8.0),
                      if (session!.clockIn!.isToday == false && session!.duration == null)
                        Column(
                          children: [
                            Icon(
                              Icons.warning_outlined,
                              color: theme.colorScheme.error,
                            ),
                            Text('Not closed!'.i18n)
                          ],
                        ),
                      if (session!.duration != null)
                        Container(
                          constraints: BoxConstraints(minWidth: 70),
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              DecoratedValueWidget(
                                session!.duration?.formatHmShrink ?? '-',
                                type: DecoratedValue.HOURS_THIN,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (allowWageView == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: DecoratedValueWidget(
                        '${session!.totalWage ?? '-'} ${session!.rateCurrency ?? ''}',
                        type: DecoratedValue.MONEY_THIN,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
