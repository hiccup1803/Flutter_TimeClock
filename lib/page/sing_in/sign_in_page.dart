import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/app_logo_widget.dart';
import 'package:staffmonitor/widget/dialog/login_error_dialog.dart';
import 'package:staffmonitor/widget/dialog/no_internet_dialog.dart';

import 'sign_in_page.i18n.dart';

class SignInPage extends BasePageWidget {
  static Map<String, dynamic> buildArgs(bool? employee, bool? admin) => {
        'employee': employee,
        'admin': admin,
      };

  @override
  String? shouldRedirect(AuthState? authState) => authState is AuthAuthorized ? MAIN_ROUTE : null;

  @override
  Widget buildSafe(BuildContext context, [profile]) {
    bool isAdmin = false;
    final args = readArgs(context);
    if (args != null && args.containsKey('admin')) {
      isAdmin = args['admin'] == true;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppLogoWidget(100),
                SignInForm(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: TextButton(
                    onPressed: () => Dijkstra.openResetPasswordPage(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Forgot password? - Recover it'.i18n),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black87,
                  indent: 36.0,
                  endIndent: 36.0,
                ),
                if (!isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green.shade400, shadowColor: Colors.green),
                      onPressed: () => Dijkstra.openRegisterPage(),
                      // Dijkstra.openRegisterPage(registerCode: 'g97a6dw8yuh4'),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('Have an invite code? - Register now'.i18n),
                      ),
                    ),
                  ),
                if (isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () => Dijkstra.openRegisterEmployerPage(replace: true),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text("Don't have an account? - Register now".i18n),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _log = Logger('SignInForm');
  late TextEditingController _userController, _passwordController;

  bool _loading = false;
  bool _success = false;
  bool _obscurePassword = true;

  String? _passwordError;
  String? _userError;
  String? deviceToken;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    _userController = TextEditingController(text: const String.fromEnvironment('user'));
    _passwordController = TextEditingController(text: const String.fromEnvironment('password'));
    _userController.addListener(_userChanged);
    _passwordController.addListener(_passwordChanged);

    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    }
  }

  void _userChanged() {
    if (_userError != null) {
      setState(() {
        if (_userController.text.isNotEmpty != true) {
          _userError = 'Required'.i18n;
        } else {
          _userController.text = _userController.text.trim();
          _userError = null;
        }
      });
    }
  }

  Future<void> _checkNotificationPermission(BuildContext context) async {
    await NotificationPermissions.getNotificationPermissionStatus().then((value) async {
      switch (value) {
        case PermissionStatus.denied:
          _requestPermission();
          break;
        case PermissionStatus.granted:
          await pushyRegister();
          break;
        case PermissionStatus.unknown:
          _requestPermission();
          break;
        case PermissionStatus.provisional:
          _requestPermission();
          break;
        default:
          return null;
      }
    });
  }

  Future _requestPermission() async {
    await NotificationPermissions.requestNotificationPermissions(
            openSettings: false,
            iosSettings: const NotificationSettingsIos(sound: true, badge: true, alert: true))
        .then((value) async {
      switch (value) {
        case PermissionStatus.denied:
          deviceToken = null;
          break;
        case PermissionStatus.granted:
          await pushyRegister();
          break;
        case PermissionStatus.unknown:
          deviceToken = null;
          break;
        case PermissionStatus.provisional:
          deviceToken = null;
          break;
        default:
          return null;
      }
    });
  }

  Future pushyRegister() async {
    try {
      // Register the user for push notifications
      deviceToken = await Pushy.register();
    } on PlatformException catch (error) {
      deviceToken = null;
    }
  }

  void _passwordChanged() {
    if (_passwordError != null) {
      setState(() {
        if (_passwordController.text.isNotEmpty != true) {
          _passwordError = 'Required'.i18n;
        } else {
          _passwordError = null;
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _userController.dispose();
    _passwordController.dispose();
  }

  bool formValid() {
    bool valid = true;
    String? userError;
    String? passwordError;

    _userController.text = _userController.text.trim();
    if (_userController.text.isEmpty) {
      valid = false;
      userError = 'Required'.i18n;
    }
    if (_passwordController.text.isEmpty) {
      valid = false;
      passwordError = 'Required'.i18n;
    }
    setState(() {
      _userError = userError;
      _passwordError = passwordError;
    });

    return valid;
  }

  void trySignIn() async {
    if (!formValid()) {
      return;
    }
    await pushyRegister();
    _setLoading(true);

    BlocProvider.of<AuthCubit>(context)
        .singIn(_userController.text, _passwordController.text, deviceToken)
        .then(
      (success) {
        _log.fine('trySignIn: $success');
        if (success == true) {
          setState(() {
            _success = true;
            _loading = false;
          });
        } else {
          NoInternetDialog.show(context: context).then((value) => _setLoading(false));
        }
      },
      onError: (e, stack) {
        _log.warning('trySignIn', e, stack);

        if (e is AppError) {
          _showError(e).then((_) => _setLoading(false));
        } else {
          _showError(AppError.fromMessage(e.toString())).then((_) => _setLoading(false));
        }
      },
    );
  }

  void _setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _userController,
            decoration: sharedGreyInputDecoration.copyWith(
              hintText: 'Email'.i18n,
              errorText: _userError,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _obscurePassword,
            decoration: sharedGreyInputDecoration.copyWith(
              hintText: 'Password'.i18n,
              errorText: _passwordError,
              suffixIcon: InkWell(
                onTap: () => setState(() {
                  _obscurePassword = !_obscurePassword;
                }),
                child: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: _success ? AppColors.positiveGreen : null, minimumSize: Size(20, 50)),
            onPressed: (_loading || _success) ? null : trySignIn,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[_success ? Text('Signed in'.i18n) : Text('Sign in'.i18n)] +
                  (_loading ? <Widget>[CircularProgressIndicator()] : []),
            ),
          ),
        ),
      ],
    );
  }

  Future _showError(AppError e) async {
    return LoginErrorDialog.show(
      context: context,
      content: (e.messages.isNotEmpty == true)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: e.messages.map((e) => Text(e!)).toList(),
            )
          : Text('An error occurred'.i18n),
    );
  }
}
