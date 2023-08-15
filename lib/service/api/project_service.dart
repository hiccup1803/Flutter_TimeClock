import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/project.dart';

part 'project_service.chopper.dart';

@ChopperApi(baseUrl: 'projects')
abstract class ProjectService extends ChopperService {
  @Get(path: '{id}')
  Future<Response<Project>> getProject(@Path('id') int id);

  @Get()
  Future<Response<List<Project>>> getProjects({
    @Query('page') int? page,
    @Query('per-page') int? perPage,
  });

  @Post()
  Future<Response<Project>> postProject(@Body() body);

  static ProjectService create([ChopperClient? client]) => _$ProjectService(client);
}
