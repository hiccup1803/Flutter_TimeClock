import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(
    String routeName, {
    Object? args,
    bool replace = false,
    String? removeUntil,
  }) {
    if (removeUntil?.isNotEmpty ?? false) {
      return navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: args,
      );
    }
    if (replace) {
      return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: args);
    }
    return navigatorKey.currentState!.pushNamed(routeName, arguments: args);
  }

  Future<bool> navigateBack(dynamic result) {
    return navigatorKey.currentState!.maybePop(result);
  }

  void pop() {
    navigatorKey.currentState!.pop();
  }
}
