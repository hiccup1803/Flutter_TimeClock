import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'register_page.i18n.dart';

class RegisterEmployerPage extends BasePageWidget {
  static Map<String, dynamic> buildArgs({String? email}) => {
        'email': email,
      };

  @override
  String? shouldRedirect(_) => null;

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
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
          child: RegisterEmployerWidget(),
        ),
      ),
    );
  }
}

class RegisterEmployerWidget extends StatefulWidget {
  @override
  _RegisterEmployerWidgetState createState() => _RegisterEmployerWidgetState();
}

class _RegisterEmployerWidgetState extends State<RegisterEmployerWidget> {
  late TextEditingController emailController,
      nameController,
      passController,
      rateController,
      companyNameController;
  late String lang;
  late String timeZone;

  String? emailError, nameError, passError, rateError, companyNameError;
  bool enabled = true;
  bool processing = false;
  bool obscure = true;
  bool isAllowed = false;

  @override
  void initState() {
    super.initState();
    if (Platform.localeName.toLowerCase().contains('pl')) {
      lang = 'pl';
    } else {
      lang = 'en';
    }

    emailController = TextEditingController()..addListener(onEmailChanged);
    nameController = TextEditingController()..addListener(onNameChanged);
    passController = TextEditingController()..addListener(onPassChanged);
    rateController = TextEditingController(text: lang == 'pl' ? 'PLN' : 'USD')
      ..addListener(onRateChanged);
    companyNameController = TextEditingController()..addListener(onCompanyNameChanged);

    getCurrentTimezone();
  }

  getCurrentTimezone() async {
    timeZone = await FlutterNativeTimezone.getLocalTimezone();
  }

  void onEmailChanged() {
    if (emailError != null)
      setState(() {
        if (emailController.text.isEmpty) {
          emailError = 'Required'.i18nAs(lang);
        } else if (emailRegEx.hasMatch(emailController.text)) {
          emailError = null;
        } else {
          emailError = 'Invalid address'.i18nAs(lang);
        }
      });
  }

  void onNameChanged() {
    if (nameError != null)
      setState(() {
        if (nameController.text.isEmpty) {
          nameError = 'Required'.i18nAs(lang);
        } else {
          nameError = null;
        }
      });
  }

  void onPassChanged() {
    if (passError != null)
      setState(() {
        if (passController.text.isEmpty) {
          passError = 'Required'.i18nAs(lang);
        } else if (passController.text.length < 6) {
          passError = null;
        }
      });
  }

  void onRateChanged() {
    if (rateError != null)
      setState(() {
        if (rateController.text.isEmpty) {
          rateError = 'Required'.i18nAs(lang);
        } else {
          rateError = null;
        }
      });
  }

  void onCompanyNameChanged() {
    if (companyNameError != null)
      setState(() {
        if (companyNameController.text.isEmpty) {
          companyNameError = 'Required'.i18nAs(lang);
        } else {
          companyNameError = null;
        }
      });
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passController.dispose();
    rateController.dispose();
    companyNameController.dispose();
    super.dispose();
  }

  void _showError(String? error) async {
    FailureDialog.show(
      context: context,
      content: Text(error ?? 'An error occurred'.i18nAs(lang)),
    ).then((value) {
      setState(() {
        processing = false;
        enabled = true;
      });
    });
  }

  bool checkValidation() {
    bool valid = true;
    setState(() {
      if (emailController.text.isEmpty) {
        emailError = 'Required'.i18nAs(lang);
        valid = false;
      } else if (emailRegEx.hasMatch(emailController.text)) {
        emailError = null;
      } else {
        emailError = 'Invalid address'.i18nAs(lang);
        valid = false;
      }
      if (nameController.text.isEmpty) {
        nameError = 'Required'.i18nAs(lang);
        valid = false;
      } else {
        nameError = null;
      }
      if (passController.text.isEmpty) {
        passError = 'Required'.i18nAs(lang);
        valid = false;
      } else {
        passError = null;
      }
      if (rateController.text.isEmpty) {
        rateError = 'Required'.i18nAs(lang);
        valid = false;
      } else {
        rateError = null;
      }
      if (companyNameController.text.isEmpty) {
        companyNameError = 'Required'.i18nAs(lang);
        valid = false;
      } else {
        companyNameError = null;
      }
      if (isAllowed) {
        valid = true;
      }
    });
    return valid;
  }

  void createAccount() {
    if (checkValidation()) {
      setState(() {
        enabled = false;
        processing = true;
      });
      injector.registrationService
          .registerAccount(emailController.text, nameController.text, lang, passController.text,
              rateController.text, companyNameController.text, timeZone)
          .then(
        (response) {
          if (response.isSuccessful) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Account has been created'.i18nAs(lang)),
                  content: Text('You can log in now'.i18nAs(lang)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'.i18nAs(lang)),
                    ),
                  ],
                );
              },
            ).then((value) => Dijkstra.goBack());
          } else {
            var ddd = jsonDecode(response.bodyString);

            List l = (ddd as List).map((data) => new Errmsg.fromJson(data)).toList();
            String errr = "";
            l.forEach((value) {
              String f = (value.field);
              String m = (value.message);
              errr = errr + f + ": " + m.i18nAs(lang) + '\n\n';
            });
            _showError(errr);
          }
        },
        onError: (e, stack) {
          print(e);
          _showError(e.toString());
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //companyTimeZone
    final decoration = sharedGreyInputDecoration.copyWith(
      enabled: enabled,
    );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: decoration.copyWith(
                  labelText: 'Email'.i18nAs(lang),
                  errorText: emailError,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: decoration.copyWith(
                  labelText: 'First & last name'.i18nAs(lang),
                  errorText: nameError,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: passController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: obscure,
                decoration: decoration.copyWith(
                  labelText: 'Password'.i18nAs(lang),
                  errorText: passError,
                  suffixIcon: InkWell(
                    child: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onTap: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                ),
              ),
            ),
            dropdownRow<String, String>(
              'Language'.i18nAs(lang),
              lang.toLowerCase(),
              {'pl': 'Polski', 'en': 'English'},
              labelFlex: 1,
              decoration: sharedGreyDecoration,
              optionBuilder: (item) => Text(item),
              selectedBuilder: (item) => Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              onChange: enabled
                  ? (lang) {
                      setState(() {
                        this.lang = lang ?? 'en';
                        if (this.lang == 'en') rateController.text = 'USD';
                        if (this.lang == 'pl') rateController.text = 'PLN';
                      });
                    }
                  : null,
              onTap: () => context.unFocus(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: rateController,
                keyboardType: TextInputType.text,
                decoration: decoration.copyWith(
                  labelText: 'Rate currency'.i18nAs(lang),
                  errorText: rateError,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: companyNameController,
                keyboardType: TextInputType.text,
                decoration: decoration.copyWith(
                  labelText: 'Company name'.i18nAs(lang),
                  errorText: companyNameError,
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
                    TextSpan(text: 'I accept '.i18nAs(lang)),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          String url = 'https://staffmonitor.app/terms?lang=$lang';
                          canLaunch(url).then((value) {
                            launch(url);
                          });
                        },
                      text: "Terms".i18nAs(lang),
                      style: TextStyle(color: Colors.deepOrangeAccent),
                    ),
                    TextSpan(text: " and ".i18nAs(lang)),
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            String url = 'https://staffmonitor.app/privacy?lang=$lang';
                            canLaunch(url).then((value) {
                              launch(url);
                            });
                          },
                        text: "Privacy Policy".i18nAs(lang),
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
                onPressed: enabled
                    ? isAllowed
                        ? createAccount
                        : null
                    : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                        Text('Create account'.i18nAs(lang)),
                      ] +
                      ((!enabled && !processing) ? [CircularProgressIndicator()] : []),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: ElevatedButton(
                onPressed: () => Dijkstra.openSignInPage(admin: true, replace: true),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text("I already have account - login".i18n),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Errmsg {
  String field = "";
  String message = "";

  Errmsg({required this.field, required this.message});

  factory Errmsg.fromJson(Map<String, dynamic> parsedJson) {
    return Errmsg(field: parsedJson['field'], message: parsedJson['message']);
  }
}
