import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/model/employee_summary.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

class UserMonthSummaryWidget extends StatelessWidget {
  final EmployeeSummary _employeeSummary;
  final Profile? Function(int id)? userWithId;
  final Function()? onTap;

  const UserMonthSummaryWidget(this._employeeSummary, {this.userWithId, this.onTap});

  int get currencyCount => _employeeSummary.currencyRateWageMap.keys.length;

  bool get multipleCurrencies => currencyCount > 1;

  String get singleCurrency {
    String topCurrency = _employeeSummary.currencyRateWageMap.keys.toList()[0];
    if (currencyCount == 1) {
      return topCurrency;
    }
    double topWage = 0;
    for (String currency in _employeeSummary.currencyRateWageMap.keys) {
      double wage = _employeeSummary.currencyRateWageMap[currency]?.values
              .reduce((value, element) => value + element)
              .wageDouble ??
          0;
      if (wage > topWage) {
        topCurrency = currency;
      }
    }
    return topCurrency;
  }

  String get singleWage =>
      _employeeSummary.currencyRateWageMap[singleCurrency]?.values
          .reduce((value, element) => value + element)
          .wage ??
      '--';

  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userWithId?.call(_employeeSummary.userId)?.name ?? '???',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.color1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Worked: ',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.color3,
                          ),
                          children: [
                            TextSpan(
                              text: _employeeSummary.duration.formatHmShrink,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Sessions: ',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.color3,
                          ),
                          children: [
                            TextSpan(
                              text: _employeeSummary.sessions.length.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // if (!employ.valide) Icon(Icons.info_rounded, size: 24.sp, color: Colors.red),
            SizedBox(width: 10),
            Column(
              children: [
                Text(
                  '${singleWage == '0.00' ? '' : singleWage} $singleCurrency',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  '${'Wage'}${multipleCurrencies ? ' (+ ${currencyCount - 1})' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.color3,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
