import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/utils/time_utils.dart';

import 'converter/json_date_time_converter.dart';

part 'admin_file_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-files')
abstract class AdminFileService extends ChopperService {
  final _jsonDateTimeConverter = JsonDateTimeConverter();

  @Delete(path: '{id}')
  Future<Response<dynamic>> deleteFile(@Path('id') int? id);

  @Get(path: '{id}')
  Future<Response<AdminSessionFile>> getFile(@Path('id') int id);

  @Put(
    path: '{id}',
  )
  Future<Response<AdminSessionFile>> updateFile(
    @Path() int? id,
    @Body() ApiSessionFile body,
  );

  @Get()
  Future<Response<List<AdminSessionFile>>> getFiles({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 25,
    @Body() body,
  });

  Future<Response<List<AdminSessionFile>>> getSortedFiles({
    int? page,
    int? perPage,
    required int uploaderId,
    required int sessionProjectId,
    required DateTime after,
    required DateTime before,
  }) {
    return getFiles(
      perPage: perPage ?? 25,
      page: page ?? 1,
      body: {
          'page': page ?? 1,
          'per-page': perPage ?? 25,
          'sort': '-createdAt',
        if (uploaderId > 0 ||
            sessionProjectId > 0 ||
            after != DateTime.now().firstDayOfMonth && before != DateTime.now().lastDayOfMonth)
          'filter': {
            if (uploaderId > 0) 'uploaderId': uploaderId,
            if (sessionProjectId > 0) 'projectId': sessionProjectId,
            if (after != DateTime.now().firstDayOfMonth && before != DateTime.now().lastDayOfMonth)
              'createdAt': {
                'gte': _jsonDateTimeConverter.toJson(after),
                'lt': _jsonDateTimeConverter.toJson(before),
              },
          }
      },
    );
  }

  static AdminFileService create([ChopperClient? client]) => _$AdminFileService(client);
}
