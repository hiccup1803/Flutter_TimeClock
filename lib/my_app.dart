import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/connect/connect_status_cubit.dart';
import 'package:staffmonitor/bloc/kiosk/nfc_reader/nfc_reader_cubit.dart';
import 'package:staffmonitor/bloc/notifications/notifications_cubit.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/uploader.dart';

import 'bloc/files/file_upload_cubit.dart';
import 'dijkstra.dart' as dijkstra;
import 'injector.dart';

class MyApp extends StatelessWidget {
  MyApp(this._themeData);

  final ThemeData? _themeData;
  final HeroController heroController = HeroController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
              injector.authRepository, injector.profileRepository, injector.geolocationService)
            ..init(),
        ),
        BlocProvider<FileUploadCubit>(
          lazy: false,
          create: (context) => FileUploadCubit(injector.filesRepository)..init(),
        ),
        BlocProvider<ConnectStatusCubit>(
          create: (context) => ConnectStatusCubit(injector.networkStatusService)..init(),
          lazy: false,
        ),
        BlocProvider<NotificationsCubit>(
          create: (context) => NotificationsCubit(),
          lazy: false,
        ),
        BlocProvider<NfcReaderCubit>(
          create: (context) => NfcReaderCubit(),
        ),
      ],
      child: MaterialAppWrapper(_themeData),
    );
  }
}

class MaterialAppWrapper extends StatefulWidget {
  MaterialAppWrapper(this._themeData);

  final ThemeData? _themeData;

  @override
  State<MaterialAppWrapper> createState() => _MaterialAppWrapperState();
}

class _MaterialAppWrapperState extends State<MaterialAppWrapper> with WidgetsBindingObserver {
  final HeroController heroController = HeroController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        //do not delegate a background upload handler
        clearUploaderBackground();
        break;
      case AppLifecycleState.paused:
        //set background upload handler when file cubit can't handle this
        setupUploaderBackground();
        break;
      default:
        break;
    }
  }

  final _log = Logger('MaterialAppWrapper');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        _log.fine('buildWhen [${previous != current}] previous: $previous, current: $current');

        return previous != current;
      },
      builder: (context, authState) {
        _log.fine('build localeState: ${authState.locale}');
        return BlocListener<NotificationsCubit, NotificationsState>(
          listener: (context, state) {
            if (authState is! AuthAuthorized) {
              return;
            }
            if (state is NotificationsOpenTask) {
              Dijkstra.editTask(CalendarTask.withId(state.taskId), null);
            } else if (state is NotificationsShowDialog) {
              // Display an alert with the "message" payload value
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(state.title),
                    content: Text(state.body),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: MaterialApp(
            title: 'StaffMonitor',
            debugShowCheckedModeBanner: false,
            theme: widget._themeData,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', 'US'),
              Locale('pl', 'PL'),
            ],
            locale: authState.locale,
            navigatorObservers: [heroController],
            navigatorKey: injector.navigationService.navigatorKey,
            onGenerateRoute: dijkstra.generateRoute,
            initialRoute: dijkstra.SPLASH_ROUTE,
          ),
        );
      },
    );
  }
}
