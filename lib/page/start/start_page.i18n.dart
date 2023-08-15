import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "I am employee - worker",
        "pl_pl": "Jestem pracownikiem",
        "comment": " ",
      } +
      {
        "en_us": "I am company owner\nor freelancer",
        "pl_pl": "Jestem pracodawcą\nlub freelancerem",
        "comment": " ",
      } +
      {
        "en_us": "Change app to KIOSK mode",
        "pl_pl": "Zamień w terminal RCP",
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
