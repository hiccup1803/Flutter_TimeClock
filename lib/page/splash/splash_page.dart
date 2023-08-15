import 'dart:async';

import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/dijkstra.dart' as dijkstra;
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/repository/terminal_repository.dart';
import 'package:staffmonitor/widget/app_logo_widget.dart';
import 'package:wakelock/wakelock.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends BasePageState<SplashPage> {
  AuthState? _auth;
  bool _showLoading = false;
  bool _terminalChecked = false;
  bool _isTerminal = false;
  late Timer _timer;
  late TerminalRepository _terminalRepository;

  final _log = Logger('Splash');

  @override
  void initState() {
    super.initState();
    Wakelock.disable();
    _terminalRepository = injector.terminalRepository;
    _terminalRepository.isActiveTerminal().then((value) {
      setState(() {
        _terminalChecked = true;
        _isTerminal = value;
        _navigate();
      });
    });
    _timer = Timer(Duration(seconds: 2), () {
      setState(() {
        _showLoading = true;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _navigate() {
    if (_terminalChecked) {
      if (_isTerminal) {
        dijkstra.Dijkstra.openTerminal();
      } else {
        super.authCheck(_auth);
      }
    }
  }

  @override
  void authCheck(AuthState? authState) {
    if (_auth != authState)
      setState(() {
        _auth = authState;
        _navigate();
      });
  }

  @override
  String? shouldRedirect(AuthState? authState) {
    _log.fine('authState: $authState');
    if (authState is AuthAuthorized) {
      return dijkstra.MAIN_ROUTE;
    }
    if (authState is AuthUnauthorized) {
      return dijkstra.START_ROUTE;
    }
    return null;
  }

  @override
  Widget buildSafe(BuildContext context, [profile]) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoWidget(100),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: _showLoading
                  ? CircularProgressIndicator(color: Color.fromARGB(255, 0, 31, 126))
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
