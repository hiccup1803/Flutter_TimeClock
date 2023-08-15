import 'package:i18n_extension/i18n_extension.dart';
import 'package:staffmonitor/page/common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Vacations Awaiting Approval",
        "pl_pl": "Urlopy oczekujące na zatwierdzenie",
        "comment": " ",
      } +
      {
        "en_us": "Vacations Accepted",
        "pl_pl": "Urlopy zatwierdzone",
        "comment": " ",
      } +
      {
        "en_us": "Vacations Denied",
        "pl_pl": "Urlopy odrzucone",
        "comment": " ",
      } +
      {
        "en_us": "Non-Vacations",
        "pl_pl": "Wolne ogólne",
        "comment": " ",
      } +
      {
        "en_us": "Deny",
        "pl_pl": "Odrzuć",
        "comment": " ",
      } +
      {
        "en_us": "Select year",
        "pl_pl": "Wybierz rok",
        "comment": " ",
      } +
      {
        "en_us": "Pending",
        "pl_pl": "Oczekujące",
        "comment": " ",
      } +
      {
        "en_us": "Accepted",
        "pl_pl": "Zaakceptowane",
        "comment": " ",
      } +
      {
        "en_us": "Denied",
        "pl_pl": "Odrzucone",
        "comment": " ",
      } +
      {
        "en_us": "Non Vacation",
        "pl_pl": "Nie Urlop",
        "comment": " ",
      } +
      {
        "en_us": "Manage Employees Vacations",
        "pl_pl": "Zarządzaj Urlopami Pracowników",
        "comment": " ",
      } +
      {
        "en_us": "Start in",
        "pl_pl": "Początek",
        "comment": " ",
      } +
      {
        "en_us": "End in",
        "pl_pl": "Koniec",
        "comment": " ",
      } +
      {
        "en_us": "Duration",
        "pl_pl": "Długość",
        "comment": " ",
      } +
      {
        "en_us": "Edit",
        "pl_pl": "Edytuj",
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
