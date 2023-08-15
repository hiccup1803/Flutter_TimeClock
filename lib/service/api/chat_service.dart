import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_message.dart';
import 'package:staffmonitor/model/chat_participants.dart';

part 'chat_service.chopper.dart';

@ChopperApi(baseUrl: 'chat')
abstract class ChatService extends ChopperService {
  static ChatService create([ChopperClient? client]) => _$ChatService(client);

  @Get(path: '{id}')
  Future<Response<ChatRoom>> getChatRoom(@Path() int id);

  @Get()
  Future<Response<List<ChatRoom>>> getChatRooms({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 25,
    @Body() body,
  });

  Future<Response<List<ChatRoom>>> getFilteredChatRooms({
    int? page,
    int? perPage,
  }) {
    return getChatRooms(
      page: page ?? 1,
      perPage: perPage ?? 25,
      body: {
        'page': page ?? 1,
        'per-page': perPage ?? 25,
        'sort': '-latestMessageAt',
      },
    );
  }

  @Post()
  Future<Response<ChatRoom>> createChatRoom(@Body() ApiChatRoom body);

  @Get(path: '/{roomId}/messages')
  Future<Response<List<ChatMessage>>> getChatMessages(
    @Path('roomId') int roomID, {
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 25,
    @Body() body,
  });

  Future<Response<List<ChatMessage>>> getFilteredChatMessages(
    int roomID, {
    int? page,
    int? perPage,
  }) {
    return getChatMessages(
      roomID,
      page: page ?? 1,
      perPage: perPage ?? 25,
      body: {
        'page': page ?? 1,
        'per-page': perPage ?? 100,
        'sort': '-createdAt',
      },
    );
  }

  @Post(path: '/{roomId}/messages')
  Future<Response<ChatMessage>> createChatMessage(
      @Path('roomId') int roomID, @Body() ApiChatMessage body);

  @Get(path: '/{roomId}/participants')
  Future<Response<List<ChatParticipants>>> getChatParticipant(
    @Path('roomId') int roomID, {
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 25,
    @Body() body,
  });

  Future<Response<List<ChatParticipants>>> getFilteredChatParticipant(
    int roomID, {
    int? page,
    int? perPage,
  }) {
    return getChatParticipant(
      roomID,
      page: page ?? 1,
      perPage: perPage ?? 25,
      body: {
        'page': page ?? 1,
        'per-page': perPage ?? 25,
      },
    );
  }

  @Post(path: '/{roomId}/participants')
  Future<Response<ChatParticipants>> createChatParticipant(
      @Path('roomId') int roomID, @Body() ApiChatParticipant body);

  @Delete(path: '/{roomId}/participants/{id}')
  Future<Response<dynamic>> deleteChatParticipant(@Path('roomId') int? roomId, @Path('id') int? id);

  @Delete(path: '/{id}')
  Future<Response<dynamic>> deleteChatRoom(@Path('id') int? id);
}