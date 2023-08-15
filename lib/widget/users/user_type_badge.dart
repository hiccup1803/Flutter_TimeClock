import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';

import 'users.i18n.dart';

class UserTypeBadge extends StatelessWidget {
  const UserTypeBadge(this.profile);

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: profile.isSuperAdmin
          ? Colors.redAccent
          : profile.isAdmin
              ? Colors.blue
              : Colors.blueGrey,
      borderRadius: BorderRadius.all(Radius.circular(4)),
      textStyle: TextStyle(),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Text(
          (profile.isSuperAdmin
                  ? 'superadmin'.i18n
          :profile.isSupervisor?'supervisor'.i18n
                  : profile.isAdmin
                      ? 'admin'.i18n
                      : 'employee'.i18n)
              .toUpperCase(),
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.032,
          ),
        ),
      ),
    );
  }
}
