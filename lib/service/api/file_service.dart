import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/app_file.dart';

part 'file_service.chopper.dart';

@ChopperApi(baseUrl: 'files')
abstract class FileService extends ChopperService {
  @Delete(path: '{id}')
  Future<Response<dynamic>> deleteFile(@Path('id') int? id);

  @Get(path: '{id}')
  Future<Response<AppFile>> getFile(@Path('id') int id);

  @Get()
  Future<Response<List<AppFile>>> getFiles();


  static FileService create([ChopperClient? client]) => _$FileService(client);
}
