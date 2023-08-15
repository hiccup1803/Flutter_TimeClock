import 'package:i18n_extension/i18n_extension.dart';

import '../../../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Change password",
        "pl_pl": "Zmień hasło",
        "comment": " ",
      } +
      {
        "en_us": "Super Admin",
        "pl_pl": "Super Admin",
        "comment": " ",
      } +
      {
        "en_us": "Admin",
        "pl_pl": "Admin",
        "comment": " ",
      } +
      {
        "en_us": "Supervisor",
        "pl_pl": "Supervisor",
        "comment": " ",
      } +
      {
        "en_us": "Employee",
        "pl_pl": "Pracownik",
        "comment": " ",
      } +
      {
        "en_us": "Active",
        "pl_pl": "Aktywny",
        "comment": " ",
      } +
      {
        "en_us": "Deactivated",
        "pl_pl": "Dezaktywowany",
        "comment": " ",
      } +
      {
        "en_us": "Registered",
        "pl_pl": "Zarejestrowany",
        "comment": " ",
      } +
      {
        "en_us": "no note",
        "pl_pl": "brak notatki",
        "comment": " ",
      } +
      {
        "en_us": "No existing invitations",
        "pl_pl": "Brak zaproszeń",
        "comment": " ",
      } +
      {
        "en_us": "Copied: %s",
        "pl_pl": "Skopiowano: %s",
        "comment": " ",
      } +
      {
        "en_us": "Delete invitation?",
        "pl_pl": "Usunąć zaproszenie?",
        "comment": " ",
      } +
      {
        "en_us": "This operation can't be undone.",
        "pl_pl": "Ta operacja jest nie odwracalna.",
        "comment": " ",
      } +
      {
        "en_us": "Registration link",
        "pl_pl": "Link rejestracyjny",
        "comment": " ",
      } +
      {
        "en_us": "Downloading",
        "pl_pl": "Pobieranie",
        "comment": " ",
      } +
      {
        "en_us": "No users",
        "pl_pl": "Brak użytkowników",
        "comment": " ",
      } +
      {
        "en_us": "Loading\ninvitations",
        "pl_pl": "Pobieranie\nzaproszeń",
        "comment": " ",
      } +
      {
        "en_us": "Share",
        "pl_pl": "Udostępnij",
        "comment": " ",
      } +
      {
        "en_us": "Invitation code",
        "pl_pl": "Kod zaproszenia",
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
