import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/chat_user.dart';

part 'chat_users_service.chopper.dart';

@ChopperApi(baseUrl: 'chat-users')
abstract class ChatUserService extends ChopperService {
  @Get()
  Future<Response<List<ChatUser>>> getAvailableChatUser({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 25,
    @Body() body,
  });

  Future<Response<List<ChatUser>>> getFilteredAvailableChatUser({
    int? page,
    int? perPage,
  }) {
    return getAvailableChatUser(
      page: page ?? 1,
      perPage: perPage ?? 25,
      body: {
        'page': page ?? 1,
        'per-page': perPage ?? 25,
        'sort': 'name',
      },
    );
  }

  static ChatUserService create([ChopperClient? client]) => _$ChatUserService(client);
}
