import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';

import 'reset_password_page.i18n.dart';

//https://flutter.dev/docs/development/ui/navigation/deep-linking
class ResetPasswordPage extends BasePageWidget {
  static const String EMAIL_KEY = '_email';
  static const String TOKEN_KEY = '_token';

  static Map<String, dynamic> buildArgs(String? email, String? token) => {
        EMAIL_KEY: email,
        TOKEN_KEY: token,
      };

  @override
  String? shouldRedirect(_) => null;

  @override
  Widget buildSafe(BuildContext context, [profile]) => Container();

  @override
  Widget build(BuildContext context) {
    var args = readArgs(context);
    var token;
    var email;
    if (args?.containsKey(EMAIL_KEY) == true) email = args![EMAIL_KEY];
    if (args?.containsKey(TOKEN_KEY) == true) token = args![TOKEN_KEY];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black54),
        title: Text(
          'Recover password'.i18n,
          style: TextStyle(color: Colors.black54),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResetPasswordForm(email, token),
        ),
      ),
    );
  }
}

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm(this.initialEmail, this.initialToken);

  final String? initialEmail;
  final String? initialToken;

  @override
  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final log = Logger('ResetPasswordForm');

  late TextEditingController _tokenController, _passwordController, _emailController;
  String? _emailError, _passwordError, _tokenError;

  bool setPassword = false;
  bool processing = false;
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken?.isNotEmpty == true) {
      setPassword = true;
    }
    _tokenController = TextEditingController(text: widget.initialToken ?? '')
      ..addListener(_tokenChanged);
    _emailController = TextEditingController(text: widget.initialEmail ?? '')
      ..addListener(_emailChanged);
    _passwordController = TextEditingController()..addListener(_passwordChanged);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _emailChanged() {
    if (_emailError != null) {
      setState(() {
        if (_emailController.text.isEmpty) {
          _emailError = 'Required'.i18n;
        } else if (emailRegEx.hasMatch(_emailController.text)) {
          _emailError = null;
        } else {
          _emailError = 'Invalid address'.i18n;
        }
      });
    }
  }

  void _tokenChanged() {
    if (_tokenError != null) {
      setState(() {
        if (_tokenController.text.isEmpty) {
          _tokenError = 'Required'.i18n;
        } else {
          _tokenError = null;
        }
      });
    }
  }

  void _passwordChanged() {
    if (_passwordError != null) {
      setState(() {
        if (_passwordController.text.isEmpty) {
          _passwordError = 'Required'.i18n;
        } else if (_passwordController.text.length < 8) {
          _passwordError = 'Password is too short'.i18n;
        } else {
          _passwordError = null;
        }
      });
    }
  }

  void _showError(dynamic error) {
    if (error is AppError) {
      error = error.messages.toString();
    }

    FailureDialog.show(
      context: context,
      content: Text(error?.toString() ?? 'An error occurred'.i18n),
    ).then((value) {
      setState(() {
        processing = false;
      });
    });
  }

  void sendResetToken() {
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Required'.i18n;
      });
    } else if (emailRegEx.hasMatch(_emailController.text)) {
      setState(() {
        _emailError = null;
      });
    } else {
      setState(() {
        _emailError = 'Invalid address'.i18n;
      });
    }
    if (_emailError != null) {
      return;
    }

    setState(() {
      processing = true;
    });
    injector.registrationService.resetPassword(_emailController.text).then(
      (response) {
        if (response.isSuccessful) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An email has been send with reset token.'.i18n)));
          setState(() {
            processing = false;
            setPassword = true;
            _tokenController.text = '';
            _passwordController.text = '';
          });
        } else {
          _showError(response.error);
        }
      },
      onError: (e, stack) {
        _showError(e);
      },
    );
  }

  void setNewPassword() {
    setState(() {
      processing = true;
    });
    injector.registrationService
        .setNewPassword(_tokenController.text, _passwordController.text)
        .then(
      (response) {
        if (response.isSuccessful) {
          SuccessDialog.show(
            context: context,
            content: Text('You can now log in with the new password.'.i18n),
          ).then((value) => Dijkstra.goBack());
        } else {
          _showError(response.error);
        }
      },
      onError: (e, stack) {
        log.finest('setPassword', e, stack);
        _showError(e.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!setPassword)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: sharedGreyInputDecoration.copyWith(
                    labelText: 'Email'.i18n,
                    enabled: processing != true,
                    errorText: _emailError,
                  ),
                ),
              ),
            if (!setPassword)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(44),
                  ),
                  child: Text('Reset password'.i18n),
                  onPressed: processing ? null : sendResetToken,
                ),
              ),
            if (setPassword)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: TextField(
                  controller: _tokenController,
                  keyboardType: TextInputType.text,
                  decoration: sharedGreyInputDecoration.copyWith(
                    labelText: 'Token'.i18n,
                    enabled: processing != true,
                    // errorText: details?.emailError,
                  ),
                ),
              ),
            if (setPassword)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: obscure,
                  decoration: sharedGreyInputDecoration.copyWith(
                      labelText: 'Password'.i18n,
                      enabled: processing != true,
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                        child: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                      )
                      // errorText: details?.passwordError,
                      ),
                ),
              ),
            if (setPassword)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(44),
                  ),
                  child: Text('Set new password'.i18n),
                  onPressed: processing ? null : setNewPassword,
                ),
              ),
            Divider(),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.fromHeight(44),
              ),
              onPressed: () {
                setState(() {
                  setPassword = !setPassword;
                });
              },
              child:
                  Text(setPassword ? 'Send me the token'.i18n : 'I have reset password token'.i18n),
            ),
          ],
        ),
      ),
    );
  }
}
