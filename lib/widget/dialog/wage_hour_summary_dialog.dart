import 'package:flutter/material.dart';
import 'package:staffmonitor/model/employee_summary.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';

import 'dialogs.i18n.dart';

class WageHourSummaryDialog extends AlertDialog {
  WageHourSummaryDialog(BuildContext context, {required String title, required Widget content})
      : super(
          title: Text(title),
          contentPadding: const EdgeInsets.all(0),
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'.i18n),
            )
          ],
        );

  static Future show({
    required BuildContext context,
    required EmployeeSummary summary,
    required String employeeName,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return WageHourSummaryDialog(
          context,
          title: employeeName,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //todo sum
                DataTable(
                  columnSpacing: 6,
                  columns: [
                    DataColumn(label: Text('Hours'.i18n), numeric: true),
                    DataColumn(label: Text('Rate'.i18n), numeric: true),
                    DataColumn(label: Text('Bonus'.i18n), numeric: true),
                    DataColumn(label: Text('Wage'.i18n), numeric: true),
                  ],
                  rows: summary.currencyRateWageMap.entries.map(
                    (currencyEntry) {
                      return currencyEntry.value.entries.map(
                        (wageEntry) => DataRow(cells: [
                          DataCell(
                            Text(
                              wageEntry.value.duration.formatHmLong,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          moneyCell(context, wageEntry.key, currencyEntry.key),
                          moneyCell(context, wageEntry.value.bonus, currencyEntry.key),
                          moneyCell(context, wageEntry.value.wage, currencyEntry.key),
                        ]),
                      );
                    },
                  ).fold<List<DataRow>>(List<DataRow>.empty(growable: true),
                      (previousValue, element) => previousValue..addAll(element)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static DataCell moneyCell(BuildContext context, String value, String currency) {
    return DataCell(
      RichText(
        text: TextSpan(children: [
          TextSpan(text: currency, style: TextStyle(fontSize: 12)),
          TextSpan(text: '\n'),
          TextSpan(text: value),
        ], style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        textAlign: TextAlign.end,
      ),
    );
  }
}
