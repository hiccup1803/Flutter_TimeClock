import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/calendar_note.dart';
import 'package:staffmonitor/model/calendar_task.dart';

part 'calendar_note_service.chopper.dart';

@ChopperApi(baseUrl: 'task-notes')
abstract class CalendarNoteService extends ChopperService {
  @Get()
  Future<Response<List<CalendarTask>>> getTasks();

  static CalendarNoteService create([ChopperClient? client]) => _$CalendarNoteService(client);

  @Post(headers: {'Content-Type': 'application/json'})
  Future<Response<CalendarNote>> _saveNotes(@Body() body);

  Future<Response<CalendarNote>> saveNotes(int taskId, String note) =>
      _saveNotes({'taskId': taskId, 'note': note});
}
