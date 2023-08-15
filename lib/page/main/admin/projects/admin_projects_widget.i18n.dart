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
      } +
      {
        "en_us": "Project Details",
        "pl_pl": "Szczegóły Projektu",
        "comment": " ",
      } +
      {
        "en_us": "Total Budget Cost",
        "pl_pl": "Całkowity koszt budżetowy",
        "comment": " ",
      } +
      {
        "en_us": "Default Project Currency",
        "pl_pl": "Domyślna waluta projektu",
        "comment": " ",
      }  +
      {
        "en_us": "Project\nCurrencies",
        "pl_pl": "Projekt\nWaluty",
        "comment": " ",
      } +
      {
        "en_us": "Total Budget Hours",
        "pl_pl": "Całkowite godziny budżetowe",
        "comment": " ",
      } +
      {
        "en_us": "Edit Currencies",
        "pl_pl": "Edytuj waluty",
        "comment": " ",
      } +
      {
        "en_us": "Budget",
        "pl_pl": "Budżet",
        "comment": " ",
      } +
      {
        "en_us": "Type",
        "pl_pl": "Typ",
        "comment": " ",
      } +
      {
        "en_us": "Unlimited Budget",
        "pl_pl": "Nieograniczony budżet",
        "comment": " ",
      } +
      {
        "en_us": "Cost Budget",
        "pl_pl": "Budżet kosztów",
        "comment": " ",
      } +
      {
        "en_us": "Hours Budget",
        "pl_pl": "Budżet godzinowy",
        "comment": " ",
      } +
      {
        "en_us": "Settlements in one currency",
        "pl_pl": "Rozliczenia w jednej walucie",
        "comment": " ",
      } +
      {
        "en_us": "Multi-currency settlements",
        "pl_pl": "Rozliczenia wielowalutowe",
        "comment": " ",
      }+
      {
        "en_us": "Edit Currencies Ratio",
        "pl_pl": "Edytuj współczynnik walut",
        "comment": " ",
      } +
      {
        "en_us": "Budget Reset",
        "pl_pl": "Resetowanie budżetu",
        "comment": " ",
      } +
      {
        "en_us": "Never",
        "pl_pl": "Nigdy",
        "comment": " ",
      } +
      {
        "en_us": "Weekly",
        "pl_pl": "Co tydzień",
        "comment": " ",
      } +
      {
        "en_us": "Monthly",
        "pl_pl": "Co miesiąc",
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
