// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_users_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$ChatUserService extends ChatUserService {
  _$ChatUserService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ChatUserService;

  @override
  Future<Response<List<ChatUser>>> getAvailableChatUser({
    int page = 1,
    int perPage = 25,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('chat-users');
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
    return client.send<List<ChatUser>, ChatUser>($request);
  }
}
