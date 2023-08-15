import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/widget/count_time_widget.dart';

import '../../../model/session_break.dart';
import 'my_start_stop.i18n.dart';

class BreakTile extends StatelessWidget {
  const BreakTile({Key? key, required this.sessionBreak}) : super(key: key);

  final SessionBreak sessionBreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 10, ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).textTheme.headline5!.color,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).textTheme.headline3!.color!.withOpacity(0.4),
            offset: const Offset(0.0, 1.0),
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (sessionBreak.end == null)
                  CountTimeWidget(
                    startTime: sessionBreak.start!,
                    format: DurationFormat.MS,
                    builder: (context, text) => Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headline1!.color,
                      ),
                    ),
                  ),
                if (sessionBreak.end != null)
                  Text(
                    sessionBreak.duration.inMinutes < 1
                        ? '<1'
                        : NumberFormat('0').format(sessionBreak.duration.inMinutes),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headline1!.color,
                    ),
                  ),
                Text(
                  'min',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headline1!.color,
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(width: 25),
          Expanded(
            flex: 8,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'Started at'.i18n}:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${'Ended at'.i18n}:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionBreak.start!.format('d MMM, yyyy HH:mm:ss'),
                      // DateFormat.yMMMd().add_Hms().format(sessionBreak.start!),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headline1!.color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      sessionBreak.end?.format('d MMM, yyyy HH:mm:ss') ?? '-',
                      // DateFormat.yMMMd().add_Hms().format(sessionBreak.end),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headline1!.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
