import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Settings",
        "pl_pl": "Ustawienia",
        "comment": " ",
      } +
      {
        "en_us": "-- Select --",
        "pl_pl": "-- Wybierz --",
        "comment": " ",
      } +
      {
        "en_us": "Profile",
        "pl_pl": "Profil",
        "comment": " ",
      } +
      {
        "en_us": "Email",
        "pl_pl": "Email",
        "comment": " ",
      } +
      {
        "en_us": "First & Last name",
        "pl_pl": "Imię i nazwisko",
        "comment": " ",
      } +
      {
        "en_us": "Phone number",
        "pl_pl": "Numer telefonu",
        "comment": " ",
      } +
      {
        "en_us": "Language",
        "pl_pl": "Język",
        "comment": " ",
      } +
      {
        "en_us": "Projects",
        "pl_pl": "Projekty",
        "comment": " ",
      } +
      {
        "en_us": "Default",
        "pl_pl": "Domyślny",
        "comment": " ",
      } +
      {
        "en_us": "Hourly rate",
        "pl_pl": "Stawka godzinowa",
        "comment": " ",
      } +
      {
        "en_us": "Recent limit",
        "pl_pl": "Liczba ostatnich",
        "comment": " ",
      } +
      {
        "en_us": "Logout",
        "pl_pl": "Wyloguj",
        "comment": " ",
      } +
      {
        "en_us": "New user",
        "pl_pl": "Nowy użytkownik",
        "comment": " ",
      } +
      {
        "en_us": "User profile",
        "pl_pl": "Profil użytkownika",
        "comment": " ",
      } +
      {
        "en_us": "Automatically Close Open Sessions After 24 hours",
        "pl_pl": "Automatycznie zamykaj otwarte sesje po 24 godzinach",
        "comment": " ",
      } +
      {
        "en_us": "Automatically Close Open Sessions After Midnight",
        "pl_pl": "Automatycznie zamykaj otwarte sesje po północy",
        "comment": " ",
      } +
      {
        "en_us": "Changes saved correctly",
        "pl_pl": "Zmiany zostały porpawnie zapisane",
        "comment": " ",
      } +
      {
        "en_us": "month",
        "pl_pl": "miesiąc",
        "comment": " ",
      } +
      {
        "en_us": "week",
        "pl_pl": "tydzień",
        "comment": " ",
      } +
      {
        "en_us": "day",
        "pl_pl": "dzień",
        "comment": " ",
      } +
      {
        "en_us": "Checkpoints",
        "pl_pl": "Punktly kontrolne",
        "comment": " ",
      } +
      {
        "en_us": "Access cards",
        "pl_pl": "Karty dostępowe",
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
