import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:staffmonitor/bloc/main/calendars/my_calendars_cubit.dart';
import 'package:staffmonitor/page/base_page.dart';

import '../../../utils/ui_utils.dart';
import '../../../widget/dialog/dialogs.i18n.dart';

class CalendarFilterWidget extends StatefulWidget {
  CalendarFilterWidget({required this.filterValue, Key? key}) : super(key: key);
  final List<bool> filterValue;

  @override
  _CalendarFilterWidgetState createState() => _CalendarFilterWidgetState();
}

class _CalendarFilterWidgetState extends State<CalendarFilterWidget> {
  bool showTask = true;
  bool showOffTime = false;
  bool showSession = false;

  bool _enable = false;

  @override
  void initState() {
    super.initState();
    showTask = widget.filterValue[0];
    showSession = widget.filterValue[1];
    showOffTime = widget.filterValue[2];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        margin: EdgeInsets.all(3.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
        width: MediaQuery.of(context).size.width * .9,
        height: MediaQuery.of(context).size.height * .4,
        padding: EdgeInsets.all(5),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                      ),
                    ),
                    Text(
                      'Filter'.i18n,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    InkWell(
                      onTap: showTask || showSession || showOffTime || _enable
                          ? () {
                              setState(() {
                                _enable = false;
                                showTask = false;
                                showSession = false;
                                showOffTime = false;
                                BlocProvider.of<MyCalendarsCubit>(context)
                                    .updateFilter([showTask, showSession, showOffTime]);
                              });
                            }
                          : null,
                      child: Text(
                        'Clear'.i18n,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: showTask || showSession || showOffTime || _enable
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: showTask || showSession || showOffTime || _enable
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.1,
                color: Colors.grey,
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  FlutterSwitch(
                    width: 35.0,
                    height: 20.0,
                    valueFontSize: 15.0,
                    toggleSize: 15.0,
                    value: showTask,
                    borderRadius: 20.0,
                    padding: 3.0,
                    showOnOff: false,
                    onToggle: (val) {
                      setState(() {
                        showTask = val;
                      });
                      BlocProvider.of<MyCalendarsCubit>(context)
                          .updateFilter([showTask, showSession, showOffTime]);
                    },
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Show Tasks'.i18n,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  FlutterSwitch(
                    width: 35.0,
                    height: 20.0,
                    valueFontSize: 15.0,
                    toggleSize: 15.0,
                    value: showSession,
                    borderRadius: 20.0,
                    padding: 3.0,
                    showOnOff: false,
                    onToggle: (val) {
                      setState(() {
                        showSession = val;
                      });
                      BlocProvider.of<MyCalendarsCubit>(context)
                          .updateFilter([showTask, showSession, showOffTime]);
                    },
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Show Sessions'.i18n,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  FlutterSwitch(
                    width: 35.0,
                    height: 20.0,
                    valueFontSize: 15.0,
                    toggleSize: 15.0,
                    value: showOffTime,
                    borderRadius: 20.0,
                    padding: 3.0,
                    showOnOff: false,
                    onToggle: (val) {
                      setState(() {
                        showOffTime = val;
                      });
                      BlocProvider.of<MyCalendarsCubit>(context)
                          .updateFilter([showTask, showSession, showOffTime]);
                    },
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Show Off-time'.i18n,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: AppColors.darkGreen),
                  onPressed: showTask || showSession || showOffTime || _enable
                      ? () {
                          BlocProvider.of<MyCalendarsCubit>(context)
                              .updateFilter([showTask, showSession, showOffTime]);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(
                    'Apply'.i18n,
                    softWrap: true,
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
