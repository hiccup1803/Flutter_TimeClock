import 'package:i18n_extension/i18n_extension.dart';
import 'package:staffmonitor/page/common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Archive",
        "pl_pl": "Archiwizuj",
        "comment": " ",
      } +
      {
        "en_us": "In use",
        "pl_pl": "W użyciu",
        "comment": " ",
      } +
      {
        "en_us": "Archived",
        "pl_pl": "Zarchiwizowany",
        "comment": " ",
      } +
      {
        "en_us": "Active",
        "pl_pl": "Aktywny",
        "comment": " ",
      } +
      {
        "en_us": "Status",
        "pl_pl": "Status",
        "comment": " ",
      } +
      {
        "en_us": "Bring back",
        "pl_pl": "Przywróć",
        "comment": " ",
      } +
      {
        "en_us": "Assigned users",
        "pl_pl": "Przydzieleni pracownicy",
        "comment": " ",
      } +
      {
        "en_us": "No assigned users",
        "pl_pl": "Brak przydzielonych pracowników",
        "comment": " ",
      } +
      {
        "en_us": "Remove",
        "pl_pl": "Usuń",
        "comment": " ",
      } +
      {
        "en_us": "Edit",
        "pl_pl": "Edytuj",
        "comment": " ",
      } +
      {
        "en_us": "Project name",
        "pl_pl": "Nazwa projektu",
        "comment": " ",
      } +
      {
        "en_us": "Delete project?",
        "pl_pl": "Usunąć projekt?",
        "comment": " ",
      } +
      {
        "en_us": "Archive project?",
        "pl_pl": "Zarchiwizować projekt?",
        "comment": " ",
      } +
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
        "en_us": "Every active user is already assigned",
        "pl_pl": "Wszyscy aktywni użytkownicy są już dodani",
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
