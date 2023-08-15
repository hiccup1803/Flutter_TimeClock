import 'dart:async';
import 'dart:core';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceRepository {
  SharedPreferences? _preferences;

  Future<SharedPreferences> getPreferences() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _preferences!;
  }
}
