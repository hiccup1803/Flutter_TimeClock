import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/admin_task_file.dart';
import 'package:staffmonitor/utils/time_utils.dart';

import 'converter/json_date_time_converter.dart';

part 'admin_task_file_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-task-files')
abstract class AdminTaskFileService extends ChopperService {
  final _jsonDateTimeConverter = JsonDateTimeConverter();

  @Delete(path: '{id}')
  Future<Response<dynamic>> deleteFile(@Path('id') int? id);

  @Get(path: '{id}')
  Future<Response<AdminTaskFile>> getFile(@Path('id') int id);

  @Put(
    path: '{id}',
  )
  Future<Response<AdminTaskFile>> updateFile(
    @Path() int? id,
    @Body() ApiTaskFile body,
  );

  @Get()
  Future<Response<List<AdminTaskFile>>> getTaskFiles({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 25,
    @Body() body,
  });

  Future<Response<List<AdminTaskFile>>> getSortedFiles({
    int? page,
    int? perPage,
    required int uploaderId,
    required int taskProjectId,
    required DateTime after,
    required DateTime before,
  }) {
    return getTaskFiles(
      perPage: perPage ?? 25,
      page: page ?? 1,
      body: {
        'page': page ?? 1,
        'per-page': perPage ?? 25,
        'sort': '-createdAt',
        if (uploaderId > 0 ||
            taskProjectId > 0 ||
            after != DateTime.now().firstDayOfMonth && before != DateTime.now().lastDayOfMonth)
          'filter': {
            if (uploaderId > 0) 'uploaderId': uploaderId,
            if (taskProjectId > 0) 'projectId': taskProjectId,
            if (after != DateTime.now().firstDayOfMonth && before != DateTime.now().lastDayOfMonth)
              'createdAt': {
                'gte': _jsonDateTimeConverter.toJson(after),
                'lt': _jsonDateTimeConverter.toJson(before),
              },
          }
      },
    );
  }

  static AdminTaskFileService create([ChopperClient? client]) => _$AdminTaskFileService(client);
}
