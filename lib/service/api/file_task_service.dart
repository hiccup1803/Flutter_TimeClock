import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/app_file.dart';

part 'file_task_service.chopper.dart';

@ChopperApi(baseUrl: 'task-files')
abstract class FileTaskService extends ChopperService {
  @Delete(path: '{id}')
  Future<Response<dynamic>> deleteFile(@Path('id') int? id);

  @Get(path: 'download/{id}')
  Future<Response<AppFile>> downloadFile(@Path('id') int id);

  static FileTaskService create([ChopperClient? client]) => _$FileTaskService(client);
}
