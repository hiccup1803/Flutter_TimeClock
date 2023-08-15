import 'package:flutter/gestures.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/repository/terminal_repository.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/app_logo_widget.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'terminal.i18n.dart';

class RegisterTerminalPage extends StatefulWidget {
  @override
  _RegisterTerminalPageState createState() => _RegisterTerminalPageState();
}

class _RegisterTerminalPageState extends State<RegisterTerminalPage> {
  late TerminalRepository _terminalRepository;
  late TapGestureRecognizer _tapGestureRecognizer;
  late TextEditingController _terminalIdController, _codeController;
  bool _inProgress = false;

  final log = Logger('RegisterTerminalPage');

  @override
  void initState() {
    super.initState();
    _terminalRepository = injector.terminalRepository;
    _terminalIdController = TextEditingController(text: const String.fromEnvironment('terminal'));
    _codeController = TextEditingController();
    _tapGestureRecognizer = TapGestureRecognizer();
    _tapGestureRecognizer.onTap = _onLinkTap;
  }

  @override
  void dispose() {
    _terminalIdController.dispose();
    _codeController.dispose();
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _onLinkTap() {
    final url = 'https://panel.staffmonitor.app/terminal/index';
    canLaunch(url).then((value) {
      launch(url);
    });
  }

  void _onSubmit() {
    if (_codeController.text.isEmpty || _terminalIdController.text.isEmpty) {
      return;
    }
    context.unFocus();
    setState(() {
      _inProgress = true;
    });
    _terminalRepository.registerTerminal(_codeController.text, _terminalIdController.text).then(
      (value) {
        if (value == true) {
          SuccessDialog.show(
            context: context,
            content: Text('Terminal registered'.i18n),
          ).then((value) {
            Dijkstra.openSplash();
          });
        }
        setState(() {
          _inProgress = false;
        });
      },
      onError: (e, stack) {
        log.shout('error register', e, stack);
        showError(e);
        setState(() {
          _inProgress = false;
        });
      },
    );
  }

  void showError(e) {
    if (e is AppError)
      FailureDialog.show(
        context: context,
        content: Text(e.formatted() ?? 'An error occurred'.i18n),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppLogoWidget(100),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, top: 16),
                    child: Text(
                      'Register device as terminal',
                      style: theme.textTheme.headline6,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    enabled: _inProgress != true,
                    controller: _terminalIdController,
                    decoration: sharedGreyInputDecoration.copyWith(
                      labelText: 'Terminal ID'.i18n,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    enabled: _inProgress != true,
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: sharedGreyInputDecoration.copyWith(
                      labelText: 'One time code'.i18n,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(20, 50),
                    ),
                    onPressed: _inProgress ? null : _onSubmit,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text('Submit'.i18n),
                        if (_inProgress) CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.subtitle1,
                      children: [
                        TextSpan(
                          text: 'You can generate ID and code at web version'.i18n,
                        ),
                      ],
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