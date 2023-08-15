import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:staffmonitor/bloc/main/chat/chat_cubit.dart';
import 'package:staffmonitor/bloc/main/chat/messages/chat_messages_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_message.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/profile.dart';

import '../../../model/chat_participants.dart';
import '../../base_page.dart';

class ChatMessagesPage extends BasePageWidget {
  static const String CHAT_USER_KEY = 'chatUser';
  static const String CHAT_ROOM_KEY = 'chatRoom';
  static const String CHAT_IS_GROUP = 'isGroup';
  static const String CHAT_ROOM_NAME = 'roomName';
  static const String CHAT_CUBIT_KEY = 'chatCubit';
  static const int CHAT_CHANGED = 101;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'chat');

  static Map<String, dynamic> buildArgs(ChatCubit chatCubit, bool isGroup, String toUserName,
          {ChatUser? chatUser, ChatRoom? chatRoom}) =>
      {
        CHAT_IS_GROUP: isGroup,
        CHAT_ROOM_NAME: toUserName,
        CHAT_USER_KEY: chatUser,
        CHAT_ROOM_KEY: chatRoom,
        CHAT_CUBIT_KEY: chatCubit,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    final theme = Theme.of(context);
    ChatUser? paramChatUser = args[CHAT_USER_KEY];
    ChatRoom? paramChatRoom = args[CHAT_ROOM_KEY];
    bool isGroup = args[CHAT_IS_GROUP] ?? false;
    String roomName = args[CHAT_ROOM_NAME];
    ChatCubit chatCubit = args[CHAT_CUBIT_KEY];

    types.User _user;

    if (paramChatRoom == null) {
      _user = types.User(id: profile!.id.toString(), firstName: profile.name.toString());
    } else {
      _user = paramChatRoom.global == 1
          ? types.User(id: profile!.id.toString(), firstName: profile.name.toString())
          : types.User(id: profile!.id.toString(), firstName: profile.name.toString());
    }

    return BlocProvider(
      create: (context) {
        return ChatMessagesCubit(injector.chatRepository, injector.usersRepository)
          ..init(isGroup, profile, paramChatUser: paramChatUser, chatRoom: paramChatRoom);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leadingWidth: 50,
          titleSpacing: 0,
          title: Text(
            roomName,
            style: theme.textTheme.subtitle1,
          ),
          actions: [
            isGroup
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        onTap: () {
                          Dijkstra.openGroupDetailsPage(paramChatRoom);
                        },
                        child: Icon(
                          Icons.info,
                          color: Colors.black54,
                          size: 28,
                        )),
                  )
                : Container(),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: WillPopScope(
            onWillPop: () async {
              chatCubit.init(true);
              injector.navigationService.pop();
              return true;
            },
            child: MessageWidget(profile, isGroup, paramChatRoom?.global, _user),
          ),
        ),
      ),
    );
  }
}

class MessageWidget extends StatefulWidget {
  MessageWidget(this.profile, this.isGroup, this.isGlobal, this.mUser);

  final Profile? profile;
  final types.User mUser;
  final bool isGroup;
  int? isGlobal = 0;

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  List<types.Message> _messagesList = [];
  List<ChatMessage> chatMessageList = [];
  bool isMsgSending = false;

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void _handleSendPressed(types.PartialText message) {
    isMsgSending = true;
    final textMessage = types.TextMessage(
        author: types.User(
          id: widget.profile!.id.toString(),
        ),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: message.text,
        status: types.Status.sending);
    setState(() {
      _messagesList.insert(0, textMessage);
      BlocProvider.of<ChatMessagesCubit>(context).sendMessage(message.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    ChatMessagesCubit chatCubit = BlocProvider.of<ChatMessagesCubit>(context);

    ChatParticipants? _userName(int? id) {
      if (chatCubit.listUsers.isNotEmpty) {
        return chatCubit.listUsers.firstWhereOrNull(
          (element) => element.userId == id,
        );
      } else {
        return null;
      }
    }

    return BlocBuilder<ChatMessagesCubit, ChatMessagesState>(builder: (context, state) {
      bool loading = true;

      if (state is ChatMessagesReady) {
        loading = state.chatList.inProgress == true;
        chatMessageList = state.chatList.value ?? List.empty();

        if (chatMessageList.isNotEmpty && !isMsgSending) {
          _messagesList = chatMessageList
              .map((e) => types.TextMessage(
                  author: types.User(
                      id: e.userId.toString(),
                      firstName: _userName(e.userId)?.userName == null
                          ? ''
                          : _userName(e.userId)?.userName,
                      lastName: widget.isGlobal == 1
                          ? _userName(e.userId)?.userCompany == null
                              ? ''
                              : ' [${_userName(e.userId)?.userCompany}]'
                          : ''),
                  id: e.id.toString(),
                  text: e.message!,
                  roomId: e.roomId!.toString(),
                  //status: types.Status.sent,
                  createdAt: e.createdAt!.millisecondsSinceEpoch))
              .toList();
        } else {
          isMsgSending = false;
        }
      }

      return loading
          ? LinearProgressIndicator()
          : Chat(
              messages: _messagesList,
              onSendPressed: _handleSendPressed,
              user: widget.mUser,
              showUserAvatars: true,
              showUserNames: widget.isGroup ? true : false,
              dateFormat: DateFormat.MMMd(),
              timeFormat: DateFormat.jm(),
              theme: const DefaultChatTheme(
                inputTextStyle: TextStyle(fontSize: 14),
                receivedMessageBodyTextStyle: TextStyle(fontSize: 14),
                receivedMessageLinkTitleTextStyle: TextStyle(fontSize: 14),
                sentMessageBodyTextStyle: TextStyle(fontSize: 14),
                sentMessageLinkTitleTextStyle: TextStyle(fontSize: 14),
              ),
            );
    });
  }
}
