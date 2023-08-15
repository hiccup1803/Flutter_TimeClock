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
        "en_us": "Start Break",
        "pl_pl": "Rozpocznij Przerwę",
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
        "pl_pl": "Nowa sesja dla projektu",
        "comment": " ",
      } +
      {
        "en_us": "End session now?",
        "pl_pl": "Zakończyć sesję teraz?",
        "comment": " ",
      } +
      {
        "en_us": "Default project",
        "pl_pl": "Domyślny projekt",
        "comment": " ",
      } +
      {
        "en_us": "Project",
        "pl_pl": "Projekt",
        "comment": " ",
      } +
      {
        "en_us": "upload completed",
        "pl_pl": "zakończono wysyłanie",
        "comment": " ",
      } +
      {
        "en_us": "Select default project",
        "pl_pl": "Wybierz domyślny projekt",
        "comment": " ",
      } +
      {
        "en_us": "Breaks",
        "pl_pl": "Przerwy",
        "comment": " ",
      } +
      {
        "en_us": "Hourly rate",
        "pl_pl": "Stawka godzinowa",
        "comment": " ",
      } +
      {
        "en_us": "Enter Project name and choose a color to create a project",
        "pl_pl": "Podaj nawę projektu i wybierz kolor aby stworzyć nowy projekt",
        "comment": " ",
      } +
      {
        "en_us": "Your project name",
        "pl_pl": "Nazwa projektu",
        "comment": " ",
      } +
      {
        "en_us": "Pick a color",
        "pl_pl": "Wybier kolor",
        "comment": " ",
      } +
      {
        "en_us": "Create project",
        "pl_pl": "Dodaj projekt",
        "comment": " ",
      } +
      {
        "en_us": "Pick your color",
        "pl_pl": "Wybierz kolor",
        "comment": " ",
      } +
      {
        "en_us": "File note",
        "pl_pl": "Notatka do pliku",
        "comment": " ",
      } +
      {
        "en_us": "Your note",
        "pl_pl": "Twoja notatka",
        "comment": " ",
      } +
      {
        "en_us": "Save note",
        "pl_pl": "Zapisz notatke",
        "comment": " ",
      } +
      {
        "en_us": "Started at",
        "pl_pl": "Rozpoczęto o",
        "comment": " ",
      } +
      {
        "en_us": "Ended at",
        "pl_pl": "Zakończono o",
        "comment": " ",
      } +
      {
        "en_us": "You have no breaks so far.",
        "pl_pl": "Nie masz jeszcze żadnej przerwy.",
        "comment": " ",
      } +
      {
        "en_us": "Note",
        "pl_pl": "Notatka",
        "comment": " ",
      } +
      {
        "en_us": "Files",
        "pl_pl": "Pliki",
        "comment": " ",
      } +
      {
        "en_us": "Photo",
        "pl_pl": "Zdjęcie",
        "comment": " ",
      } +
      {
        "en_us": "End break",
        "pl_pl": "Zakończ przerwę",
        "comment": " ",
      } +
      {
        "en_us": "Start break",
        "pl_pl": "Rozpocznij przerwę",
        "comment": " ",
      } +
      {
        "en_us": "End session",
        "pl_pl": "Zakończ sesję",
        "comment": " ",
      } +
      {
        "en_us": "Start session",
        "pl_pl": "Rozpocznij sesję",
        "comment": " ",
      } +
      {
        "en_us": "Hourly Rate",
        "pl_pl": "Stawka godzinowa",
        "comment": " ",
      } +
      {
        "en_us": "Select a project or create new one",
        "pl_pl": "Wybierz projekt lub dodaj nowy",
        "comment": " ",
      } +
      {
        "en_us": "Add new project",
        "pl_pl": "Dodaj nowy projekt",
        "comment": " ",
      } +
      {
        "en_us": "Current Project",
        "pl_pl": "Wybrany projekt",
        "comment": " ",
      } +
      {
        "en_us": "Select project",
        "pl_pl": "Wybierz projekt",
        "comment": " ",
      } +
      {
        "en_us": "Create new project",
        "pl_pl": "Dodaj nowy projekt",
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
