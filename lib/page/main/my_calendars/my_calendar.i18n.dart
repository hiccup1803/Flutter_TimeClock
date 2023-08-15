import 'package:i18n_extension/i18n_extension.dart';

import '../../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Sessions",
        "pl_pl": "Sesje",
        "comment": " ",
      } +
      {
        "en_us": "Earnings",
        "pl_pl": "Zarobek",
        "comment": " ",
      } +
      {
        "en_us": "No projects",
        "pl_pl": "Brak projektów",
        "comment": " ",
      } +
      {
        "en_us": "Downloading projects",
        "pl_pl": "Pobieranie projektów",
        "comment": " ",
      } +
      {
        "en_us": "Time",
        "pl_pl": "Czas",
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
