import 'preference_repository.dart';

class AppPreferences {
  static const String _LAST_PROJECTS_IDS = 'app_lastProjectIds';
  static const String _IS_FIRST_OPEN = 'is_first_open';

  AppPreferences(this._repository);

  final PreferenceRepository _repository;

  Future<List<int?>> getLastProjects() async {
    final prefs = await _repository.getPreferences();
    var stringList = prefs.getStringList(_LAST_PROJECTS_IDS) ?? List.empty();
    return stringList.map((e) => int.tryParse(e)).toList();
  }

  Future updateLastProjects(int projectId) async {
    if (projectId <= 0) return;
    final prefs = await _repository.getPreferences();
    var stringList = prefs.getStringList(_LAST_PROJECTS_IDS) ?? List.empty();
    var idString = projectId.toString();
    if (stringList.contains(idString)) {
      stringList.remove(idString);
    }
    return prefs.setStringList(_LAST_PROJECTS_IDS, List.of([idString])..addAll(stringList));
  }

  Future<bool> isFirstOpen() async {
    final prefs = await _repository.getPreferences();
    return prefs.getBool(_IS_FIRST_OPEN) ?? true;
  }

  Future setFirstOpen(bool value) async {
    final prefs = await _repository.getPreferences();
    return await prefs.setBool(_IS_FIRST_OPEN, value);
  }
}
