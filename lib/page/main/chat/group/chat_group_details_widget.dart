import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/chat/group/chat_group_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_participants.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/chat/chat_room_list_widget.i18n.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';
import 'package:staffmonitor/widget/dialog/select_list_dialog.dart';
import 'package:collection/collection.dart' show IterableExtension;

class ChatGroupDetailsPage extends BasePageWidget {
  static const String CHAT_ROOM_DETAIL_KEY = 'chatRoomDetail';

  static Map<String, dynamic> buildArgs(ChatRoom? chatRoom) => {
        CHAT_ROOM_DETAIL_KEY: chatRoom,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    final theme = Theme.of(context);
    ChatRoom? paramChatRoom = args[CHAT_ROOM_DETAIL_KEY];

    List<ChatParticipants> chatParticipant =
        paramChatRoom!.participants!.where((element) => element.deleted == 0).toList();

    return BlocProvider<ChatGroupCubit>(
      create: (context) => ChatGroupCubit(
        injector.chatRepository,
      )..init(profile!, paramChatRoom.id),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 54,
                child: Icon(
                  Icons.group,
                  size: 54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                paramChatRoom.name,
                style: theme.textTheme.headline5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 14),
              child: Text(
                'Group - ' + chatParticipant.length.toString() + ' participant',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
            Divider(),
            GroupParticipantWidget(profile!, paramChatRoom.global)
          ],
        ),
      ),
    );
  }
}

class GroupParticipantWidget extends StatefulWidget {
  GroupParticipantWidget(this.profile, this.isGlobal);

  final Profile profile;
  int? isGlobal = 0;

  @override
  _GroupParticipantWidgetState createState() => _GroupParticipantWidgetState();
}

class _GroupParticipantWidgetState extends State<GroupParticipantWidget> {
  bool loading = false;

  void _addParticipant(List<int> chatParticipant, List<ChatUser> chatUsersList) {
    final options =
        chatUsersList.where((element) => chatParticipant.contains(element.id) != true).toList();

    SelectListDialog.showSelectOne<ChatUser>(
      context: context,
      options: options,
      emptyBuilder: () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Every active user is already in group'.i18n),
      ),
      itemBuilder: (context, item) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: Text(item.name)),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          loading = true;
        });
        BlocProvider.of<ChatGroupCubit>(context).addChatParticipant(value.id).then((value) {
          setState(() {
            loading = false;
          });
        });
      }
    });
  }

  void _delete(String? userName, int id) {
    ConfirmDialog.show(
      context: context,
      title: Row(
        children: [
          Expanded(child: Text('Remove $userName from group?')),
        ],
      ),
    ).then((value) {
      if (value == true) {
        setState(() {
          loading = true;
        });
        BlocProvider.of<ChatGroupCubit>(context).deleteChatParticipant(id).then((value) {
          setState(() {
            loading = false;
          });
        });
      }
    });
  }

  void _exitGroup(int id) {
    ConfirmDialog.show(
      context: context,
      title: Row(
        children: [
          Expanded(child: Text('Exit group?')),
        ],
      ),
    ).then((value) {
      if (value == true) {
        setState(() {
          loading = true;
        });
        BlocProvider.of<ChatGroupCubit>(context).deleteChatParticipant(id).then((value) {
          setState(() {
            loading = false;
          });

          injector.navigationService.pop();
          injector.navigationService.pop();
          Future.delayed(Duration(seconds: 1)).then((value) => injector.navigationService.pop());
          Future.delayed(Duration(seconds: 1)).then((value) => Dijkstra.openChatRoomsPage());
        });
      }
    });
  }

  void _deleteChatRoom() {
    ConfirmDialog.show(
      context: context,
      title: Row(
        children: [
          Expanded(child: Text('Delete group!')),
        ],
      ),
      content: Text('Are you sure? You will lost all data in this room'.i18n),
    ).then((value) {
      if (value == true) {
        setState(() {
          loading = true;
        });
        BlocProvider.of<ChatGroupCubit>(context).deleteChatRoom().then((value) {
          setState(() {
            loading = false;
          });

          injector.navigationService.pop();
          injector.navigationService.pop();
          Future.delayed(Duration(seconds: 1)).then((value) => injector.navigationService.pop());
          Future.delayed(Duration(seconds: 1)).then((value) => Dijkstra.openChatRoomsPage());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final theme = Theme.of(context);

    return BlocBuilder<ChatGroupCubit, ChatGroupState>(builder: (context, state) {
      List<ChatParticipants> chatParticipant = [];
      List<ChatUser> chatUsersList = List.empty(growable: true);
      List<int> chatParticipantId = List.empty(growable: true);
      int myChatParticipantId = -1;

      AppError? error;
      if (state is ChatGroupReady) {
        loading = state.chatParticipantList.inProgress;
        chatParticipant = state.chatParticipantList.value ?? [];
        chatParticipant = chatParticipant.where((element) => element.deleted == 0).toList();
        error = state.chatParticipantList.error;

        chatUsersList = state.chatUsersList.value ?? List.empty();

        if (chatUsersList.isNotEmpty) {
          chatUsersList.removeWhere((item) => item.id == widget.profile.id);
          chatParticipantId.addAll(chatParticipant.map((e) => e.userId!));
        }

        ChatParticipants? chat = chatParticipant.firstWhereOrNull(
            (element) => element.userId == widget.profile.id && element.deleted == 0);
        if (chat != null) {
          myChatParticipantId = chat.id;
        }
      }

      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 4,
              child: loading ? LinearProgressIndicator() : null,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Group Participants'.i18n, style: theme.textTheme.subtitle1)),
                  if (widget.profile.isAdmin && widget.isGlobal == 0)
                    InkWell(
                      onTap: () => _addParticipant(chatParticipantId, chatUsersList),
                      child: Row(
                        children: [Icon(Icons.add), Text('Add'.i18n)],
                      ),
                    )
                ],
              ),
            ),
            if (chatParticipant.isNotEmpty)
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: chatParticipant.length,
                  itemBuilder: (context, index) {
                    ChatParticipants user = chatParticipant[index];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 4.0),
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: Image.asset(
                                  'assets/person.jpg',
                                  fit: BoxFit.cover,
                                ).image,
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                flex: 16,
                                child: Text(
                                  user.userName!,
                                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                                ),
                              ),
                              if (widget.profile.isAdmin &&
                                  widget.profile.id == user.userId &&
                                  widget.isGlobal == 1)
                                InkWell(
                                  onTap: () => _delete(user.userName, user.id),
                                  child: Icon(Icons.close),
                                ),
                              if (widget.profile.isAdmin && widget.isGlobal == 0)
                                InkWell(
                                  onTap: () => _delete(user.userName, user.id),
                                  child: Icon(Icons.close),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (chatParticipant.isEmpty && !loading)
              Expanded(
                  child: Center(
                      child: Text(
                'No chat participant found'.i18n,
                style: TextStyle(fontSize: 16),
              ))),
            if (widget.profile.isEmployee == true || widget.profile.isSupervisor == true)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () => _exitGroup(myChatParticipantId),
                    child: Row(
                      children: [
                        Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Exit group'.i18n,
                          style: TextStyle(color: Colors.red, fontSize: 15),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            if (widget.profile.isAdmin == true && widget.isGlobal == 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () => _deleteChatRoom(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Delete group'.i18n,
                          style: TextStyle(color: Colors.red, fontSize: 15),
                        )
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      );
    });
  }
}
