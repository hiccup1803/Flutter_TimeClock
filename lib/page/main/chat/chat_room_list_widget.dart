import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/chat/chat_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_participants.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/main/chat/chat_room_list_widget.i18n.dart';
import 'package:staffmonitor/utils/time_utils.dart';

import '../../../bloc/main/main_cubit.dart';
import '../../base_page.dart';

class ChatRoomListPage extends BasePageWidget {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'room');

  static const String MAIN_CUBIT_KEY = 'mainCubit';

  ChatCubit chatCubit = ChatCubit(injector.chatRepository)..init(true);

  static Map<String, dynamic> buildArgs(MainCubit? mainCubit) => {
        MAIN_CUBIT_KEY: mainCubit,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    // TODO: implement buildSafe
    final args = readArgs(context)!;
    MainCubit? mainCubit = args[MAIN_CUBIT_KEY];

    final theme = Theme.of(context);
    return BlocProvider<ChatCubit>.value(
      value: chatCubit,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leadingWidth: 50,
          titleSpacing: 0,
          title: Text(
            'Chat'.i18n,
            style: theme.textTheme.headline4,
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              bool loading = true;
              List<ChatRoom> chatRoomsList = List.empty();
              AppError? error;
              if (state is ChatReady) {
                loading = false;
                chatRoomsList = state.chatList;

                if (mainCubit != null) {
                  mainCubit.updateChatRooms(profile!, force: true);
                }
              }

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 4,
                    child: loading ? LinearProgressIndicator() : null,
                  ),
                  if (chatRoomsList.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatRoomsList.length,
                        itemBuilder: (context, index) {
                          final chatRoom = chatRoomsList[index];

                          return ChatRoomItemWidget(
                            chatCubit,
                            chatRoom,
                            profile,
                          );
                        },
                      ),
                    ),
                  if (chatRoomsList.isEmpty && loading)
                    Expanded(
                        child: Center(child: Text('Loading'.i18n, style: TextStyle(fontSize: 16)))),
                  if (chatRoomsList.isEmpty && !loading && error == null)
                    Expanded(
                        child: Center(
                            child: Text(
                      'No chat rooms found'.i18n,
                      style: TextStyle(fontSize: 16),
                    ))),
                  if (chatRoomsList.isEmpty && !loading && error != null)
                    Expanded(
                      child: Center(
                        child: Text(
                          error.formatted() ?? 'Error'.i18n,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: CreateChatFab(chatCubit),
      ),
    );
  }
}

class CreateChatFab extends StatelessWidget {
  CreateChatFab(this.chatCubit);

  final ChatCubit chatCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        List<ChatRoom> chatRoomsList = List.empty();
        if (state is ChatReady) {
          chatRoomsList = state.chatList;
        }

        return FloatingActionButton(
          onPressed: () {
            Dijkstra.openChatUserPage(
              chatCubit,
              chatRoomsList,
              onChanged: ([chatRom]) {},
            );
          },
          child: Icon(Icons.chat),
        );
      },
    );
  }
}

class ChatRoomItemWidget extends StatelessWidget {
  const ChatRoomItemWidget(this.chatCubit, this.mChatRoom, this.profile);

  final ChatRoom mChatRoom;
  final Profile? profile;
  final ChatCubit chatCubit;

  String _formattedDate(DateTime date) {
    if (date.isToday) {
      return DateTimeUtils.getTimeAmPm(date);
    } else if (date.add(Duration(days: 1)).isToday) {
      return 'Yesterday'.i18n;
    }
    return date.format();
  }

  bool isNewMessage(ChatRoom mChatRoom, Profile? profile) {
    var list = mChatRoom.participants!.where((element) => element.userId == profile!.id).toList();
    if (list.isNotEmpty) return list.elementAt(0).newMessage == 0 ? false : true;
    return false;
  }

  String? _getChatRoomName(ChatRoom mChatRoom, Profile? profile) {
    if (mChatRoom.isGroup) {
      return mChatRoom.name;
    } else if (mChatRoom.participants != null && mChatRoom.participants!.length > 1) {
      ChatParticipants chatParticipants1 = mChatRoom.participants!.elementAt(0);
      ChatParticipants chatParticipants2 = mChatRoom.participants!.elementAt(1);

      if (profile?.id == chatParticipants1.userId) {
        return chatParticipants2.userName;
      } else {
        return chatParticipants1.userName;
      }
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                onTap: () {
                  if (mChatRoom.isGroup) {
                    Dijkstra.openChatMessagesPage(
                      chatCubit,
                      true,
                      mChatRoom.name,
                      chatRoom: mChatRoom,
                    );
                  } else {
                    ChatParticipants chatUser1 = mChatRoom.participants!.elementAt(0);
                    ChatParticipants chatUser2 = mChatRoom.participants!.elementAt(1);

                    String? toUserName;

                    if (profile!.id == chatUser1.userId) {
                      toUserName = chatUser2.userName!;
                    } else {
                      toUserName = chatUser1.userName!;
                    }

                    Dijkstra.openChatMessagesPage(
                      chatCubit,
                      false,
                      toUserName,
                      chatRoom: mChatRoom,
                    );
                  }
                },
                leading: mChatRoom.isGroup
                    ? Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.group),
                          ),
                          if (isNewMessage(mChatRoom, profile))
                            Container(
                              margin: EdgeInsets.only(top: 32),
                              alignment: Alignment.bottomRight,
                              width: 16,
                              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            )
                        ],
                      )
                    : Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: Image.asset(
                              'assets/person.jpg',
                              fit: BoxFit.cover,
                            ).image,
                          ),
                          if (isNewMessage(mChatRoom, profile))
                            Container(
                              margin: EdgeInsets.only(top: 32),
                              alignment: Alignment.bottomRight,
                              width: 16,
                              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            )
                        ],
                      ),
                title: Text(
                  _getChatRoomName(mChatRoom, profile) ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'last message'.i18n,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formattedDate(mChatRoom.latestMessageAt ?? mChatRoom.createdAt!),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
