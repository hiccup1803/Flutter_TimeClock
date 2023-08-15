import 'package:i18n_extension/i18n_extension.dart';

import '../../page/common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "superadmin",
        "pl_pl": "superadmin",
        "comment": " ",
      } +
      {
        "en_us": "admin",
        "pl_pl": "admin",
        "comment": " ",
      } +
      {
        "en_us": "employee",
        "pl_pl": "pracownik",
        "comment": " ",
      } +
      {
        "en_us": "active",
        "pl_pl": "aktywny",
        "comment": " ",
      } +
      {
        "en_us": "deactivated",
        "pl_pl": "dezaktywowany",
        "comment": " ",
      } +
      {
        "en_us": "registered",
        "pl_pl": "zarejestrowany",
        "comment": " ",
      } ;

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
