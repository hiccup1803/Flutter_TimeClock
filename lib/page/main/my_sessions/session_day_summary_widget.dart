import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/sessions_day_summary.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import '../../../model/session.dart';
import 'session_info.dart';

class SessionDaySummaryWidget<T extends Session> extends StatefulWidget {
  const SessionDaySummaryWidget(this.summary, {this.userWithId, required this.onSessionTap});

  final SessionsDaySummary<T> summary;
  final Profile? Function(int id)? userWithId;
  final void Function(dynamic session) onSessionTap;

  @override
  State<SessionDaySummaryWidget> createState() => _SessionDaySummaryWidgetState<T>();
}

class _SessionDaySummaryWidgetState<T extends Session> extends State<SessionDaySummaryWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // if (_expanded) const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.summary.day?.format('d/MM/yyyy') ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.color1,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.summary.count.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.summary.time.formatHmShrink,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.color1,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 24,
                    color: AppColors.color1,
                  ),
                ],
              ),
            ),
            if (_expanded)
              Divider(
                thickness: 1.5,
                indent: 16,
                endIndent: 16,
                color: AppColors.color4,
              ),
            if (_expanded) const SizedBox(height: 2),
            if (_expanded)
              ListView.separated(
                itemCount: widget.summary.sessions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return SessionInfo<T>(
                    session: widget.summary.sessions[index] as T,
                    userWithId: widget.userWithId,
                    onTap: () => widget.onSessionTap.call(widget.summary.sessions[index] as T),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  thickness: 1.5,
                  height: 1.5,
                  color: AppColors.color4,
                ),
              ),
            // if (_expanded) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}