import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/chat/chat_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/chat/chat_room_list_widget.i18n.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/text_input_dialog.dart';

class CreateChatGroupPage extends BasePageWidget {
  static const String CHAT_USER_LIST_KEY = 'chatUserList';
  static const int SESSION_CHANGED = 101;
  static const String CHAT_CUBIT_KEY = 'chatCubit';

  static Map<String, dynamic> buildArgs(ChatCubit chatCubit, List<ChatUser> list) => {
        CHAT_USER_LIST_KEY: list,
        CHAT_CUBIT_KEY: chatCubit,
      };

  List<ChatUser> selectedList = [];

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context)!;
    final theme = Theme.of(context);
    List<ChatUser> paramChatUserList = args[CHAT_USER_LIST_KEY];
    ChatCubit chatCubit = args[CHAT_CUBIT_KEY];

    if (paramChatUserList.isNotEmpty && paramChatUserList.elementAt(0).id == -1) {
      paramChatUserList.removeAt(0);
    }

    return BlocProvider<ChatCubit>(
      create: (context) => ChatCubit(
        injector.chatRepository,
      )..init(false),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 50,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New group'.i18n,
                style: theme.textTheme.headline6,
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                'Add participants'.i18n,
                style: theme.textTheme.caption,
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (paramChatUserList.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: paramChatUserList.length,
                    itemBuilder: (context, index) {
                      final chatUser = paramChatUserList[index];
                      return ChatUserWidget(
                        chatUser,
                        (bool value) {
                          if (value) {
                            selectedList.add(chatUser);
                          } else {
                            selectedList.remove(chatUser);
                          }
                        },
                      );
                    },
                  ),
                ),
              if (paramChatUserList.isEmpty)
                Expanded(child: Center(child: Text('No chat users found'.i18n))),
            ],
          ),
        ),
        floatingActionButton: CreateChatFab(chatCubit, selectedList, profile!.id),
      ),
    );
  }
}

class CreateChatFab extends StatelessWidget {
  CreateChatFab(this.chatCubit, this.selectedList, this.myProfileID);

  final List<ChatUser> selectedList;
  final int myProfileID;
  final ChatCubit chatCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return FloatingActionButton(
          onPressed: () {
            if (selectedList.isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Please select at least 1 user')));
            } else {
              List<int> selectedUsers = List.empty(growable: true);
              selectedUsers.add(myProfileID);
              selectedUsers.addAll(selectedList.map((e) => e.id));

              TextInputDialog.show(
                context: context,
                text: '',
                title: Text('Group Name'.i18n),
              ).then((value) {
                if (value != null) {
                  String groupName = value;

                  BlocProvider.of<ChatCubit>(context)
                      .createGroupChatRoom(groupName, 1, selectedUsers)
                      .then((value) {
                    Dijkstra.openChatMessagesPage(chatCubit, true, value.name,
                        chatRoom: value, replace: true);
                  }).onError((error, stackTrace) {
                    FailureDialog.show(
                      context: context,
                      content: Text(error.toString()),
                    ).then((value) {
                      Dijkstra.goBack();
                    });
                  });
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Please give a group name')));
                }
              });
            }
          },
          child: Icon(Icons.arrow_forward),
        );
      },
    );
  }
}

class ChatUserWidget extends StatefulWidget {
  ChatUserWidget(this.mChatUser, this.isSelected);

  final ChatUser mChatUser;
  final ValueChanged<bool> isSelected;

  @override
  State<ChatUserWidget> createState() => _ChatUserWidgetState();
}

class _ChatUserWidgetState extends State<ChatUserWidget> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
              widget.isSelected(isSelected);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: isSelected ? Colors.blueGrey.shade300 : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: Image.asset(
                    'assets/person.jpg',
                    fit: BoxFit.cover,
                  ).image,
                ),
                title: Text(
                  widget.mChatUser.name,
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
