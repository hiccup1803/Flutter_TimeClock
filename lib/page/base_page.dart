import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/dijkstra.dart' as dijkstra;
import 'package:staffmonitor/model/profile.dart';

import '../injector.dart';

export 'package:flutter/material.dart';

abstract class _Page {
  /// Return a proper Route name if redirect should occur for current AuthState
  /// null or empty string is interpreted as no redirection is need
  @protected
  String? shouldRedirect(AuthState? authState) =>
      authState is AuthUnauthorized ? dijkstra.FALLBACK_ROUTE : null;

  @protected
  Widget buildSafe(BuildContext context, [Profile? profile]);

  @protected
  bool get checkAppUpdates => false;

  @protected
  final List<DeviceOrientation> _acceptableOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  void authCheck(AuthState? authState) async {
    var redirectTo = shouldRedirect(authState);
    if (redirectTo?.isNotEmpty == true && redirectTo == dijkstra.MAIN_ROUTE) {
      Future.microtask(() {
        injector.navigationService.navigateTo(redirectTo!, removeUntil: dijkstra.MAIN_ROUTE);
      });
    } else if (redirectTo?.isNotEmpty == true) {
      Future.microtask(() {
        injector.navigationService.navigateTo(redirectTo!, replace: true);
      });
    }
  }

  Map<String, dynamic>? readArgs(BuildContext context) {
    RouteSettings? routeSettings = ModalRoute.of(context)?.settings;
    if (routeSettings == null) return null;
    return (routeSettings.arguments is Map)
        ? routeSettings.arguments as Map<String, dynamic>?
        : Map<String, dynamic>();
  }
}

abstract class BasePageWidget extends StatelessWidget with _Page {
  final _log = Logger('Page');

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(_acceptableOrientations);
    authCheck(BlocProvider.of<AuthCubit>(context).state);
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, authState) {
        _log.fine('($runtimeType) listener authState $authState');
        authCheck(authState);
      },
      buildWhen: (previous, current) {
        var bool = previous != current;
        _log.finer('($runtimeType) buildWhen authState: $bool, prev: $previous, curr: $current');
        return bool;
      },
      builder: (context, state) {
        _log.finer('($runtimeType) build authState: $state');
        return buildSafe(
          context,
          state is AuthAuthorized ? state.profile : null,
        );
      },
    );
  }
}

abstract class BasePageState<T extends StatefulWidget> extends State<T> with _Page {
  final _log = Logger('Page');

  @override
  void initState() {
    super.initState();
    authCheck(BlocProvider.of<AuthCubit>(context).state);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(_acceptableOrientations);
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, authState) {
        _log.fine('listener authState $authState');
        authCheck(authState);
      },
      buildWhen: (previous, current) {
        return previous != current;
      },
      builder: (context, state) {
        return buildSafe(
          context,
          state is AuthAuthorized ? state.profile : null,
        );
      },
    );
  }
}
