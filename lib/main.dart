import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  setupLogger();
  setupDownloader();
  setupLocalNotification();

  await prepareInjector(
    protocol: 'https',
    baseDomain: 'panel.staffmonitor.app',
    apiSegment: 'api',
  );
  Pushy.listen();

  await injector.geolocationService.init();
  final theme = ThemeData(
    primaryColor: AppColors.primary,
    primaryColorLight: AppColors.primaryLight,
    brightness: Brightness.light,
    colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
    scaffoldBackgroundColor: Color.fromRGBO(249, 250, 252, 1),
    splashColor: AppColors.primary.withOpacity(0.2),
    focusColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    buttonTheme: const ButtonThemeData(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: const Color(0xFFC21717),
      selectionColor: const Color(0xFFC21717).withOpacity(0.2),
      selectionHandleColor: const Color(0xFFC21717),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Color(0xFF3A3A3A)),
      actionsIconTheme: IconThemeData(color: Color(0xFF3A3A3A)),
      iconTheme: IconThemeData(
        color: Color(0xFF3A3A3A),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
    ),
  );
  runApp(
    MyApp(
      theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          headline4: theme.textTheme.headline4?.copyWith(fontSize: 24),
        ),
      ),
    ),
  );
}
