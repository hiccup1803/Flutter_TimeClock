import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart' as log;
import 'package:staffmonitor/model/admin_nfc.dart';
import 'package:staffmonitor/model/admin_off_time.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/model/admin_task_file.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/auth_token.dart';
import 'package:staffmonitor/model/calendar_note.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/chat.dart';
import 'package:staffmonitor/model/chat_participants.dart';
import 'package:staffmonitor/model/chat_user.dart';
import 'package:staffmonitor/model/company_profile.dart';
import 'package:staffmonitor/model/device_token.dart';
import 'package:staffmonitor/model/invitation_details.dart';
import 'package:staffmonitor/model/sessions_summary.dart';
import 'package:staffmonitor/model/terminal_access.dart';
import 'package:staffmonitor/model/terminal_session.dart';
import 'package:staffmonitor/model/terminal_session_nfc.dart';
import 'package:staffmonitor/model/uploader.dart';
import 'package:staffmonitor/model/user_history.dart';
import 'package:staffmonitor/model/user_location.dart';
import 'package:staffmonitor/repository/chat_repository.dart';
import 'package:staffmonitor/repository/company_repository.dart';
import 'package:staffmonitor/repository/device_token_repository.dart';
import 'package:staffmonitor/repository/files_repository.dart' as FileRepository;
import 'package:staffmonitor/repository/files_repository.dart';
import 'package:staffmonitor/repository/invitation_repository.dart';
import 'package:staffmonitor/repository/location_repository.dart';
import 'package:staffmonitor/repository/nfc_repository.dart';
import 'package:staffmonitor/repository/off_times_repository.dart';
import 'package:staffmonitor/repository/preferences/terminal_preferences.dart';
import 'package:staffmonitor/repository/session_break_repository.dart';
import 'package:staffmonitor/repository/sessions_repository.dart';
import 'package:staffmonitor/repository/terminal_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';
import 'package:staffmonitor/service/api/admin_calendar_note_service.dart';
import 'package:staffmonitor/service/api/admin_calendar_task_service.dart';
import 'package:staffmonitor/service/api/admin_company_service.dart';
import 'package:staffmonitor/service/api/admin_file_service.dart';
import 'package:staffmonitor/service/api/admin_location_service.dart';
import 'package:staffmonitor/service/api/admin_off_times_service.dart';
import 'package:staffmonitor/service/api/admin_projects_service.dart';
import 'package:staffmonitor/service/api/admin_sessions_service.dart';
import 'package:staffmonitor/service/api/admin_task_file_service.dart';
import 'package:staffmonitor/service/api/admin_terminals_service.dart';
import 'package:staffmonitor/service/api/auth_service.dart';
import 'package:staffmonitor/service/api/calendar_note_service.dart';
import 'package:staffmonitor/service/api/calendar_task_service.dart';
import 'package:staffmonitor/service/api/chat_service.dart';
import 'package:staffmonitor/service/api/chat_users_service.dart';
import 'package:staffmonitor/service/api/converter/json_error_converter.dart';
import 'package:staffmonitor/service/api/converter/json_to_type_converter.dart';
import 'package:staffmonitor/service/api/devices_service.dart';
import 'package:staffmonitor/service/api/file_service.dart';
import 'package:staffmonitor/service/api/file_task_service.dart';
import 'package:staffmonitor/service/api/holiday_service.dart';
import 'package:staffmonitor/service/api/interceptors/auth_interceptor.dart';
import 'package:staffmonitor/service/api/interceptors/base_interceptor.dart';
import 'package:staffmonitor/service/api/invitation_service.dart';
import 'package:staffmonitor/service/api/location_service.dart';
import 'package:staffmonitor/service/api/off_time_service.dart';
import 'package:staffmonitor/service/api/profile_service.dart';
import 'package:staffmonitor/service/api/project_service.dart';
import 'package:staffmonitor/service/api/session_break_service.dart';
import 'package:staffmonitor/service/api/sessions_service.dart';
import 'package:staffmonitor/service/api/terminal_service.dart';
import 'package:staffmonitor/service/api/users_service.dart';
import 'package:staffmonitor/service/geolocation_service.dart';
import 'package:staffmonitor/service/local_database_service.dart';
import 'package:staffmonitor/service/network_status_service.dart';

import 'model/admin_terminal.dart';
import 'model/chat_message.dart';
import 'model/holiday.dart';
import 'model/invitation.dart';
import 'model/off_time.dart';
import 'model/pin.dart';
import 'model/profile.dart';
import 'model/project.dart';
import 'model/session.dart';
import 'model/session_break.dart';
import 'repository/auth_repository.dart';
import 'repository/preferences/app_preferences.dart';
import 'repository/preferences/auth_preferences.dart';
import 'repository/preferences/preference_repository.dart';
import 'repository/profile_repository.dart';
import 'repository/projects_repository.dart';
import 'service/api/admin_nfc_service.dart';
import 'service/api/registration_service.dart';
import 'service/navigation_service.dart';
import 'storage/offline_storage.dart';

final GetIt getInjector = GetIt.instance;

final Injector injector = Injector();

const String _UNAUTHORIZED_API_CLIENT = 'auth';
const String _AUTHORIZED_API_CLIENT = 'client';

void setupLogger() {
  log.Logger.root.level = kDebugMode ? log.Level.ALL : log.Level.SEVERE;
  log.Logger.root.onRecord.listen((rec) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    var allMatches = pattern.allMatches(rec.message);
    if (allMatches.length == 1) {
      print('${rec.loggerName} | ${rec.level.name}: ${rec.time}: ${allMatches.first.group(0)}');
    } else {
      print('${rec.loggerName} | ${rec.level.name}: ${rec.time}:');
      allMatches.forEach((match) => print(match.group(0)));
    }
    if (rec.error != null)
      print('${rec.loggerName} | ${rec.level.name}: ${rec.time}: Error: ${rec.error}');
    if (rec.stackTrace != null)
      print('${rec.loggerName} | ${rec.level.name}: ${rec.time}: Stack:\n${rec.stackTrace}');
  });
}

void setupLocalNotification() {
  var initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('ic_notification'),
    iOS: IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        //
      },
    ),
  );

  FlutterLocalNotificationsPlugin().initialize(
    initializationSettings,
    onSelectNotification: (payload) async {
      //
    },
  );
}

void setupDownloader() async {
  await FlutterDownloader.initialize(debug: kDebugMode);
  //without this callback it app crashes on download complete
  FlutterDownloader.registerCallback(FileRepository.downloadCallback);
}

prepareHeadlessInjector({
  required String protocol,
  required String baseDomain,
  required String apiSegment,
}) async {
  await prepareHive();
  if (!getInjector.isRegistered<OfflineStorage>()) {
    getInjector.registerSingletonAsync<OfflineStorage>(() => OfflineStorageImpl.getInstance());
  }

  if (!getInjector.isRegistered<PreferenceRepository>()) {
    getInjector.registerLazySingleton<PreferenceRepository>(() => PreferenceRepository());
  }
  if (!getInjector.isRegistered<AuthPreferences>()) {
    getInjector.registerLazySingleton<AuthPreferences>(
        () => AuthPreferences(injector.preferenceRepository));
  }
  if (!getInjector.isRegistered<ChopperClient>(instanceName: _UNAUTHORIZED_API_CLIENT)) {
    _prepareUnauthorizedClient('$protocol://$baseDomain/$apiSegment');
  }
  if (!getInjector.isRegistered<AuthRepository>()) {
    getInjector.registerLazySingleton<AuthRepository>(() => AuthRepository(
        injector._authService, injector.authPreferences, injector.appPreferences, null));
  }
  if (!getInjector.isRegistered<ChopperClient>(instanceName: _AUTHORIZED_API_CLIENT)) {
    _prepareAuthorizedClient('$protocol://$baseDomain/$apiSegment');
  }
  if (!getInjector.isRegistered<NetworkStatusService>()) {
    getInjector.registerLazySingleton<NetworkStatusService>(() => NetworkStatusService(baseDomain));
  }

  if (!getInjector.isRegistered<SessionBreakRepository>()) {
    getInjector.registerLazySingleton<SessionBreakRepository>(
      () => SessionBreakRepository(
        injector._sessionBreakService,
        injector.offlineStorage,
        injector.networkStatusService,
      ),
    );
  }
  if (!getInjector.isRegistered<SessionsRepository>()) {
    getInjector.registerLazySingleton<SessionsRepository>(
      () => SessionsRepository(
        injector._sessionsService,
        injector._adminSessionsService,
        injector.sessionBreakRepository,
        injector.offlineStorage,
        injector.networkStatusService,
      ),
    );
  }
}

void _prepareUnauthorizedClient(String baseUrl) {
  getInjector.registerLazySingleton<ChopperClient>(
    () => ChopperClient(
      baseUrl: Uri.parse(baseUrl),
      interceptors: [
        HttpLoggingInterceptor(),
      ],
      converter: JsonToTypeConverter({
        JwtToken: (json) => JwtToken.fromJson(json),
        InvitationDetails: (json) => InvitationDetails.fromJson(json),
        TerminalAccess: (json) => TerminalAccess.fromJson(json),
        TerminalSession: (json) => TerminalSession.fromJson(json),
        TerminalSessionNfc: (json) => TerminalSessionNfc.fromJson(json),
        UserHistory: (json) => UserHistory.fromJson(json),
      }),
      errorConverter: JsonErrorConverter(),
      services: [
        AuthService.create(),
        RegisterService.create(),
        TerminalService.create(),
      ],
    ),
    instanceName: _UNAUTHORIZED_API_CLIENT,
  );
}

void _prepareAuthorizedClient(String baseUrl) {
  getInjector.registerLazySingleton<ChopperClient>(
    () => ChopperClient(
      baseUrl: Uri.parse(baseUrl),
      interceptors: [
        AuthInterceptor(injector.authRepository),
        BaseInterceptor(),
        HttpLoggingInterceptor(),
      ],
      converter: JsonToTypeConverter({
        AppFile: (json) => AppFile.fromJson(json),
        AdminSessionFile: (json) => AdminSessionFile.fromJson(json),
        AdminTaskFile: (json) => AdminTaskFile.fromJson(json),
        Holiday: (json) => Holiday.fromJson(json),
        OffTime: (json) => OffTime.fromJson(json),
        AdminOffTime: (json) => AdminOffTime.fromJson(json),
        Profile: (json) => Profile.fromJson(json),
        CompanyProfile: (json) => CompanyProfile.fromJson(json),
        Project: (json) => Project.fromJson(json),
        AdminProject: (json) => AdminProject.fromJson(json),
        CurrencyExchange: (json) => CurrencyExchange.fromJson(json),
        Session: (json) => Session.fromJson(json),
        AdminSession: (json) => AdminSession.fromJson(json),
        CalendarTask: (json) => CalendarTask.fromJson(json),
        CalendarNote: (json) => CalendarNote.fromJson(json),
        SessionsSummary: (json) => SessionsSummary.fromJson(json),
        Invitation: (json) => Invitation.fromJson(json),
        Pin: (json) => Pin.fromJson(json),
        UserLocation: (json) => UserLocation.fromJson(json),
        SessionBreak: (json) => SessionBreak.fromJson(json),
        DeviceToken: (json) => DeviceToken.fromJson(json),
        ChatRoom: (json) => ChatRoom.fromJson(json),
        ChatUser: (json) => ChatUser.fromJson(json),
        ChatParticipants: (json) => ChatParticipants.fromJson(json),
        ChatMessage: (json) => ChatMessage.fromJson(json),
        AdminTerminal: (json) => AdminTerminal.fromJson(json),
        AdminNfc: (json) => AdminNfc.fromJson(json),
      }),
      errorConverter: JsonErrorConverter(),
      services: [
        AdminSessionsService.create(),
        AdminOffTimesService.create(),
        AdminProjectsService.create(),
        ProfileService.create(),
        AdminCompanyService.create(),
        ProjectService.create(),
        SessionsService.create(),
        CalendarTaskService.create(),
        AdminCalendarTaskService.create(),
        CalendarNoteService.create(),
        AdminCalendarNoteService.create(),
        HolidayService.create(),
        OffTimeService.create(),
        FileService.create(),
        AdminFileService.create(),
        AdminTaskFileService.create(),
        FileTaskService.create(),
        UsersService.create(),
        InvitationService.create(),
        LocationService.create(),
        AdminLocationService.create(),
        SessionBreakService.create(),
        DeviceService.create(),
        ChatService.create(),
        ChatUserService.create(),
        AdminTerminalsService.create(),
        AdminNfcService.create(),
      ],
    ),
    instanceName: _AUTHORIZED_API_CLIENT,
  );
}

Future prepareHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(SessionAdapter());
  Hive.registerAdapter(SessionBreakAdapter());
  Hive.registerAdapter(AppFileAdapter());
  Hive.registerAdapter(UploaderAdapter());
}

Future prepareInjector({
  required String protocol,
  required String baseDomain,
  required String apiSegment,
}) async {
  assert(protocol.isNotEmpty);
  assert(apiSegment.isNotEmpty);
  assert(baseDomain.isNotEmpty);

  await prepareHive();

  getInjector.registerSingletonAsync<OfflineStorage>(() => OfflineStorageImpl.getInstance());

  getInjector.registerLazySingleton<NavigationService>(() => NavigationService());
  getInjector.registerLazySingleton<PreferenceRepository>(() => PreferenceRepository());
  getInjector.registerLazySingleton<NetworkStatusService>(() => NetworkStatusService(baseDomain));
  getInjector
      .registerLazySingleton<AppPreferences>(() => AppPreferences(injector.preferenceRepository));
  getInjector
      .registerLazySingleton<AuthPreferences>(() => AuthPreferences(injector.preferenceRepository));
  getInjector.registerLazySingleton<TerminalPreferences>(
      () => TerminalPreferences(injector.preferenceRepository));

  _prepareUnauthorizedClient('$protocol://$baseDomain/$apiSegment');
  _prepareAuthorizedClient('$protocol://$baseDomain/$apiSegment');

  getInjector.registerLazySingleton<AuthRepository>(
    () => AuthRepository(injector._authService, injector.authPreferences, injector.appPreferences,
        injector.networkStatusService),
  );

  getInjector.registerLazySingleton<GeolocationService>(() => GeolocationService(
        injector.authRepository,
        // locationUrl: 'https://enezgh8xkpxh10n.m.pipedream.net',
        locationUrl: '$protocol://$baseDomain/$apiSegment/locations',
      ));

  getInjector.registerSingleton('$protocol://$baseDomain/$apiSegment/locations',
      instanceName: 'locationUrl');

  getInjector.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(
      injector._profileService,
      injector.offlineStorage,
      injector.networkStatusService,
    ),
  );
  getInjector.registerLazySingleton<CompanyRepository>(
    () => CompanyRepository(
      injector._profileCompanyService,
      injector.preferenceRepository,
      injector.networkStatusService,
    ),
  );
  getInjector.registerLazySingleton<SessionsRepository>(
    () => SessionsRepository(
      injector._sessionsService,
      injector._adminSessionsService,
      injector.sessionBreakRepository,
      injector.offlineStorage,
      injector.networkStatusService,
    ),
  );
  getInjector.registerLazySingleton<OffTimesRepository>(
    () => OffTimesRepository(
      injector._offTimeService,
      injector._adminOffTimesService,
    ),
  );
  getInjector.registerLazySingleton<ChatRepository>(
    () => ChatRepository(
      injector._chatService,
      injector._chatUserService,
    ),
  );
  getInjector.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepository(
      injector._projectService,
      injector._adminProjectsService,
      injector._sessionsService,
      injector._calendarService,
      injector._adminCalendarService,
      injector._calendarNoteService,
      injector._adminCalendarNoteService,
      injector.appPreferences,
    ),
  );
  getInjector.registerLazySingleton<FilesRepository>(() => FilesRepository(
      '$protocol://$baseDomain/$apiSegment/files',
      '$protocol://$baseDomain/$apiSegment/task-files',
      '$protocol://$baseDomain/$apiSegment/admin-files',
      '$protocol://$baseDomain/$apiSegment/admin-task-files',
      '$protocol://$baseDomain/$apiSegment/terminal-photos',
      injector.authRepository,
      injector._fileService,
      injector._adminSessionFileService,
      injector._adminTaskFileService,
      injector._fileTaskService,
      FlutterUploader()));

  getInjector.registerLazySingleton<InvitationRepository>(
      () => InvitationRepository(injector._invitationService));

  getInjector.registerLazySingleton<UsersRepository>(() => UsersRepository(injector._usersService));

  getInjector.registerLazySingleton<TerminalRepository>(
    () => TerminalRepository(
      injector._terminalPreferences,
      injector._terminalService,
      injector._adminTerminalService,
    ),
  );

  getInjector.registerLazySingleton<NfcRepository>(
    () => NfcRepository(
      injector._adminNfcService,
    ),
  );

  getInjector.registerLazySingleton<LocationRepository>(
      () => LocationRepository(injector._locationService, injector._adminLocationService));

  getInjector.registerLazySingleton<SessionBreakRepository>(() => SessionBreakRepository(
        injector._sessionBreakService,
        injector.offlineStorage,
        injector.networkStatusService,
      ));

  getInjector.registerLazySingleton<DeviceTokenRepository>(
      () => DeviceTokenRepository(injector._deviceService));

  getInjector.registerSingleton(AppDatabase());

  return getInjector.allReady();
}

class Injector {
  OfflineStorage get offlineStorage => getInjector.get<OfflineStorage>();

  NavigationService get navigationService => getInjector.get<NavigationService>();

  AppDatabase get appDatabase => getInjector.get<AppDatabase>();

  AppPreferences get appPreferences => getInjector.get<AppPreferences>();

  AuthPreferences get authPreferences => getInjector.get<AuthPreferences>();

  TerminalPreferences get _terminalPreferences => getInjector.get<TerminalPreferences>();

  ChopperClient get _authorizedClient =>
      getInjector.get<ChopperClient>(instanceName: _AUTHORIZED_API_CLIENT);

  ChopperClient get _unauthorizedClient =>
      getInjector.get<ChopperClient>(instanceName: _UNAUTHORIZED_API_CLIENT);

  RegisterService get registrationService => _unauthorizedClient.getService<RegisterService>();

  AuthService get _authService => _unauthorizedClient.getService<AuthService>();

  AuthRepository get authRepository => getInjector.get<AuthRepository>();

  ProfileService get _profileService => _authorizedClient.getService<ProfileService>();

  AdminCompanyService get _profileCompanyService =>
      _authorizedClient.getService<AdminCompanyService>();

  ProfileRepository get profileRepository => getInjector.get<ProfileRepository>();

  PreferenceRepository get preferenceRepository => getInjector.get<PreferenceRepository>();

  CompanyRepository get profileCompanyRepository => getInjector.get<CompanyRepository>();

  SessionsService get _sessionsService => _authorizedClient.getService<SessionsService>();

  SessionBreakService get _sessionBreakService =>
      _authorizedClient.getService<SessionBreakService>();

  CalendarTaskService get _calendarService => _authorizedClient.getService<CalendarTaskService>();

  AdminCalendarTaskService get _adminCalendarService =>
      _authorizedClient.getService<AdminCalendarTaskService>();

  CalendarNoteService get _calendarNoteService =>
      _authorizedClient.getService<CalendarNoteService>();

  AdminCalendarNoteService get _adminCalendarNoteService =>
      _authorizedClient.getService<AdminCalendarNoteService>();

  AdminSessionsService get _adminSessionsService =>
      _authorizedClient.getService<AdminSessionsService>();

  AdminProjectsService get _adminProjectsService =>
      _authorizedClient.getService<AdminProjectsService>();

  AdminOffTimesService get _adminOffTimesService =>
      _authorizedClient.getService<AdminOffTimesService>();

  SessionsRepository get sessionsRepository => getInjector.get<SessionsRepository>();

  SessionBreakRepository get sessionBreakRepository => getInjector.get<SessionBreakRepository>();

  ProjectService get _projectService => _authorizedClient.getService<ProjectService>();

  ProjectsRepository get projectsRepository => getInjector.get<ProjectsRepository>();

  OffTimeService get _offTimeService => _authorizedClient.getService<OffTimeService>();

  OffTimesRepository get offTimesRepository => getInjector.get<OffTimesRepository>();

  ChatService get _chatService => _authorizedClient.getService<ChatService>();

  ChatUserService get _chatUserService => _authorizedClient.getService<ChatUserService>();

  ChatRepository get chatRepository => getInjector.get<ChatRepository>();

  FileService get _fileService => _authorizedClient.getService<FileService>();

  AdminFileService get _adminSessionFileService => _authorizedClient.getService<AdminFileService>();

  AdminTaskFileService get _adminTaskFileService =>
      _authorizedClient.getService<AdminTaskFileService>();

  FileTaskService get _fileTaskService => _authorizedClient.getService<FileTaskService>();

  FilesRepository get filesRepository => getInjector.get<FilesRepository>();

  InvitationService get _invitationService => _authorizedClient.getService<InvitationService>();

  InvitationRepository get invitationRepository => getInjector.get<InvitationRepository>();

  UsersService get _usersService => _authorizedClient.getService<UsersService>();

  UsersRepository get usersRepository => getInjector.get<UsersRepository>();

  TerminalService get _terminalService => _unauthorizedClient.getService<TerminalService>();

  AdminTerminalsService get _adminTerminalService =>
      _authorizedClient.getService<AdminTerminalsService>();

  AdminNfcService get _adminNfcService => _authorizedClient.getService<AdminNfcService>();

  TerminalRepository get terminalRepository => getInjector.get<TerminalRepository>();

  NfcRepository get nfcRepository => getInjector.get<NfcRepository>();

  NetworkStatusService get networkStatusService => getInjector.get<NetworkStatusService>();

  GeolocationService get geolocationService => getInjector.get<GeolocationService>();

  LocationService get _locationService => _authorizedClient.getService<LocationService>();

  DeviceService get _deviceService => _authorizedClient.getService<DeviceService>();

  AdminLocationService get _adminLocationService =>
      _authorizedClient.getService<AdminLocationService>();

  LocationRepository get locationRepository => getInjector.get<LocationRepository>();

  DeviceTokenRepository get deviceTokenRepository => getInjector.get<DeviceTokenRepository>();
}
