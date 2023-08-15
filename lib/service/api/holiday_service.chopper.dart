// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$HolidayService extends HolidayService {
  _$HolidayService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = HolidayService;

  @override
  Future<Response<List<Holiday>>> getHolidays() {
    final Uri $url = Uri.parse('holidays');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<Holiday>, Holiday>($request);
  }
}
