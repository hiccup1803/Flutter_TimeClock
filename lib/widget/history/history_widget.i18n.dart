import 'package:i18n_extension/i18n_extension.dart';

import '../../page/common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Change password",
        "pl_pl": "Zmień hasło",
        "comment": " ",
      } +
      {
        "en_us": "You can now log in with new password.",
        "pl_pl": "Możesz teraz zalogować się za pomocą nowego hasła.",
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
