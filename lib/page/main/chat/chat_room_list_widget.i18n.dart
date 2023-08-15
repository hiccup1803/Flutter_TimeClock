import 'package:i18n_extension/i18n_extension.dart';

import '../../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Loading",
        "pl_pl": "Ładowanie",
        "comment": " ",
      } +
      {
        "en_us": "Error",
        "pl_pl": "Błąd",
        "comment": " ",
      } +
      {
        "en_us": "No message found",
        "pl_pl": "Nie znaleziono wiadomości",
        "comment": " ",
      } +
      {
        "en_us": "Are you sure? You will lost all data in this room",
        "pl_pl": "Jesteś pewien? Stracisz wszystkie informacje w tym pokoju",
        "comment": " ",
      } +
      {
        "en_us": "No chat rooms found",
        "pl_pl": "Nie znaleziono pokojów rozmów",
        "comment": " ",
      } +
      {
        "en_us": "Chat",
        "pl_pl": "Czat",
        "comment": " ",
      } +
      {
        "en_us": "last message",
        "pl_pl": "ostatnia wiadomość",
        "comment": " ",
      } +
      {
        "en_us": "Select User",
        "pl_pl": "Wybierz Pracownika",
        "comment": " ",
      } +
      {
        "en_us": "New group",
        "pl_pl": "Nowa grupa",
        "comment": " ",
      } +
      {
        "en_us": "Add participants",
        "pl_pl": "Dodaj uczestników",
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
