import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "File Details",
        "pl_pl": "Szczegóły pliku",
        "comment": " ",
      } +
      {
        "en_us": "Name: ",
        "pl_pl": "Nazwa: ",
        "comment": " ",
      } +
      {
        "en_us": "Size: ",
        "pl_pl": "Rozmiar: ",
        "comment": " ",
      } +
      {
        "en_us": "Upload date: ",
        "pl_pl": "Data przesłania: ",
        "comment": " ",
      } +
      {
        "en_us": "Uploader: ",
        "pl_pl": "Przesyłający: ",
        "comment": " ",
      } +
      {
        "en_us": "Project: ",
        "pl_pl": "Projekt: ",
        "comment": " ",
      } +
      {
        "en_us": "Note saved!",
        "pl_pl": "Uwaga zapisana!",
        "comment": " ",
      } +
      {
        "en_us": "Save note",
        "pl_pl": "Zapisz notatke",
        "comment": " ",
      } +
      {
        "en_us": "File deleted.",
        "pl_pl": "Plik usunięty.",
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
