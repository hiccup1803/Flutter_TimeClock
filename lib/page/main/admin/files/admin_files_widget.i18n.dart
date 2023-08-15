import 'package:i18n_extension/i18n_extension.dart';
import 'package:staffmonitor/page/common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Bring back project?",
        "pl_pl": "Przywrócić projekt?",
        "comment": " ",
      } +
      {
        "en_us": "(tap to edit)",
        "pl_pl": "(naciśnij aby edytować)",
        "comment": " ",
      } +
      {
        "en_us": "No files found",
        "pl_pl": "Nie znaleziono plików",
        "comment": " ",
      } +
      {
        "en_us": "Every active user is already assigned",
        "pl_pl": "Wszyscy aktywni użytkownicy są już dodani",
        "comment": " ",
      } +
      {
        "en_us": "Filter By Month",
        "pl_pl": "Filtruj po miesiącu",
        "comment": " ",
      } +
      {
        "en_us": "Filter by Project",
        "pl_pl": "Filtruj po Projekcie",
        "comment": " ",
      };

/* @EndTranslation */

  static var t = commonTranslations * _translation;

  String get i18n {
    return localize(this, t);
  }

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, t);

  String version(Object modifier) => localizeVersion(modifier, this, t);

  Map<String?, String> allVersions() => localizeAllVersions(this, t);
}
