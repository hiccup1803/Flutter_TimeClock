import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/admin_project.dart';

part 'admin_projects_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-projects')
abstract class AdminProjectsService extends ChopperService {
  static AdminProjectsService create([ChopperClient? client]) => _$AdminProjectsService(client);

  @Delete(path: '{id}')
  Future<Response> deleteProject(@Path() int id);

  @Get(path: '{id}')
  Future<Response<AdminProject>> getProject(@Path() int id);

  @Put(path: '{id}')
  Future<Response<AdminProject>> putProject(@Path() int id, @Body() body);

  @Post()
  Future<Response<AdminProject>> postProject(@Body() body);

  @Get()
  Future<Response<List<AdminProject>>> getProjects({
    @Query() int page = 1,
    @Query('per-page') int perPage = 50,
  });

  @Get()
  Future<Response<List<AdminProject>>> getAllProjects();

  @Put(path: 'archive/{id}', optionalBody: true)
  Future<Response<AdminProject>> archiveProject(@Path() int id);

  @Put(path: 'bring-back/{id}', optionalBody: true)
  Future<Response<AdminProject>> bringBackProject(@Path() int id);
}
