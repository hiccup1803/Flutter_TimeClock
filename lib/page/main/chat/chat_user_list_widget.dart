import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/chat/chat_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/main/chat/chat_room_list_widget.i18n.dart';

import '../../base_page.dart';

class ChatUserListPage extends BasePageWidget {
  static const String CHAT_ROOM_KEY = 'chatRoomList';

  static const String CHAT_CUBIT_KEY = 'chatCubit';

  static Map<String, dynamic> buildArgs(ChatCubit chatCubit, List<ChatRoom> list) => {
        CHAT_ROOM_KEY: list,
        CHAT_CUBIT_KEY: chatCubit,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    final theme = Theme.of(context);
    List<ChatRoom> paramChatRoomList = args[CHAT_ROOM_KEY];
    ChatCubit chatCubit = args[CHAT_CUBIT_KEY];

    return BlocProvider<ChatCubit>(
      create: (context) => ChatCubit(
        injector.chatRepository,
      )..init(false),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 50,
          titleSpacing: 0,
          title: Text(
            'Select User'.i18n,
            style: theme.textTheme.headline4,
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              bool loading = true;
              List<ChatUser> chatUsersList = List.empty(growable: true);
              AppError? error;
              if (state is ChatUserListReady) {
                loading = state.chatUsersList.inProgress == true;
                chatUsersList = state.chatUsersList.value ?? List.empty();

                if (chatUsersList.isNotEmpty == true) {
                  if (chatUsersList.elementAt(0).id != -1 && profile!.isAdmin) {
                    chatUsersList.insert(0, new ChatUser(-1, 'New group'.i18n));
                  }
                  chatUsersList.removeWhere((item) => item.id == profile!.id);
                }

                error = state.chatUsersList.error;
              }

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 4,
                    child: loading ? LinearProgressIndicator() : null,
                  ),
                  if (chatUsersList.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatUsersList.length,
                        itemBuilder: (context, index) {
                          final chatUser = chatUsersList[index];
                          return ChatUserItemWidget(
                            index,
                            profile!.isAdmin,
                            chatUser,
                            onTap: () {
                              if (index == 0 && profile.isAdmin) {
                                if (chatUsersList.elementAt(0).id == -1) {
                                  chatUsersList.removeAt(0);
                                }
                                Dijkstra.openCreateChatGroupPage(chatCubit, chatUsersList);
                              } else {
                                String mPossibleRoom1 =
                                    chatUser.name.toString() + ' - ' + profile.name.toString();
                                String mPossibleRoom2 =
                                    profile.name.toString() + ' - ' + chatUser.name.toString();

                                ChatRoom? chatRoom;

                                paramChatRoomList.forEach((element) {
                                  if (element.name == mPossibleRoom1 ||
                                      element.name == mPossibleRoom2) {
                                    chatRoom = element;
                                  }
                                });

                                Dijkstra.openChatMessagesPage(chatCubit, false, chatUser.name,
                                    chatRoom: chatRoom, chatUser: chatUser, replace: true);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  if (chatUsersList.isEmpty && loading)
                    Expanded(child: Center(child: Text('Loading'.i18n))),
                  if (chatUsersList.isEmpty && !loading && error == null)
                    Expanded(child: Center(child: Text('No chat users found'.i18n))),
                  if (chatUsersList.isEmpty && !loading && error != null)
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
      ),
    );
  }
}

class ChatUserItemWidget extends StatelessWidget {
  const ChatUserItemWidget(this.index, this.isAdmin, this.mChatUser, {this.onTap});

  final ChatUser mChatUser;
  final int index;
  final bool isAdmin;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: ListTile(
                leading: index == 0 && isAdmin
                    ? CircleAvatar(
                        child: Icon(Icons.group),
                      )
                    : CircleAvatar(
                        backgroundImage: Image.asset(
                          'assets/person.jpg',
                          fit: BoxFit.cover,
                        ).image,
                      ),
                title: Text(
                  mChatUser.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
