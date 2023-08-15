import 'dart:async';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_message.dart';
import 'package:staffmonitor/model/chat_participants.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/service/api/chat_service.dart';
import 'package:staffmonitor/service/api/chat_users_service.dart';

class ChatRepository {
  ChatRepository(this._chatService, this._chatUserService);

  final ChatService _chatService;
  final ChatUserService _chatUserService;

  Future<ChatRoom> createChatRoom(String name, int group, List<int> users) async {
    var response = await _chatService.createChatRoom(
      ApiChatRoom.fromChatRoom(name, group, users),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<ChatRoom>> getChatRooms({int page = 1, int perPage = 25}) async {
    final response = await _chatService.getFilteredChatRooms(page: page, perPage: perPage);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<List<ChatRoom>> getAllChatRooms() async {
    late Paginated<ChatRoom> paginated;
    int page = 0;

    do {
      final result = await getChatRooms(page: ++page, perPage: 50);
      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }

  Future<Paginated<ChatMessage>> getChatMessages(int roomId, int page) async {
    final response = await _chatService.getFilteredChatMessages(roomId, page: page, perPage: 100);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<ChatMessage> createChatMessage(int roomId, String message) async {
    var response = await _chatService.createChatMessage(
      roomId,
      ApiChatMessage.fromChatMessage(roomId, message),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<ChatParticipants>> getChatParticipants(int roomId, int page) async {
    final response = await _chatService.getFilteredChatParticipant(roomId, page: page, perPage: 25);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<List<ChatParticipants>> getAllChatParticipants(int roomId) async {
    late Paginated<ChatParticipants> paginated;
    int page = 0;

    do {
      final result = await getChatParticipants(roomId, ++page);
      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }

  Future<ChatParticipants> createChatParticipant(int roomId, int userid) async {
    var response = await _chatService.createChatParticipant(
      roomId,
      ApiChatParticipant.fromChatParticipant(roomId, userid),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteChatParticipant(int roomId, int userId) async {
    final response = await _chatService.deleteChatParticipant(roomId, userId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteChatRoom(int roomId) async {
    final response = await _chatService.deleteChatRoom(roomId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<ChatUser>> getAvailableChatUser(int page) async {
    final response = await _chatUserService.getFilteredAvailableChatUser(page: page, perPage: 25);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<List<ChatUser>> getAllAvailableChatUser() async {
    late Paginated<ChatUser> paginated;
    int page = 0;

    do {
      final result = await getAvailableChatUser(++page);
      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }
}
