part of 'edit_user_page.dart';

class EditUserActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditUserCubit, EditUserState>(
      builder: (context, state) {
        if (state is EditUserProcessing) {
          return PopupMenuButton<dynamic>(
            enabled: false,
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: Text('Loading'.i18n),
              )
            ],
          );
        }

        bool isActive = false;
        Profile? user;
        if (state is EditUserEdit) {
          isActive = state.user.isActive == true;
          user = state.ogUser;
          if (state.ogUser.isCreate == true) {
            return Container();
          }
        }
        return PopupMenuButton<int>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 1:
                generatePin(context);
                break;
              case 2:
                removePin(context);
                break;
              case 9:
                resetPassword(context);
                break;
            }
            Logger('EditUserActions').fine('selected: $value');
          },
          itemBuilder: (context) {
            return <PopupMenuEntry<int>>[
              PopupMenuItem(
                value: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.apps),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text('Generate Pin'.i18n),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.apps),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text('Remove Pin'.i18n),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                // value: 5,
                value: 9,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.lock),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text('Reset password'.i18n),
                    ),
                  ],
                ),
              ),
            ];
          },
        );
      },
    );
  }

  void generatePin(BuildContext context) {
    ConfirmDialog.show(
      context: context,
      title: Text('Generate new pin code?'.i18n),
      content: Text('Generating new pin code will remove current pin code.'.i18n),
    ).then((value) {
      if (value == true) {
        BlocProvider.of<EditUserCubit>(context).generateNewPin();
      }
    });
  }

  void removePin(BuildContext context) {
    ConfirmDialog.show(
      context: context,
      title: Row(
        children: [
          Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
          Text('Remove pin code?'.i18n),
        ],
      ),
    ).then((value) {
      if (value == true) {
        BlocProvider.of<EditUserCubit>(context).removePin();
      }
    });
  }

  void resetPassword(BuildContext context) {
    ConfirmDialog.show(
            context: context,
            title: Text('Reset user password?'.i18n),
            content: Text('An email with instructions will be send to users email address.'.i18n))
        .then((value) {
      if (value == true) {
        BlocProvider.of<EditUserCubit>(context).resetPassword();
      }
    });
  }


}
