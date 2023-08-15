import 'package:staffmonitor/model/calendar_note.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';

import '../task.i18n.dart';

class NoteAuthorAndDateWidget extends StatelessWidget {
  const NoteAuthorAndDateWidget(this.calendarNote);

  final CalendarNote calendarNote;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          calendarNote.author ?? '',
          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: Text(
            calendarNote.createdAt?.format('MM-dd-yyyy HH:mm'.i18n) ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
