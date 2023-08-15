// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$ChatService extends ChatService {
  _$ChatService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ChatService;

  @override
  Future<Response<ChatRoom>> getChatRoom(int id) {
    final Uri $url = Uri.parse('chat/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<ChatRoom, ChatRoom>($request);
  }

  @override
  Future<Response<List<ChatRoom>>> getChatRooms({
    int page = 1,
    int perPage = 25,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('chat');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per-page': perPage,
    };
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<List<ChatRoom>, ChatRoom>($request);
  }

  @override
  Future<Response<ChatRoom>> createChatRoom(ApiChatRoom body) {
    final Uri $url = Uri.parse('chat');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<ChatRoom, ChatRoom>($request);
  }

  @override
  Future<Response<List<ChatMessage>>> getChatMessages(
    int roomID, {
    int page = 1,
    int perPage = 25,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('chat/${roomID}/messages');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per-page': perPage,
    };
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<List<ChatMessage>, ChatMessage>($request);
  }

  @override
  Future<Response<ChatMessage>> createChatMessage(
    int roomID,
    ApiChatMessage body,
  ) {
    final Uri $url = Uri.parse('chat/${roomID}/messages');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<ChatMessage, ChatMessage>($request);
  }

  @override
  Future<Response<List<ChatParticipants>>> getChatParticipant(
    int roomID, {
    int page = 1,
    int perPage = 25,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('chat/${roomID}/participants');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per-page': perPage,
    };
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<List<ChatParticipants>, ChatParticipants>($request);
  }

  @override
  Future<Response<ChatParticipants>> createChatParticipant(
    int roomID,
    ApiChatParticipant body,
  ) {
    final Uri $url = Uri.parse('chat/${roomID}/participants');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<ChatParticipants, ChatParticipants>($request);
  }

  @override
  Future<Response<dynamic>> deleteChatParticipant(
    int? roomId,
    int? id,
  ) {
    final Uri $url = Uri.parse('chat/${roomId}/participants/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteChatRoom(int? id) {
    final Uri $url = Uri.parse('chat/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
