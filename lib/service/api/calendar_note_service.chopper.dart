// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_note_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$CalendarNoteService extends CalendarNoteService {
  _$CalendarNoteService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = CalendarNoteService;

  @override
  Future<Response<List<CalendarTask>>> getTasks() {
    final Uri $url = Uri.parse('task-notes');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<CalendarTask>, CalendarTask>($request);
  }

  @override
  Future<Response<CalendarNote>> _saveNotes(dynamic body) {
    final Uri $url = Uri.parse('task-notes');
    final Map<String, String> $headers = {
      'Content-Type': 'application/json',
    };
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<CalendarNote, CalendarNote>($request);
  }
}
