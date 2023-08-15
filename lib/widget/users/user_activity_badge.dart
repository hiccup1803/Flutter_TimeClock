import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';

import 'users.i18n.dart';

class UserActivityBadge extends StatelessWidget {
  const UserActivityBadge(this.profile);

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: profile.isActive
          ? Colors.green
          : profile.isDeleted
              ? Colors.blueGrey
              : Colors.amber,
      borderRadius: BorderRadius.all(Radius.circular(4)),
      textStyle: TextStyle(color: profile.isRegistered ? Colors.black87 : null),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Text(
          (profile.isActive
                  ? 'active'.i18n
                  : profile.isDeleted
                      ? 'deactivated'.i18n
                      : 'registered'.i18n)
              .toUpperCase(),
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.032,
          ),
        ),
      ),
    );
  }
}
