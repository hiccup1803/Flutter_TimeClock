import 'package:hive_flutter/hive_flutter.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session_break.dart';

import '../model/session.dart';
import 'storage.dart';

mixin OfflineStorage {
  List<Session> sessionsList();

  Future<void> addSession(Session session);

  Future<void> updateSession(Session session);

  Future<void> deleteSession(int sessionId);

  Future<void> clearSessions();

  List<SessionBreak> getBreaksOf({required int sessionId});

  Future<void> deleteBreaksOf({required int sessionId});

  Future<void> updateBreaksOf(int sessionId, List<SessionBreak> sessionBreaks);

  Future<void> addBreak(SessionBreak sessionBreak);

  Future<void> updateBreak(SessionBreak sessionBreak);

  Future<void> clearAll();

  Future<void> updateProfile(Profile? profile);

  Profile? getProfile();

  Future<void> saveCurrentSession(Session session);

  Session? getCurrentSession();

  Future<void> deleteCurrentSession();
}

class OfflineStorageImpl extends Storage with OfflineStorage {
  static OfflineStorageImpl? _instance;

  static Future<OfflineStorage> getInstance() async {
    _instance ??= OfflineStorageImpl._(await Hive.openBox<dynamic>(_boxName));
    return _instance!;
  }

  static const _boxName = '_offlineBox';
  static const _sessionsKey = '_sessionsListKey';
  static const _profileKey = '_profileKey';
  static const _currentKey = '_currentSessionKey';
  static const _breakKeyPrefix = '_breakKey';
  static const _trackedBreakKey = '_trackedBreakKey';

  const OfflineStorageImpl._(Box box) : super(box);

  Future<void> _addTrackedBreakKey(String key) {
    Set<String> keys = Set.from(getListValue<String>(_trackedBreakKey));
    keys.add(key);
    return setValue(_trackedBreakKey, keys.toList());
  }

  Future<void> _removeTrackedBreakKey(String key) {
    Set<String> keys = Set.from(getListValue<String>(_trackedBreakKey));
    keys.remove(key);
    return setValue(_trackedBreakKey, keys.toList());
  }

  @override
  Future<void> updateProfile(Profile? profile) {
    if (profile == null) {
      return deleteValue(_profileKey);
    }
    return setValue(_profileKey, profile);
  }

  @override
  Profile? getProfile() {
    return getValueOrNull(_profileKey);
  }

  @override
  Future<void> addSession(Session session) async {
    List<Session> value = sessionsList();
    return setValue(_sessionsKey, List.from(value)..add(session));
  }

  @override
  Future<void> updateSession(Session session) {
    List<Session> list = List.from(sessionsList());
    int indexWhere = list.indexWhere((element) => element.id == session.id);
    if (indexWhere > -1) {
      list[indexWhere] = session;
      return setValue(_sessionsKey, list);
    } else {
      list.add(session);
      return setValue(_sessionsKey, list);
    }
  }

  @override
  Future<void> deleteSession(int sessionId) {
    List<Session> value = sessionsList();
    return setValue(
      _sessionsKey,
      List.from(value)..removeWhere((element) => element.id == sessionId),
    );
  }

  @override
  List<Session> sessionsList() {
    return getListValue<Session>(_sessionsKey);
  }

  @override
  Future<void> clearSessions() {
    return deleteValue(_sessionsKey);
  }

  @override
  Future<void> deleteBreaksOf({required int sessionId}) {
    String key = '${_breakKeyPrefix}_$sessionId';
    _removeTrackedBreakKey(key);
    return deleteValue(key);
  }

  @override
  List<SessionBreak> getBreaksOf({required int sessionId}) {
    String key = '${_breakKeyPrefix}_$sessionId';
    return getListValue<SessionBreak>(key);
  }

  @override
  Future<void> addBreak(SessionBreak sessionBreak) {
    String key = '${_breakKeyPrefix}_${sessionBreak.sessionId}';
    List<SessionBreak> breaks = getListValue<SessionBreak>(key);
    int indexWhere = breaks.indexWhere((element) => element.id == sessionBreak.id);
    if (indexWhere < 0) {
      breaks = [...breaks, sessionBreak];
      _addTrackedBreakKey(key);
      return setValue(key, breaks);
    }
    return Future.value();
  }

  @override
  Future<void> updateBreaksOf(int sessionId, List<SessionBreak> sessionBreaks) {
    String key = '${_breakKeyPrefix}_$sessionId';
    if (sessionBreaks.isEmpty) {
      _removeTrackedBreakKey(key);
      return deleteValue(key);
    }
    return setValue(key, sessionBreaks);
  }

  @override
  Future<void> updateBreak(SessionBreak sessionBreak) {
    String key = '${_breakKeyPrefix}_${sessionBreak.sessionId}';
    List<SessionBreak> breaks = getListValue<SessionBreak>(key);
    int indexWhere = breaks.indexWhere((element) => element.id == sessionBreak.id);
    if (indexWhere >= 0) {
      breaks[indexWhere] = sessionBreak;
      _addTrackedBreakKey(key);
      return setValue(key, breaks);
    }
    return Future.value();
  }

  @override
  Future<void> deleteCurrentSession() {
    return deleteValue(_currentKey);
  }

  @override
  Session? getCurrentSession() {
    return getValueOrNull(_currentKey);
  }

  @override
  Future<void> saveCurrentSession(Session session) {
    return setValue(_currentKey, session);
  }

  @override
  Future<void> clearAll() async {
    await deleteValue(_currentKey);
    await deleteValue(_sessionsKey);
    await deleteValue(_profileKey);
    List<String> breakKeys = getValue(_trackedBreakKey, defaultValue: []);
    for (String key in breakKeys) {
      await deleteValue(key);
    }
    await deleteValue(_trackedBreakKey);
  }
}
