import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/session_wage_duration.dart';
import 'package:staffmonitor/page/main/my_sessions/month_statistics_card.dart';
import 'package:staffmonitor/page/main/my_sessions/session_info.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import 'admin_sessions_widget.i18n.dart';

class EmployeeSessionsBottomSheet extends StatefulWidget {
  static Future show(BuildContext context, List<AdminSession> sessionList, String userName,
      {required Function([dynamic]) onChanged, required Function([dynamic]) onDeleted}) {
    return showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (context) => EmployeeSessionsBottomSheet(
              sessionList: sessionList,
              name: userName,
              onChanged: onChanged,
              onDeleted: onDeleted,
            ));
  }

  const EmployeeSessionsBottomSheet({
    Key? key,
    required this.sessionList,
    required this.name,
    required this.onChanged,
    required this.onDeleted,
  }) : super(key: key);

  final List<AdminSession> sessionList;
  final String name;
  final Function([dynamic]) onChanged;
  final Function([dynamic]) onDeleted;

  @override
  State<EmployeeSessionsBottomSheet> createState() => _EmployeeSessionsBottomSheetState();
}

class _EmployeeSessionsBottomSheetState extends State<EmployeeSessionsBottomSheet> {
  List<AdminSession> _sessionList = [];

  String rateCurrency = '';
  Map<String, WageAndDuration> mappedSessionWageCurrency = {};

  @override
  void initState() {
    super.initState();
    _sessionList = widget.sessionList;

    _sessionList.forEach((session) {
      rateCurrency = session.rateCurrency ?? '';

      if (mappedSessionWageCurrency[rateCurrency.toUpperCase()] == null) {
        mappedSessionWageCurrency[rateCurrency.toUpperCase()] = WageAndDuration().add(session);
      } else {
        mappedSessionWageCurrency[rateCurrency.toUpperCase()] =
            mappedSessionWageCurrency[rateCurrency.toUpperCase()]!.add(session);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<WageAndDuration> listWageDuration = mappedSessionWageCurrency.values.toList();
    List<String> listCurrency = mappedSessionWageCurrency.keys.toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 10),
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.color2,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${widget.name} ${'Sessions'.i18n}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.color1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Check All Employee Sessions'.i18n,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.color3,
              ),
            ),
          ),
          SizedBox(height: 16),
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
                        label: 'Hours'.i18n,
                        loading: false,
                        text:
                            "${wd.duration.inHours}:${wd.duration.inMinutes.remainder(60)}:${(wd.duration.inSeconds.remainder(60))}",
                        isRate: false,
                        currencyText: '',
                      ),
                    ),
                    const VerticalDivider(thickness: 1.5),
                    Expanded(
                      child: Info(
                        label: 'Rate'.i18n,
                        loading: false,
                        text: wd.rateHour,
                        isRate: true,
                        currencyText: ' $currency',
                      ),
                    ),
                    const VerticalDivider(thickness: 1.5),
                    Expanded(
                      child: Info(
                        label: 'Bonus'.i18n,
                        loading: false,
                        text: wd.bonus,
                        isRate: true,
                        currencyText: ' $currency',
                      ),
                    ),
                    const VerticalDivider(thickness: 1.5),
                    Expanded(
                      child: Info(
                        label: 'Wage'.i18n,
                        loading: false,
                        text: wd.wage,
                        isRate: true,
                        currencyText: ' $currency',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: 15),
              itemCount: _sessionList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => SessionInfo<AdminSession>(
                session: _sessionList[index],
                onTap: () => Dijkstra.editAdminSession(
                  _sessionList[index],
                  onChanged: ([session]) {
                    widget.onChanged.call(session);
                    if (session != null) {
                      setState(() {
                        _sessionList[index] = session;
                      });
                    }
                  },
                  onDeleted: ([session]) {
                    widget.onDeleted.call(session);
                    setState(() {
                      _sessionList.removeAt(index);
                      if (_sessionList.isEmpty) {
                        Navigator.of(context).maybePop();
                      }
                    });
                  },
                ),
              ),
              separatorBuilder: (context, index) => Divider(
                thickness: 1.5,
                height: 1.5,
                indent: 16,
                endIndent: 16,
                color: AppColors.color4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
