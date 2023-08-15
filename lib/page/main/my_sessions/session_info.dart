import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import 'my_sessions.i18n.dart';

class SessionInfo<T extends Session> extends StatelessWidget {
  const SessionInfo({
    Key? key,
    required this.session,
    this.userWithId,
    this.onTap,
  }) : super(key: key);

  final T session;
  final Profile? Function(int id)? userWithId;
  final void Function()? onTap;

  String? get userName => userWithId?.call(session is AdminSession ? (session as AdminSession).userId : -1)?.name;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      onTap: onTap == null ? null : () => Future.delayed(Duration(milliseconds: 300), onTap),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName ??
                        '${session.clockIn?.format('HH:mm')} - ${session.clockOut != null ? session.clockOut?.format('HH:mm') : 'unfinished'.i18n}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.color1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Project'.i18n,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.color3,
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: session.project?.color ?? Colors.black87),
                          color: session.project?.color ?? Colors.white,
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          session.project?.name ?? '--',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!session.verified) Icon(Icons.info_rounded, size: 24, color: Colors.red),
            SizedBox(width: 16),
            Column(
              children: [
                Text(
                  '${session.totalWage == 'null' ? '' : session.totalWage} ${session.rateCurrency ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  session.duration?.formatHmShrink ?? '--',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.color1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
