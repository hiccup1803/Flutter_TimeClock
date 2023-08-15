import 'package:i18n_extension/i18n_extension.dart';

import '../../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Start session",
        "pl_pl": "Rozpocznij",
        "comment": " ",
      } +
      {
        "en_us": "Close session now?",
        "pl_pl": "Zakończyć sesjię teraz?",
        "comment": " ",
      } +
      {
        "en_us": "Current session",
        "pl_pl": "Aktualna sesja",
        "comment": " ",
      } +
      {
        "en_us": "Finish",
        "pl_pl": "Zakończ",
        "comment": " ",
      } +
      {
        "en_us": "Photo",
        "pl_pl": "Zdjęcie",
        "comment": " ",
      } +
      {
        "en_us": "Files %s/%s",
        "pl_pl": "Pliki %s/%s",
        "comment": " ",
      } +
      {
        "en_us": "No sessions this month",
        "pl_pl": "Brak sesji w tym miesiącu",
        "comment": " ",
      } +
      {
        "en_us": "'No Internet'",
        "pl_pl": "'Brak internetu'",
        "comment": " ",
      } +
      {
        "en_us": "Start new session?",
        "pl_pl": "Rozpocząć nową sesję?",
        "comment": " ",
      } +
      {
        "en_us": "Full history",
        "pl_pl": "Pełna historia",
        "comment": " ",
      } +
      {
        "en_us": "New session for project",
        "pl_pl": "zakończyć sesję teraz?",
        "comment": " ",
      } +
      {
        "en_us": "End session now?",
        "pl_pl": "Nowa sesja dla projektu",
        "comment": " ",
      } +
      {
        "en_us": "Default project",
        "pl_pl": "Domyślny projekt",
        "comment": " ",
      } +
      {
        "en_us": "Earnings",
        "pl_pl": "Zyski",
        "comment": " ",
      } +
      {
        "en_us": "Select month",
        "pl_pl": "Wybierz miesiąc",
        "comment": " ",
      } +
      {
        "en_us": "Check all your sessions",
        "pl_pl": "Sprawdź swoje sesje",
        "comment": " ",
      } +
      {
        "en_us": "Month Statistics",
        "pl_pl": "Podsumowanie miesiąca",
        "comment": " ",
      } +
      {
        "en_us": "Days",
        "pl_pl": "Dni",
        "comment": " ",
      } +
      {
        "en_us": "Sessions",
        "pl_pl": "Sesje",
        "comment": " ",
      } +
      {
        "en_us": "Rate",
        "pl_pl": "Stawka",
        "comment": " ",
      } +
      {
        "en_us": "Bonus",
        "pl_pl": "Premia",
        "comment": " ",
      } +
      {
        "en_us": "Wage",
        "pl_pl": "Płaca",
        "comment": " ",
      } +
      {
        "en_us": "unfinished",
        "pl_pl": "nie zakończona",
        "comment": " ",
      } +
      {
        "en_us": "Time",
        "pl_pl": "Czas",
        "comment": " ",
      } +
      {
        "en_us": "Sessions List",
        "pl_pl": "Lista sesji",
        "comment": " ",
      } +
      {
        "en_us": "Select default project",
        "pl_pl": "Wybierz domyślny projekt",
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
