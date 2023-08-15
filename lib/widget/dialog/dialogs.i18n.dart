import 'package:i18n_extension/i18n_extension.dart';

import '../../page/common_translations.i18n.dart';

extension Localization on String {
  static var t = commonTranslations * _translation;

  static var _translation = Translations("en_us") +
      {
        "en_us": "Failure",
        "pl_pl": "Niepowodzenie",
        "comment": " ",
      } +
      {
        "en_us": "Recently used",
        "pl_pl": "Ostatnio używane",
        "comment": "projects category",
      } +
      {
        "en_us": "Preferred",
        "pl_pl": "Preferowane",
        "comment": "projects category",
      } +
      {
        "en_us": "-- new project --",
        "pl_pl": "-- nowy projekt --",
        "comment": " ",
      } +
      {
        "en_us": "-- no project --",
        "pl_pl": "-- bez projektu --",
        "comment": " ",
      } +
      {
        "en_us": "Note",
        "pl_pl": "Notatka",
        "comment": " ",
      } +
      {
        "en_us": "Write a note (optional)",
        "pl_pl": "Napisz notatke (opcjonalne)",
        "comment": " ",
      } +
      {
        "en_us": "New Invitation",
        "pl_pl": "Nowe Zaproszenie",
        "comment": " ",
      } +
      {
        "en_us": "Add a note to your new invitation",
        "pl_pl": "Dodaj notatke do zaproszenia",
        "comment": " ",
      } +
      {
        "en_us": "Create Invitation",
        "pl_pl": "Stwórz Zaproszenie",
        "comment": " ",
      } +
      {
        "en_us": "Other",
        "pl_pl": "Pozostałe",
        "comment": "projects category",
      } +
      {
        "en_us": "Download",
        "pl_pl": "Pobierz",
        "comment": "file details dialog - button",
      } +
      {
        "en_us": "Downloading to: %s",
        "pl_pl": "Pobieram do: %s",
        "comment": "file details dialog",
      } +
      {
        "en_us": "Delete",
        "pl_pl": "Usuń",
        "comment": "file details dialog - delete button",
      } +
      {
        "en_us": "This action cannot be undone. Are you sure you want to delete this file?",
        "pl_pl": "Tej operacji nie można cofnąć. Czy na pewno chcesz usuąć ten plik?",
        "comment": "file details dialog - delete confirm",
      } +
      {
        "en_us": "Type: %s",
        "pl_pl": "Typ: %s",
        "comment": "file details dialog - %s is file type",
      } +
      {
        "en_us": "Size: %s B",
        "pl_pl": "Rozmiar: %s B",
        "comment": "file details dialog - %s is file size in B",
      } +
      {
        "en_us": "Uploaded: %s",
        "pl_pl": "Wysłano: %s",
        "comment": "file details dialog - %s is a date",
      } +
      {
        "en_us": "Edited: %s",
        "pl_pl": "Edytowano: %s",
        "comment": "file details dialog - %s is a date",
      } +
      {
        "en_us": "Confirm deleting",
        "pl_pl": "Potwierdź usunięcie",
        "comment": "file details dialog",
      } +
      {
        "en_us": "Error",
        "pl_pl": "Błąd",
        "comment": "Login error title",
      } +
      {
        "en_us": "File to large, file size limit is 10 MB",
        "pl_pl": "Plik jest za duży, limit wynosi 10 MB",
        "comment": "File size over",
      } +
      {
        "en_us": "The system administrator has been informed",
        "pl_pl": "Administrator został o tym powiadomiony",
        "comment": "Login error content",
      } +
      {
        "en_us": "Wrong login or password",
        "pl_pl": "Zły login lub hasło",
        "comment": "Login error content",
      } +
      {
        "en_us": "Pick color",
        "pl_pl": "Wybierz kolor",
        "comment": "Color picker dialog",
      } +
      {
        "en_us": "Shade",
        "pl_pl": "Odcień",
        "comment": "Color picker dialog",
      } +
      {
        "en_us": "New project",
        "pl_pl": "Nowy projekt",
        "comment": "Own project dialog ",
      } +
      {
        "en_us": "No, thanks",
        "pl_pl": "Nie, dzięki",
        "comment": "Location Permission Dialog ",
      } +
      {
        "en_us": "Ok, I understand",
        "pl_pl": "Ok, rozumiem",
        "comment": "Location Permission Dialog ",
      } +
      {
        "en_us":
            "StaffMonitor collects your location data during active sessions even when the app is closed or not in use. In order to track your activity efficiently please grand location and physical activity permissions.",
        "pl_pl":
            "StaffMonitor zbiera lokalizację twojego urządzenia podczas trwającej sesji także gdy aplikacja jest zamkniętą lub nie jest używana. Aby śledzić lokalizacje najwydajniejszy sposób proszę przyznać aplikacji dostep do lokalizacji i aktywnosci fizycznej.",
        "comment": "Location Permission Dialog message",
      } +
      {
        "en_us": "Show Off-time",
        "pl_pl": "Pokaż wolne",
      } +
      {
        "en_us": "Show Sessions",
        "pl_pl": "Pokaż sesje",
      } +
      {
        "en_us": "Show Tasks",
        "pl_pl": "Pokaż zadania",
      } +
      {
        "en_us": "Filter",
        "pl_pl": "Filtry",
      } +
      {
        "en_us": "Filter By Employee",
        "pl_pl": "Filtruj po pracowniku",
      } +
      {
        "en_us": "Hours",
        "pl_pl": "Godz.",
      } +
      {
        "en_us": "Rate",
        "pl_pl": "Stawka",
      } +
      {
        "en_us": "Bonus",
        "pl_pl": "Bonus",
      } +
      {
        "en_us": "Wage",
        "pl_pl": "Zarob.",
      } +
      {
        "en_us": "Select employee",
        "pl_pl": "Wybierz pracownika",
      } +
      {
        "en_us": "No internet connection",
        "pl_pl": "Brak połączenia z internetem",
      } +
      {
        "en_us": "Name",
        "pl_pl": "Nazwa",
        "comment": "",
      } +
      {
        "en_us": "Confirm",
        "pl_pl": "Potwierdzać",
      } +
      {
        "en_us": "Currency",
        "pl_pl": "Waluta",
      } +
      {
        "en_us": "Exchange Ratio",
        "pl_pl": "Stosunek wymiany",
      };

  String get i18n {
    return localize(this, t);
  }

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, t);

  String version(Object modifier) => localizeVersion(modifier, this, t);

  Map<String?, String> allVersions() => localizeAllVersions(this, t);
}
