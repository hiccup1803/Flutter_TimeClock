import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/widget/app_logo_widget.dart';

import 'start_page.i18n.dart';

class StartPage extends BasePageWidget {
  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    return Scaffold(
      body: SafeArea(
        child: StartWidget(),
      ),
    );
  }

  @override
  String? shouldRedirect(AuthState? authState) => authState is AuthAuthorized ? MAIN_ROUTE : null;
}

class StartWidget extends StatefulWidget {
  @override
  _StartWidgetState createState() => _StartWidgetState();
}

class _StartWidgetState extends State<StartWidget> {
  @override
  Widget build(BuildContext context) {
    final minSize = Size(220, 48);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppLogoWidget(100),
        Container(height: kToolbarHeight),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Dijkstra.openSignInPage(employee: true),
                child: Text("I am employee - worker".i18n),
                style: ElevatedButton.styleFrom(
                  minimumSize: minSize,
                  padding: EdgeInsets.all(8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Dijkstra.openSignInPage(admin: true, checkFirstTime: true),
                child: Text("I am company owner\nor freelancer".i18n, textAlign: TextAlign.center),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(280, 52),
                  primary: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.all(24.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Dijkstra.openTerminalRegistration(),
                child: Text("Change app to KIOSK mode".i18n),
                style: ElevatedButton.styleFrom(
                  minimumSize: minSize,
                  primary: Colors.grey,
                  padding: EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
        Container(),
      ],
    );
  }
}
