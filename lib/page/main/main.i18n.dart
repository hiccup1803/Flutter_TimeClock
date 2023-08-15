import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Employees",
        "pl_pl": "Pracownicy",
        "comment": "Employees tab label for all users list",
      } +
      {
        "en_us": "Invitations",
        "pl_pl": "Zaproszenia",
        "comment": "Invitations tab label for all users list",
      } +
      {
        "en_us": "Employees",
        "pl_pl": "Pracownicy",
        "comment": "Bottom bar label",
      } +
      {
        "en_us": "Admin",
        "pl_pl": "Admin",
        "comment": "Drawer label",
      } +
      {
        "en_us": "Employee",
        "pl_pl": "Pracownik",
        "comment": "Drawer label",
      } +
      {
        "en_us": "Tasks",
        "pl_pl": "Zadania",
        "comment": "Drawer label",
      } +
      {
        "en_us": "My Tasks",
        "pl_pl": "Mój Zadania",
        "comment": "Drawer label",
      } +
      {
        "en_us": "Off-times",
        "pl_pl": "Wolne",
        "comment": "Bottom bar label",
      } +
      {
        "en_us": "Projects",
        "pl_pl": "Projekty",
        "comment": "Bottom bar or drawer label ",
      } +
      {
        "en_us": "My Calendar",
        "pl_pl": "Mój kalendarz",
        "comment": "Bottom bar or drawer label ",
      } +
      {
        "en_us": "Settings",
        "pl_pl": "Ustawienia",
        "comment": "Bottom bar, drawer label or page title",
      } +
      {
        "en_us": "Menu",
        "pl_pl": "Menu",
        "comment": "Bottom bar label",
      } +
      {
        "en_us": "Projects Manager",
        "pl_pl": "Zarządzanie projektami",
        "comment": "Drawer label",
      } +
      {
        "en_us": "Sessions",
        "pl_pl": "Sesje",
        "comment": "Bottom bar label",
      } +
      {
        "en_us": "Calendar",
        "pl_pl": "Kalendarz",
        "comment": "Bottom bar label",
      } +
      {
        "en_us": "My Off-times",
        "pl_pl": "Moje Wolne",
        "comment": "Drawer label",
      } +
      {
        "en_us": "My Projects",
        "pl_pl": "Moje Projekty",
        "comment": "Drawer label",
      } +
      {
        "en_us": "KIOSK Mode",
        "pl_pl": "Tryb RCP",
        "comment": "Drawer label",
      } +
      {
        "en_us": "Terminals",
        "pl_pl": "Terminale",
        "comment": "Drawer label",
      } +
      {
        "en_us": "NFC Tags",
        "pl_pl": "Tagi NFC",
        "comment": "Drawer label",
      } +
      {
        "en_us": "My Sessions",
        "pl_pl": "Moje Sesje",
        "comment": "Drawer label",
      } +
      {
        "en_us": "project name",
        "pl_pl": "nazwa projektu",
        "comment": "new project input hint",
      } +
      {
        "en_us": "Archived",
        "pl_pl": "Zarchiwizowane",
        "comment": " ",
      } +
      {
        "en_us": "Start",
        "pl_pl": "Start",
        "comment": " ",
      } +
      {
        "en_us": "Overall Calendar",
        "pl_pl": "Kalendarz ogólny",
        "comment": " ",
      } +
      {
        "en_us": "Active",
        "pl_pl": "Aktywne",
        "comment": " ",
      } +
      {
        "en_us": "Offline",
        "pl_pl": "Offline",
        "comment": " ",
      } +
      {
        "en_us": "Work Time",
        "pl_pl": "Czas pracy",
        "comment": " ",
      }+
      {
        "en_us": "Tasks",
        "pl_pl": "Zadania",
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
