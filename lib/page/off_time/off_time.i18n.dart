import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Add off-time",
        "pl_pl": "Dodaj wolne",
        "comment": " ",
      } +
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
        "en_us": "Add off-time",
        "pl_pl": "Dodaj wolne",
        "comment": " ",
      } +
      {
        "en_us": "Edit off-time",
        "pl_pl": "Edytuj wolne",
        "comment": " ",
      } +
      {
        "en_us": "Requires approval",
        "pl_pl": "Wymaga zawtierdzenia",
        "comment": " ",
      } +
      {
        "en_us": "Confirmed",
        "pl_pl": "Zatwierdzone",
        "comment": " ",
      } +
      {
        "en_us": "Rejected",
        "pl_pl": "Odrzucone",
        "comment": " ",
      } +
      {
        "en_us": "Note",
        "pl_pl": "Notka",
        "comment": " ",
      } +
      {
        "en_us": "Edit",
        "pl_pl": "Edytuj",
        "comment": " ",
      } +
      {
        "en_us": "Month",
        "pl_pl": "Miesiąc",
        "comment": " ",
      } +
      {
        "en_us": "Week",
        "pl_pl": "Tydzień",
        "comment": " ",
      } +
      {
        "en_us": "day",
        "pl_pl": "dzień",
        "comment": " ",
      } +
      {
        "en_us": "Vacation",
        "pl_pl": "Urlop",
        "comment": " ",
      } +
      {
        "en_us": "Off-time",
        "pl_pl": "Wolne",
        "comment": " ",
      } +
      {
        "en_us": "Start",
        "pl_pl": "Start",
        "comment": " ",
      } +
      {
        "en_us": "End",
        "pl_pl": "Koniec",
        "comment": " ",
      } +
      {
        "en_us": "Delete off-time",
        "pl_pl": "Usuwanie wolnego",
        "comment": " ",
      } +
      {
        "en_us": "This action can't be undone. Are you sure you want to delete this vacation?",
        "pl_pl": "Tej operacji nie możesz cofnąć. Na pewno chcesz usunąć ten urlop?",
        "comment": " ",
      } +
      {
        "en_us":
            "Administrator will get new notification and will have to approve it to make it official.",
        "pl_pl":
            "Administrator otrzyma nowe powiadomienie i będzie musiał oficjalnie zatwierdzić ten okres.",
        "comment": " ",
      } +
      {
        "en_us": "Off-time deleted",
        "pl_pl": "Wolne zostało usunięte",
        "comment": " ",
      } +
      {
        "en_us": "Vacation deleted",
        "pl_pl": "Urlop został usunięty",
        "comment": " ",
      } +
      {
        "en_us": "Off-time saved!",
        "pl_pl": "Wolne zostało zapisane!",
        "comment": " ",
      } +
      {
        "en_us": "Vacation saved!",
        "pl_pl": "Urlop został zapisany!",
        "comment": " ",
      } +
      {
        "en_us": "This action can't be undone. Are you sure you want to delete this off-time?",
        "pl_pl": "Tej operacji nie możesz cofnąć. Na pewno chcesz usunąć to wolne?",
        "comment": " ",
      } +
      {
        "en_us": "Delete vacation",
        "pl_pl": "Usuwanie urlopu",
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
        "en_us": "Duration",
        "pl_pl": "Długość",
        "comment": " ",
      } +
      {
        "en_us": "Duration",
        "pl_pl": "Długość",
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
