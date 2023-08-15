import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Save task to upload files and notes",
        "pl_pl": "Zapisz zadanie, aby przesłać pliki i notatki",
        "comment": " ",
      } +
      {
        "en_us": "Files %s/%s",
        "pl_pl": "Pliki %s/%s",
        "comment": " ",
      } +
      {
        "en_us": "Save task to upload added files",
        "pl_pl": "Zapisz zadania aby wysłać dodane pliki",
        "comment": " ",
      } +
      {
        "en_us": "%s - upload completed.",
        "pl_pl": "%s - zakończono wysyłanie.",
        "comment": " ",
      } +
      {
        "en_us": "Delete Task",
        "pl_pl": "Usuń zadania",
        "comment": " ",
      } +
      {
        "en_us": "Select project",
        "pl_pl": "Wybierz projekt",
        "comment": " ",
      } +
      {
        "en_us": "Delete Task",
        "pl_pl": "Usuwanie zadania",
        "comment": "Dialog title",
      } +
      {
        "en_us": "This action can't be undone. Are you sure you want to delete this task?",
        "pl_pl": "Tej operacji nie możesz cofnąć. Na pewno chcesz usunąć tą zadania?",
        "comment": "Dialog title",
      } +
      {
        "en_us": "Deleting a Task",
        "pl_pl": "Usuwanie zadania",
      } +
      {
        "en_us": "Task",
        "pl_pl": "Zadanie",
        "comment": " ",
      } +
      {
        "en_us": "Task deleted!",
        "pl_pl": "Zadanie usunięte!!",
        "comment": " ",
      } +
      {
        "en_us": "Task saved!",
        "pl_pl": "Zadanie zapisane!",
        "comment": " ",
      } +
      {
        "en_us": "Adding Task",
        "pl_pl": "Nowe Zadanie",
        "comment": " ",
      } +
      {
        "en_us": "Start Date",
        "pl_pl": "Start",
        "comment": " ",
      } +
      {
        "en_us": "End Date",
        "pl_pl": "Koniec",
        "comment": " ",
      } +
      {
        "en_us": "whole day",
        "pl_pl": "cały dzień",
        "comment": " ",
      } +
      {
        "en_us": "Start Time",
        "pl_pl": "Godzina Rozpoczęcia",
        "comment": " ",
      } +
      {
        "en_us": "End Time",
        "pl_pl": "Godzina Zakończenia",
        "comment": " ",
      } +
      {
        "en_us": "Title",
        "pl_pl": "Tytuł",
        "comment": " ",
      } +
      {
        "en_us": "Priority",
        "pl_pl": "Priorytet",
        "comment": " ",
      } +
      {
        "en_us": "Select assigned project",
        "pl_pl": "Przypisany Projekt",
        "comment": " ",
      } +
      {
        "en_us": "Assigned Employees",
        "pl_pl": "Przypisani Pracownicy",
        "comment": " ",
      } +
      {
        "en_us": "Project",
        "pl_pl": "Projekt",
        "comment": " ",
      } +
      {
        "en_us": "Send notification by email to employees",
        "pl_pl": "Wyślij powiadomienie e-mail do pracowników",
        "comment": " ",
      } +
      {
        "en_us": "Send PUSH notification to employees",
        "pl_pl": "Wyślij powiadomienie PUSH do pracowników",
        "comment": " ",
      } +
      {
        "en_us":
            "Send notification immediately (by default, notifications are sent at 8 am and 4 pm)",
        "pl_pl":
            "Wyślij powiadomienie natychmiastowo (domyślnie powiadomienia są wysyłane o godzinie 8 i 16)",
        "comment": " ",
      } +
      {
        "en_us": "-- no project --",
        "pl_pl": "-- bez projektu --",
        "comment": " ",
      } +
      {
        "en_us": "New Task",
        "pl_pl": "Nowa Zadanie",
        "comment": " ",
      } +
      {
        "en_us": "Sessions history",
        "pl_pl": "Historia sesji",
        "comment": " ",
      } +
      {
        "en_us": "Note",
        "pl_pl": "Notatka",
        "comment": " ",
      } +
      {
        "en_us": "Not closed",
        "pl_pl": "Nie zamknięta",
        "comment": " ",
      } +
      {
        "en_us": "Session duration",
        "pl_pl": "Czas sesji",
        "comment": " ",
      } +
      {
        "en_us": "Earnings",
        "pl_pl": "Zarobek",
        "comment": " ",
      } +
      {
        "en_us": "Upload file",
        "pl_pl": "Wyślij plik",
        "comment": " ",
      } +
      {
        "en_us": "Not closed!",
        "pl_pl": "Nie zamknięta!",
        "comment": " ",
      } +
      {
        "en_us": "No project",
        "pl_pl": "Bez projektu",
        "comment": " ",
      } +
      {
        "en_us": "Add session",
        "pl_pl": "Dodaj sesję",
        "comment": " ",
      } +
      {
        "en_us": "none",
        "pl_pl": "brak",
        "comment": " ",
      } +
      {
        "en_us": "Location",
        "pl_pl": "Lokacja",
        "comment": " ",
      } +
      {
        "en_us": "Task name",
        "pl_pl": "Nazwa zadania",
        "comment": " ",
      } +
      {
        "en_us": "Date Start",
        "pl_pl": "Data rozpoczęcia",
        "comment": " ",
      } +
      {
        "en_us": "Date End",
        "pl_pl": "Data zakończenia",
        "comment": " ",
      } +
      {
        "en_us": "Clear",
        "pl_pl": "Usun",
        "comment": " ",
      } +
      {
        "en_us": "No session registered",
        "pl_pl": "Nie zarejestrowano sesji",
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
