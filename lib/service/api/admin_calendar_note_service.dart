import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/calendar_note.dart';
import 'package:staffmonitor/model/calendar_task.dart';

part 'admin_calendar_note_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-task-notes')
abstract class AdminCalendarNoteService extends ChopperService {
  @Get()
  Future<Response<List<CalendarTask>>> getTasks();

  static AdminCalendarNoteService create([ChopperClient? client]) =>
      _$AdminCalendarNoteService(client);

  @Post(headers: {'Content-Type': 'application/json'})
  Future<Response<CalendarNote>> _saveNotes(@Body() body);

  Future<Response<CalendarNote>> saveNotes(int taskId, String note) =>
      _saveNotes({'taskId': taskId, 'note': note});
}
