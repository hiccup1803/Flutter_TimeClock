import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:adv_camera/adv_camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:staffmonitor/bloc/connect/connect_status_cubit.dart';
import 'package:staffmonitor/bloc/files/file_upload_cubit.dart';
import 'package:staffmonitor/bloc/kiosk/nfc_reader/nfc_reader_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/terminal_session_nfc.dart';
import 'package:staffmonitor/model/user_history.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/terminal/user_action_info_widget.dart';
import 'package:staffmonitor/repository/terminal_repository.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/app_logo_widget.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';
import 'package:staffmonitor/widget/dialog/text_input_dialog.dart';
import 'package:staffmonitor/widget/numeric_keyboard_widget.dart';
import 'package:staffmonitor/widget/time_widget.dart';
import 'package:wakelock/wakelock.dart';

import 'terminal.i18n.dart';

class TerminalPage extends StatefulWidget {
  @override
  _TerminalPageState createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final log = Logger('TerminalPage');

  late TerminalRepository _terminalRepository;
  String _photoPath = '', _photoName = '';
  String _code = '';
  String _nfcTagId = '';
  String _terminalName = '';
  String _companyName = '';
  bool _inProgress = false;
  bool _useQR = false;
  CameraFacing _cameraFacing = CameraFacing.front;
  QRViewController? _cameraController;
  final GlobalKey _key = GlobalKey();
  int _seconds = 3;
  Timer? _timer;
  UserHistory? _userHistory;
  TerminalSessionNfc? _terminalSessionNfc;
  final int _dot = "•".codeUnits[0];

  String get _maskedCode => String.fromCharCodes(List.generate(_code.length, (i) => _dot));

  late AdvCameraController cameraController;
  List<String> pictureSizes = <String>[];

  var _streams = <StreamSubscription?>[];

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _terminalRepository = injector.terminalRepository;
    _terminalRepository.getTerminalName().then((value) {
      setState(() {
        _terminalName = value;
      });
    });
    _terminalRepository.getCompanyName().then((value) {
      setState(() {
        _companyName = value;
      });
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => BlocProvider.of<NfcReaderCubit>(context).startNfc());

    _streams.add(BlocProvider.of<NfcReaderCubit>(context).onNewTag.listen((event) {
      _nfcTagId = event;
      _onNewNfcTag();
    }));
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController?.dispose();
    for (var item in _streams) {
      item?.cancel();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _cameraController?.dispose();
    _cameraController = controller;
    _cameraController?.scannedDataStream.listen((Barcode scanData) async {
      if (_code.isNotEmpty != true) {
        log.fine('scanner result: ${scanData.format}, ${scanData.code}');
        _cameraController?.pauseCamera();
        await FlutterBeep.beep(false);
        _scannerCallback(scanData.code);
      }
    });
  }

  void _toggleScanner() {
    setState(() {
      _code = '';
      _nfcTagId = '';
      _useQR = !_useQR;
    });
  }

  void _scannerCallback(String? result) {
    if (result == null) return;

    if (result.isNotEmpty) {
      setState(() {
        _code = result;
      });
      if (_code.length >= 4) {
        _onSubmit();
      } else {
        _reset();
      }
    }
  }

  void _onKey(String value) {
    setState(() {
      _code += value;
    });
  }

  void _onClear() {
    setState(() {
      _code = '';
      _nfcTagId = '';
    });
  }

  void _onSubmit() {
    setState(() {
      _inProgress = true;
    });
    _terminalRepository.getUserHistory(_code).then(
      (value) {
        _userHistory = value;
        _startTimer(_performSessionAction);
        setState(() {
          _inProgress = false;
        });
      },
      onError: (e, stack) {
        setState(() {
          _inProgress = false;
        });
        showError(e);
      },
    );
  }

  void _startTimer(Function action, {int seconds = 4}) {
    _seconds = seconds;
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (_seconds - 1 < -1) {
          _timer?.cancel();
          if (_userHistory!.photoVerification == 1 &&
              _userHistory!.currentSessionStartedAt == null) {
            _takeScreenshot();
          }
          Future.delayed(Duration(seconds: 1)).then((value) {
            action.call();
          });
        } else if (_seconds - 1 < 1) {
          setState(() {
            _seconds--;
            _inProgress = true;
          });
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );
  }

  Future<void> _performSessionAction() async {
    final id = await _terminalRepository.getTerminalId();
    if (_userHistory != null && _code.isNotEmpty) {
      setState(
        () {
          _inProgress = true;
          Future.delayed(Duration(seconds: 2)).then((value) {
            _terminalRepository.toggleSession(_code).then((value) async {
              try {
                if (value.clockId != null) {
                  final size = await File(_photoPath).length();

                  PlatformFile result =
                      PlatformFile(path: _photoPath, size: size, name: _photoName);

                  BlocProvider.of<FileUploadCubit>(context)
                      .uploadFile(result, clockId: value.clockId, pin: _code, terminalId: id);
                  _photoPath = '';
                  _photoName = '';
                }
              } catch (e) {
                debugPrint('_TerminalPageState._performSessionAction: error $e');
              }
              _reset();
            }, onError: (e, stack) {
              setState(() {
                _inProgress = false;
              });
              showError(e);
            });
          });
        },
      );
    }
  }

  void _onNewNfcTag() {
    _inProgress = true;
    setState(() {});
    _terminalRepository.toggleSessionNfc(_nfcTagId).then((value) async {
      await FlutterBeep.beep(false);
      if (value.hasNfc) {
        SuccessDialog.show(
          context: context,
          content: Text('Checked'.i18n),
          autoHideDuration: Duration(seconds: 3),
        ).then((value) {
          _reset();
        });
      } else {
        _terminalSessionNfc = value;
        setState(() {});
        Future.delayed(Duration(seconds: 3), () => _reset());
      }
    }, onError: (e, stack) {
      setState(() {
        _inProgress = false;
      });
      showError(e);
    });
  }

  void _takeScreenshot() async {
    cameraController.captureImage(maxSize: 480);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _userHistory = null;
      _terminalSessionNfc = null;
      _code = '';
      _nfcTagId = '';
      _inProgress = false;
      if (_useQR) {
        _cameraController?.resumeCamera();
      }
    });
  }

  void showError(e) {
    if (e is AppError)
      FailureDialog.show(
        context: context,
        content: Text(e.formatted() ?? 'An error occurred'.i18n),
      ).then((value) {
        _reset();
      });
  }

  void _tryLogout() {
    TextInputDialog.show(
      context: context,
      hint: 'Type one time code to deactivate this terminal'.i18n,
      inputType: TextInputType.number,
    ).then((value) {
      if (value != null) {
        setState(() {
          _inProgress = true;
        });
        _logout(value);
      }
    });
  }

  void _logout(String code) {
    _terminalRepository.logoutTerminal(code).then(
      (value) {
        if (value == true) {
          Dijkstra.openSplash();
        } else {
          _reset();
        }
      },
      onError: (e, stack) {
        showError(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    bool horizontal = false;
    if (screenSize.width > screenSize.height) {
      horizontal = true;
    }
    return horizontal ? buildHorizontalView() : buildPortraitView();
  }

  Widget _nfcSessionView() {
    return Center(
      child: Builder(builder: (context) {
        var size = MediaQuery.of(context).size;
        var minSize = min(size.width, size.height);
        return Container(
          width: minSize * 0.65,
          height: minSize * 0.55,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 8),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _terminalSessionNfc!.userName ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 24),
              Text(
                _terminalSessionNfc!.sessionStatus?.toUpperCase() ?? '',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildPortraitView() {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            AppLogoWidget.small(),
            Expanded(
              child: Text(
                _terminalName,
                style: TextStyle(color: Colors.black87),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TimeWidget(
                builder: (context, formattedTime) => Text(
                  formattedTime,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: kToolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                _companyName,
                style: theme.textTheme.caption?.copyWith(color: Colors.black38),
              ),
            ),
            Spacer(),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.power_settings_new,
                  size: 24,
                ),
              ),
              onTap: _tryLogout,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _terminalSessionNfc != null
            ? _nfcSessionView()
            : Stack(
                fit: StackFit.passthrough,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Spacer(),
                      if (_userHistory == null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 8,
                            child: _inProgress ? LinearProgressIndicator() : null,
                          ),
                        ),
                      if (_userHistory == null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _maskedCode,
                              style: TextStyle(
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                      if (_userHistory == null && _useQR == false)
                        NumericKeyboardWidget(
                          enabled: _inProgress != true,
                          onKey: _onKey,
                          onSubmit: _onSubmit,
                          onClear: _onClear,
                        ),
                      if (_userHistory == null && _useQR == true)
                        Expanded(
                          flex: 4,
                          child: _buildCameraPreview(context, true),
                        ),
                      if (_userHistory == null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(minimumSize: Size(50, 50)),
                              onPressed: _inProgress != true ? _toggleScanner : null,
                              icon: Icon(Icons.qr_code),
                              label: Text(_useQR ? 'Use pin'.i18n : 'Scan QR'.i18n),
                            ),
                          ),
                        ),
                      if (_userHistory != null)
                        Expanded(
                          flex: _userHistory!.photoVerification == 1 &&
                                  _userHistory!.currentSessionStartedAt == null
                              ? 4
                              : 1,
                          child: userActionInfoWidget(_userHistory!, theme),
                        ),
                      if (_userHistory != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              textStyle: TextStyle(fontSize: 18),
                              minimumSize: Size(50, 50),
                            ),
                            onPressed: _inProgress ? null : _reset,
                            child: Text('Cancel'.i18n),
                          ),
                        ),
                      Spacer(),
                    ],
                  ),
                  networkStatusBuilder(),
                ],
              ),
      ),
    );
  }

  Widget buildHorizontalView() {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: _terminalSessionNfc != null
            ? _nfcSessionView()
            : Stack(
                fit: StackFit.passthrough,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                AppLogoWidget.small(),
                                Expanded(
                                  child: Text(
                                    _terminalName,
                                    style: theme.textTheme.headline6,
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: TimeWidget(
                                builder: (context, formattedTime) => Text(
                                  formattedTime,
                                  style: theme.textTheme.headline6,
                                ),
                              ),
                            ),
                            Spacer(),
                            Center(
                              child: Text(
                                _maskedCode,
                                style: TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                            ),
                            Spacer(),
                            Center(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(minimumSize: Size(50, 50)),
                                onPressed: (_inProgress != true && _userHistory == null)
                                    ? _toggleScanner
                                    : null,
                                icon: Icon(Icons.qr_code),
                                label: Text(_useQR ? 'Use pin'.i18n : 'Scan QR'.i18n),
                              ),
                            ),
                            Spacer(flex: 2),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(
                                    Icons.power_settings_new,
                                    size: 24,
                                  ),
                                ),
                                onTap: _tryLogout,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_userHistory == null && _useQR == false)
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: NumericKeyboardWidget(
                                enabled: _inProgress != true && _userHistory == null,
                                onKey: _onKey,
                                onSubmit: _onSubmit,
                                onClear: _onClear,
                              ),
                            ),
                          ),
                        ),
                      if (_userHistory == null && _useQR == true)
                        Expanded(
                          flex: 2,
                          child: _buildCameraPreview(context, true),
                        ),
                      if (_userHistory != null)
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              UserActionInfoWidget(
                                userHistory: _userHistory!,
                                inProgress: _inProgress,
                                countDownSeconds: _seconds,
                              ),
                              buildCancelButton(),
                            ],
                          ),
                        )
                    ],
                  ),
                  networkStatusBuilder(),
                ],
              ),
      ),
    );
  }

  Widget buildCancelButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        textStyle: TextStyle(fontSize: 18),
        minimumSize: Size(50, 50),
      ),
      onPressed: _inProgress ? null : _reset,
      child: Text('Cancel'.i18n),
    );
  }

  Widget userActionInfoWidget(UserHistory userHistory, ThemeData theme) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            userHistory.username,
            style: theme.textTheme.headline5,
          ),
          SizedBox(height: 10.0),
          if (userHistory.currentSessionStartedAt != null)
            Text(
              'Work time'.i18n,
              style: theme.textTheme.headline4,
            ),
          if (userHistory.currentSessionStartedAt != null)
            Text(
              DateTime.now()
                  .difference(userHistory.currentSessionStartedAt!)
                  .formatHoursMinutesSeconds,
              style: theme.textTheme.headline6,
            ),
          if (userHistory.photoVerification == 1 && userHistory.currentSessionStartedAt == null)
            Expanded(
              child: AdvCamera(
                initialCameraType: CameraType.front,
                onCameraCreated: _onCameraCreated,
                fileNamePrefix: 'CLOCK',
                onImageCaptured: (String path) async {
                  _photoName =
                      'CLOCK_${userHistory.username}_${DateFormat("yyyy-MM-dd${'_'}HH-mm-ss").format(DateTime.now())}';

                  await ImageGallerySaver.saveFile(path, name: _photoName, isReturnPathOfIOS: true);

                  if (Platform.isAndroid) {
                    _photoPath = '/storage/emulated/0/Pictures/$_photoName.jpg';
                  } else if (Platform.isIOS) {
                    _photoPath = path;
                  }
                },
                cameraSessionPreset: CameraSessionPreset.medium,
                cameraPreviewRatio: CameraPreviewRatio.r11_9,
                focusRectColor: Colors.purple,
                focusRectSize: 200,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 8,
              child: _inProgress ? LinearProgressIndicator() : null,
            ),
          ),
          if (userHistory.currentSessionStartedAt != null)
            Card(
              color: theme.primaryColorDark,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Your session will end in %ds'.i18n.fill([_seconds > 0 ? _seconds : 0]),
                  style: theme.textTheme.headline6?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          if (userHistory.currentSessionStartedAt == null)
            Card(
              color: AppColors.positiveGreen,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Your session will start in %ds'.i18n.fill([_seconds > 0 ? _seconds : 0]),
                  style: theme.textTheme.headline6?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _onCameraCreated(AdvCameraController controller) {
    this.cameraController = controller;

    this.cameraController.getPictureSizes().then((pictureSizes) {
      setState(() {
        this.pictureSizes = pictureSizes ?? <String>[];
      });
    });
  }

  Widget networkStatusBuilder() {
    return BlocBuilder<ConnectStatusCubit, bool>(
      builder: (context, connectionAvailable) {
        if (connectionAvailable) return Container();
        return SizedBox.expand(
          child: Container(
            color: Colors.black38,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'No Internet'.i18n,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraPreview(BuildContext context, bool isShow) {
    return RepaintBoundary(
      key: _key,
      child: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            cameraFacing: _cameraFacing,
          ),
          if (isShow)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.flip_camera_android,
                  color: Colors.white,
                ),
                onPressed: () => _cameraController?.flipCamera().then((value) {
                  setState(() {
                    _cameraFacing = value;
                  });
                }),
              ),
            )
        ],
      ),
    );
  }
}
