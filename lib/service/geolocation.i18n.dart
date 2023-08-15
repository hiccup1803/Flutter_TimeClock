import 'package:i18n_extension/i18n_extension.dart';

import '../page/common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Allow Staff Monitor to access to this device's location in the background?",
        "pl_pl": " ",
        "comment": " ",
      } +
      {
        "en_us":
            "In order to track your activity efficiently, please enable 'Allow all the time' location permission.",
        "pl_pl": " ",
        "comment": " ",
      } +
      {
        "en_us": "Change to 'Allow all the time'",
        "pl_pl": " ",
        "comment": " ",
      } +
      {
        "en_us": "Background location is not enabled",
        "pl_pl": " ",
        "comment": " ",
      } +
      {
        "en_us": "Location is not enabled",
        "pl_pl": " ",
        "comment": " ",
      } +
      {
        "en_us":
            "To use background location, you must enable \'Always\' in the Location Services settings.",
        "pl_pl": " ",
        "comment": " ",
      } +
      {
        "en_us": "Settings",
        "pl_pl": " ",
        "comment": " ",
      } +
      {
        "en_us": "Location is not enabled.",
        "pl_pl": " ",
        "comment": " ",
      } +
      {
        "en_us": "Updating location...",
        "pl_pl": "Aktualizacja lokalizacji...",
        "comment": " ",
      } +
      {
        "en_us": "Tap here to open app",
        "pl_pl": " ",
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
