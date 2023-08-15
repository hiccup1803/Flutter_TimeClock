import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Ongoing - %s",
        "pl_pl": "Trwa - %s",
        "comment": " ",
      } +
      {
        "en_us": "Hourly rate",
        "pl_pl": "Stawka godzinowa",
        "comment": " ",
      } +
      {
        "en_us": "Files %s/%s",
        "pl_pl": "Pliki %s/%s",
        "comment": " ",
      } +
      {
        "en_us": "Save session to upload files",
        "pl_pl": "Zapisz sesję aby wysłać pliki",
        "comment": " ",
      } +
      {
        "en_us": "%s - upload completed.",
        "pl_pl": "%s - zakończono wysyłanie.",
        "comment": " ",
      } +
      {
        "en_us": "Delete session",
        "pl_pl": "Usuń sesję",
        "comment": " ",
      } +
      {
        "en_us": "Select project",
        "pl_pl": "Wybierz projekt",
        "comment": " ",
      } +
      {
        "en_us": "Delete session",
        "pl_pl": "Usuwanie sesji",
        "comment": "Dialog title",
      } +
      {
        "en_us": "This action can't be undone. Are you sure you want to delete this session?",
        "pl_pl": "Tej operacji nie możesz cofnąć. Na pewno chcesz usunąć tą sesję?",
        "comment": "Dialog title",
      } +
      {
        "en_us": "Session",
        "pl_pl": "Sesja",
        "comment": " ",
      } +
      {
        "en_us": "Session deleted!",
        "pl_pl": "Sesja została usunięta!",
        "comment": " ",
      } +
      {
        "en_us": "Session saved!",
        "pl_pl": "Sesja została zapisana!",
        "comment": " ",
      } +
      {
        "en_us": "Project",
        "pl_pl": "Projekt",
        "comment": " ",
      } +
      {
        "en_us": "-- no project --",
        "pl_pl": "-- bez projektu --",
        "comment": " ",
      } +
      {
        "en_us": "New session",
        "pl_pl": "Nowa sesja",
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
        "en_us": "Currency",
        "pl_pl": "Waluta",
        "comment": " ",
      } +
      {
        "en_us": "Bonus",
        "pl_pl": "Premia",
        "comment": " ",
      } +
      {
        "en_us": "Not closed",
        "pl_pl": "Nie zamknięta",
        "comment": " ",
      } +
      {
        "en_us": "Session Duration",
        "pl_pl": "Czas Sesji",
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
        "en_us": "no project",
        "pl_pl": "bez projektu",
        "comment": " ",
      } +
      {
        "en_us": "Add session",
        "pl_pl": "Dodaj sesję",
        "comment": " ",
      } +
      {
        "en_us": "No session registered",
        "pl_pl": "Nie zarejestrowano sesji",
        "comment": " ",
      } +
      {
        "en_us": "First location",
        "pl_pl": "Początkowa pozycja",
        "comment": " ",
      } +
      {
        "en_us": "Last location",
        "pl_pl": "Końcowa pozycja",
        "comment": " ",
      } +
      {
        "en_us": "Latest location",
        "pl_pl": "Ostatnia pozycja",
        "comment": " ",
      } +
      {
        "en_us": "Speed",
        "pl_pl": "Prędkość",
        "comment": " ",
      } +
      {
        "en_us": "Missing data",
        "pl_pl": "Brak danych",
        "comment": " ",
      } +
      {
        "en_us": "Go back",
        "pl_pl": "Powrót",
        "comment": " ",
      } +
      {
        "en_us": "No recorded locations",
        "pl_pl": "Brak zebranych pozycji",
        "comment": " ",
      } +
      {
        "en_us": "Employee",
        "pl_pl": "Pracownik",
        "comment": " ",
      } +
      {
        "en_us": "Select Employee",
        "pl_pl": "Wybierz pracownika",
        "comment": " ",
      }+
      {
        "en_us": "Session Details",
        "pl_pl": "Szczegóły Sesji",
        "comment": " ",
      }+
      {
        "en_us": "Start",
        "pl_pl": "Start",
        "comment": " ",
      }+
      {
        "en_us": "End",
        "pl_pl": "Koniec",
        "comment": " ",
      }+
      {
        "en_us": "Show locations",
        "pl_pl": "Pokaż lokalizacje",
        "comment": " ",
      }+
      {
        "en_us": "Save Session",
        "pl_pl": "Zapisz Sesję",
        "comment": " ",
      }+
      {
        "en_us": "Edit Session",
        "pl_pl": "Edytuj Sesję",
        "comment": " ",
      }+
      {
        "en_us": "Add Note",
        "pl_pl": "Dodaj notatke",
        "comment": " ",
      }+
      {
        "en_us": "Total Earned",
        "pl_pl": "Zarobek",
        "comment": " ",
      }+ {
        "en_us": "Original:",
        "pl_pl": "Oryginał:",
        "comment": " ",
      }+
      {
        "en_us": "New value:",
        "pl_pl": "Nowa wartość:",
        "comment": " ",
      } +
      {
        "en_us": "Approved",
        "pl_pl": "Zatwierdzona",
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
