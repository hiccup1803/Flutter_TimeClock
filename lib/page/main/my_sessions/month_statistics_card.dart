import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/model/employee_summary.dart';
import 'package:staffmonitor/model/session_wage_duration.dart';
import 'package:staffmonitor/model/sessions_month_summary.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import 'my_sessions.i18n.dart';

class MonthStatisticsCard extends StatelessWidget {
  final bool loading;

  final SessionsMonthSummary? monthSummary;

  const MonthStatisticsCard({required this.loading, this.monthSummary});

  @override
  Widget build(BuildContext context) {
    List<WageAndDuration> listWageDuration =
        monthSummary?.currencyRateWageMap.values.toList() ?? [];
    List<String> listCurrency = monthSummary?.currencyRateWageMap.keys.toList() ?? [];

    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              'Month Statistics'.i18n,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.color3,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Info(
                      label: 'Days'.i18n,
                      loading: loading,
                      text: monthSummary?.days.toString() ?? '--',
                      isRate: false,
                      currencyText: '',
                    ),
                  ),
                  const VerticalDivider(thickness: 1.5),
                  Expanded(
                    child: Info(
                      label: 'Sessions'.i18n,
                      loading: loading,
                      text: monthSummary?.sessions.toString() ?? '--',
                      isRate: false,
                      currencyText: '',
                    ),
                  ),
                  const VerticalDivider(thickness: 1.5),
                  Expanded(
                    child: Info(
                      label: 'Time'.i18n,
                      loading: loading,
                      text: monthSummary?.duration.formatHmShrink ?? '--',
                      isRate: false,
                      currencyText: '',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              itemCount: listWageDuration.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                String currency = listCurrency.elementAt(index);

                WageAndDuration wd = listWageDuration.elementAt(index);

                return Container(
                  height: 44,
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Info(
                          label: 'Rate'.i18n,
                          loading: loading,
                          text: wd.rateHour,
                          isRate: true,
                          currencyText: ' $currency',
                        ),
                      ),
                      const VerticalDivider(thickness: 1.5),
                      Expanded(
                        child: Info(
                          label: 'Bonus'.i18n,
                          loading: loading,
                          text: wd.bonus,
                          isRate: true,
                          currencyText: ' $currency',
                        ),
                      ),
                      const VerticalDivider(thickness: 1.5),
                      Expanded(
                        child: Info(
                          label: 'Wage'.i18n,
                          loading: loading,
                          text: wd.wage,
                          isRate: true,
                          currencyText: ' $currency',
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({
    Key? key,
    required this.label,
    required this.text,
    required this.currencyText,
    required this.loading,
    required this.isRate,
  }) : super(key: key);

  final String label;
  final String text;
  final String currencyText;
  final bool loading;
  final bool isRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            color: AppColors.color3,
          ),
        ),
        loading
            ? SpinKitCircle(
                color: Theme.of(context).primaryColor,
                size: 16.8,
              )
            : RichText(
                text: new TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: isRate ? 12 : 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: text),
                    if (isRate)
                      new TextSpan(
                          text: currencyText,
                          style: new TextStyle(color: AppColors.color3, fontSize: 10)),
                  ],
                ),
              )
      ],
    );
  }
}
