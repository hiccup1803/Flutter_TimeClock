import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/auth_token.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/repository/auth_repository.dart';
import 'package:staffmonitor/repository/sessions_repository.dart';

import 'api/interceptors/auth_interceptor.dart';
import 'geolocation.i18n.dart';

void headlessTask(bg.HeadlessEvent event) async {
  if (event.name == bg.Event.HTTP) {
    print('headlessTask: onHttp');
    final httpEvent = event.event as bg.HttpEvent;
    print('headlessTask: onHttp: ${httpEvent.responseText}');
    if (httpEvent.status == 401) {
      prepareHeadlessInjector(
        protocol: 'https',
        baseDomain: 'panel.staffmonitor.app',
        apiSegment: 'api',
      );
      _updateAuth(injector.authRepository);
    }
  }
}

void _updateAuth(AuthRepository authRepository) async {
  AuthToken? jwtToken = await authRepository.getValidAuthTokenOrRefresh();
  if (jwtToken != null) {
    bg.BackgroundGeolocation.setConfig(
      bg.Config(
        headers: {
          AuthInterceptor.AUTH_HEADER: jwtToken.bearerToken,
        },
      ),
    );
  }
}

void _updateSessionId(Session session) async {
  await bg.BackgroundGeolocation.setConfig(bg.Config(
    extras: {
      'sessionId': '${session.id}',
      'uuid': await _getId(),
    },
    autoSync: false,
  )).then((value) async {
    print('_updateSessionId: 1 extras ${value.extras}, autoSync: ${value.autoSync}');
  });
  if (session.clockIn != null) {
    await bg.BackgroundGeolocation.locations.then((locations) {
      locations.forEach((element) async {
        String timestamp = element['timestamp'];
        if (DateTime.parse(timestamp).isBefore(session.clockIn!)) {
          print('_updateSessionId: 1.5 destroy Location');
          await bg.BackgroundGeolocation.destroyLocation(element['uuid']);
        }
      });
    });
  }
  await bg.BackgroundGeolocation.setConfig(bg.Config(
    autoSync: true,
  )).then((value) async {
    print('_updateSessionId: end extras ${value.extras}, autoSync: ${value.autoSync}');
  });
}

class GeolocationService {
  GeolocationService(
    this._authRepository, {
    required this.locationUrl,
  });

  final _log = Logger('GeolocationService');
  final AuthRepository _authRepository;
  final String locationUrl;

  Future init() async {
    _log.fine('GeolocationService: url: $locationUrl');
    bg.BackgroundGeolocation.onHttp((bg.HttpEvent response) {
      int status = response.status;
      bool success = response.success;
      String responseText = response.responseText;
      if (response.status == 401) {
        _updateAuth(_authRepository);
      } else if (response.success == false && response.responseText.contains('LOC-SESS-REQ')) {
        _log.fine('onHttp2: response.success false & LOC-SESS-REQ');
        SessionsRepository sessionsRepository = injector.sessionsRepository;
        sessionsRepository.currentSession().then(
          (value) async {
            final bgState = await bg.BackgroundGeolocation.state;
            if (value?.id != null && bgState.extras?['sessionId'] == null) {
              _updateSessionId(value!);
            } else {
              _log.fine('onHttp2: no session id');
              bg.BackgroundGeolocation.stop();
              bg.BackgroundGeolocation.destroyLocations();
            }
          },
        );
      }
      _log.fine('onHttp status: $status, success? $success, responseText: $responseText');
    });
    // Fired whenever a location is recorded
    final token = await _authRepository.getJwtToken();
    bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
    await bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 600,
        // 3 minutes in milliseconds
        locationUpdateInterval: 3 * 60 * 1000,
        // 1 minute in milliseconds
        fastestLocationUpdateInterval: 60 * 1000,
        stopOnTerminate: false,
        startOnBoot: true,
        url: locationUrl,
        headers: {
          AuthInterceptor.AUTH_HEADER: token?.bearerToken,
        },
        useSignificantChangesOnly: Platform.isIOS ? true : false,
        enableHeadless: true,
        maxRecordsToPersist: -1,
        locationTemplate: '''{
          "event": "<%=event%>",
          "isMoving": <%=is_moving%>,
          "timestamp": "<%=timestamp%>",
          "odometer": <%=odometer%>,
          "latitude": <%=latitude%>,
          "longitude": <%=longitude%>,
          "accuracy": <%=accuracy%>,
          "speed": <%=speed%>,
          "speedAccuracy": <%=speed_accuracy%>,
          "heading": <%=heading%>,
          "headingAccuracy": <%=heading_accuracy%>,
          "altitude": <%=altitude%>,
          "altitudeAccuracy": <%=altitude_accuracy%>,
          "activityType": "<%=activity.type%>",
          "activityConfidence": <%=activity.confidence%>,
          "batteryIsCharging": <%=battery.is_charging%>,
          "batteryLevel": <%=battery.level%>
        }''',
        httpRootProperty: '.',
        autoSync: true,
        maxDaysToPersist: 14,
        locationAuthorizationRequest: 'Always',
        backgroundPermissionRationale: bg.PermissionRationale(
          title: "Allow Staff Monitor to access to this device's location in the background?".i18n,
          message:
              "In order to track your activity efficiently, please enable 'Allow all the time' location permission."
                  .i18n,
          positiveAction: "Change to 'Allow all the time'".i18n,
          negativeAction: "Cancel".i18n,
        ),
        locationAuthorizationAlert: {
          'titleWhenNotEnabled': 'Background location is not enabled'.i18n,
          'titleWhenOff': 'Location is not enabled'.i18n,
          'instructions':
              'To use background location, you must enable \'Always\' in the Location Services settings.'
                  .i18n,
          'cancelButton': 'Cancel'.i18n,
          'settingsButton': 'Settings'.i18n
        },
        notification: bg.Notification(
          title: 'Updating location...'.i18n,
          text: 'Tap here to open app'.i18n,
          channelName: 'Ongoing Session',
          smallIcon: 'drawable/ic_notification',
        ),
        logLevel: kDebugMode ? bg.Config.LOG_LEVEL_INFO : bg.Config.LOG_LEVEL_ERROR,
      ),
    ).then((value) {
      _log.fine('onConfig $value');
    });
    _authRepository.authTokenStream.listen(updateAuthorization);
  }

  Future updateAuthorization(AuthToken? token) async {
    _log.fine('updateAuthorization $token');
    if (token != null) {
      _updateAuth(_authRepository);
    }
  }

  Future<bool> requestPermission() {
    return bg.BackgroundGeolocation.requestPermission().then((value) async {
      var providerState = await bg.BackgroundGeolocation.providerState;
      if (providerState.accuracyAuthorization !=
          bg.ProviderChangeEvent.ACCURACY_AUTHORIZATION_FULL) {
        await Permission.location.request();
      }

      return providerState.status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS &&
          providerState.accuracyAuthorization == bg.ProviderChangeEvent.ACCURACY_AUTHORIZATION_FULL;
    });
  }

  Future<bool> hasPermission({bool? always = true}) {
    return bg.BackgroundGeolocation.providerState.then((value) async {
      return value.status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS &&
          value.accuracyAuthorization == bg.ProviderChangeEvent.ACCURACY_AUTHORIZATION_FULL;
    });
  }

  Future<bool> isTracking() async {
    final state = await bg.BackgroundGeolocation.state;
    return state.enabled;
  }

  Future<bg.Location> updateLocationNow() async {
    return bg.BackgroundGeolocation.getCurrentPosition();
  }

  Future startTracking({bool resetOdometer = false}) async {
    _log.fine('startTracking');
    try {
      int status = await bg.BackgroundGeolocation.requestPermission();
      if (status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS) {
        _log.fine("[requestPermission] Authorized Always $status");
        if (resetOdometer == true) {
          await bg.BackgroundGeolocation.setOdometer(0);
        }
        await bg.BackgroundGeolocation.setConfig(bg.Config(
          extras: {
            'uuid': await _getId(),
          },
        ));
        await bg.BackgroundGeolocation.start();
      } else if (status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_WHEN_IN_USE) {
        _log.fine("[requestPermission] Authorized WhenInUse: $status");
      }
    } catch (error) {
      _log.fine("[requestPermission] DENIED: $error");
    }
    bg.BackgroundGeolocation.state.then((value) {
      _log.fine('startForegroundService: is running? ${value.enabled == true ? 'yes' : 'no'}');
    });
  }

  Future stopTracking() async {
    _log.fine('stopTracking');
    if (await isTracking()) {
      bg.BackgroundGeolocation.odometer.then((value) => _log.fine('Odometer on stop: $value'));
      if ((await bg.BackgroundGeolocation.locations).isNotEmpty) {
        try {
          await bg.BackgroundGeolocation.sync().then((value) {
            _log.fine('stopTracking: sync: $value');
          });
        } catch (e) {
          print('stopTracking: $e');
        }
      }
      await bg.BackgroundGeolocation.stop().then((value) {
        _log.fine('stopTracking: stop: $value');
      });
      await bg.BackgroundGeolocation.destroyLocations().then((value) {
        _log.fine('stopTracking: destroyLocations: $value');
      });
      await bg.BackgroundGeolocation.setConfig(bg.Config(
        extras: {},
      ));
      bg.BackgroundGeolocation.state.then((value) {
        _log.fine('stopTracking: ${value.enabled}');
      });
    }
  }
}

Future<String?> _getId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.id; // unique ID on Android
  }
}
