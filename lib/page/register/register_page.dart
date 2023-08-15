import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/register/register_cubit.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../injector.dart';
import 'register_page.i18n.dart';

class RegisterPage extends BasePageWidget {
  static const String CODE_KEY = '_code';

  static Map<String, dynamic> buildArgs(String? registerCode) => {
        CODE_KEY: registerCode,
      };

  @override
  String? shouldRedirect(_) => null;

  @override
  Widget buildSafe(BuildContext context, [profile]) => Container();

  @override
  Widget build(BuildContext context) {
    var args = readArgs(context);
    var code;
    if (args?.containsKey(CODE_KEY) == true) {
      code = args![CODE_KEY];
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black54),
        title: Text(
          'Registration'.i18n,
          style: TextStyle(color: Colors.black54),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocProvider<RegisterCubit>(
            create: (context) => RegisterCubit(injector.registrationService, code: code),
            child: RegisterForm(),
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _log = Logger('RegisterPage');

  late TextEditingController _inviteCodeController,
      _nameController,
      _emailController,
      _passwordController,
      _repeatPasswordController;
  FocusNode? _inviteFocusNode;
  bool isAllowed = false;

  @override
  void initState() {
    super.initState();
    _inviteFocusNode = FocusNode();
    _inviteCodeController =
        TextEditingController(text: BlocProvider.of<RegisterCubit>(context).code ?? '');
    _inviteCodeController.addListener(() {
      BlocProvider.of<RegisterCubit>(context).inviteChanged(_inviteCodeController.text);
    });
    _nameController = TextEditingController();
    _nameController.addListener(() {
      BlocProvider.of<RegisterCubit>(context).nameChanged(_nameController.text);
    });
    _emailController = TextEditingController();
    _emailController.addListener(() {
      BlocProvider.of<RegisterCubit>(context).emailChanged(_emailController.text);
    });
    _passwordController = TextEditingController();
    _passwordController.addListener(_passwordChanged);
    _repeatPasswordController = TextEditingController();
    _repeatPasswordController.addListener(_passwordChanged);
  }

  @override
  void dispose() {
    _inviteFocusNode!.dispose();
    _inviteCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  void _passwordChanged() {
    BlocProvider.of<RegisterCubit>(context)
        .passwordChanged(_passwordController.text, _repeatPasswordController.text);
  }

  void _showError(String? error) async {
    await FailureDialog.show(
      context: context,
      content: Text(error ?? 'An error occurred'.i18n),
    ).then((value) {
      BlocProvider.of<RegisterCubit>(context).onErrorClosed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterInputCode) {
          if (state.inviteError?.isNotEmpty == true) {
            _inviteFocusNode!.requestFocus();
          }
        }

        var code;
        if (state is RegisterInputDetails) {
          code = state.code;
        }
        if (state is RegisterProcessing) {
          code = state.code;
        }
        _log.fine('code vs input: $code vs ${_inviteCodeController.text}');
        if (code != null && code != _inviteCodeController.text) {
          setState(() {
            _inviteCodeController.text = code;
          });
        }
        if (state is RegisterError) {
          _showError(state.error);
        }
        if (state is RegisterFinish) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        var enabled = state is! RegisterProcessing;

        RegisterInputCode? codeState;
        if (state is RegisterInputCode) {
          codeState = state;
        }
        RegisterInputDetails? details;
        if (state is RegisterInputDetails) {
          details = state;
        }

        var enabledDetails = details != null && enabled;
        var processingCode = state is RegisterProcessing && state.validCode == false;

        var decoration = sharedGreyInputDecoration.copyWith(
          enabled: details != null && enabled,
        );

        ThemeData theme = Theme.of(context);

        _log.fine('build: $enabled, $enabledDetails, ${state.runtimeType}');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _inviteCodeController,
                  focusNode: _inviteFocusNode,
                  buildCounter:
                      (context, {required currentLength, required isFocused, maxLength}) => Text(
                    isFocused ? '$currentLength' : '',
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: BlocProvider.of<RegisterCubit>(context).inviteChanged,
                  decoration: decoration.copyWith(
                    labelText: 'Invite code'.i18n,
                    enabled: enabled,
                    errorText: codeState?.inviteError,
                    enabledBorder: details != null
                        ? outlineInputBorder.copyWith(
                            borderSide: BorderSide(color: AppColors.positiveGreen, width: 2),
                          )
                        : null,
                    suffix: processingCode
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(),
                          )
                        : null,
                    suffixIcon: details != null
                        ? Icon(
                            Icons.check,
                            color: AppColors.positiveGreen,
                          )
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Creating an employee account in company '.i18n,
                      style: theme.textTheme.caption,
                    ),
                  ],
                ),
              ),
              if (details?.companyName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    details?.companyName ?? '-',
                    style: theme.textTheme.bodyText1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  onChanged: BlocProvider.of<RegisterCubit>(context).nameChanged,
                  decoration: decoration.copyWith(
                    labelText: 'First & last name'.i18n,
                    errorText: details?.nameError,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: BlocProvider.of<RegisterCubit>(context).emailChanged,
                  decoration: decoration.copyWith(
                    labelText: 'Email'.i18n,
                    errorText: details?.emailError,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: decoration.copyWith(
                    labelText: 'Password'.i18n,
                    enabled: enabledDetails,
                    errorText: details?.passwordError,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _repeatPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: decoration.copyWith(
                    labelText: 'Repeat password'.i18n,
                    errorText: details?.repeatPasswordError,
                  ),
                ),
              ),
              CheckboxListTile(
                value: isAllowed,
                onChanged: (value) {
                  setState(() {
                    isAllowed = value ?? false;
                  });
                },
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(text: 'I accept '.i18n),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            String url =
                                'https://staffmonitor.app/terms?lang=${Localizations.maybeLocaleOf(context)?.languageCode}';
                            canLaunch(url).then((value) {
                              launch(url);
                            });
                          },
                        text: "Terms".i18n,
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                      TextSpan(text: " and ".i18n),
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              String url =
                                  'https://staffmonitor.app/privacy?lang=${Localizations.maybeLocaleOf(context)?.languageCode}';
                              canLaunch(url).then((value) {
                                launch(url);
                              });
                            },
                          text: "Privacy Policy".i18n,
                          style: TextStyle(color: Colors.deepOrangeAccent)),
                    ],
                  ),
                ),
                activeColor: Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(20, 45)),
                  ),
                  onPressed: isAllowed && enabledDetails
                      ? () => BlocProvider.of<RegisterCubit>(context).registerAccount(
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          repeatedPassword: _repeatPasswordController.text)
                      : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Text('Create account'.i18n),
                      if (!enabled && !processingCode)
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: CircularProgressIndicator(),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
