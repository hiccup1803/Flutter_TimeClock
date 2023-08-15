import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Recover password",
        "pl_pl": "Odzywskiwanie hasła",
        "comment": " ",
      } +
      {
        "en_us": "Reset password",
        "pl_pl": "Zresetuj hasło",
        "comment": " ",
      } +
      {
        "en_us": "I have reset password token",
        "pl_pl": "Mam token resstujacy hasło",
        "comment": " ",
      } +
      {
        "en_us": "Token",
        "pl_pl": "Token",
        "comment": " ",
      } +
      {
        "en_us": "Set new password",
        "pl_pl": "Ustaw nowe hasło",
        "comment": " ",
      } +
      {
        "en_us": "Send me the token",
        "pl_pl": "Wyślij mi token",
        "comment": " ",
      } +
      {
        "en_us": "You can now log in with the new password.",
        "pl_pl": "Możesz teraz zalogować się za pomocą nowego hasła.",
        "comment": " ",
      } +
      {
        "en_us": "Invalid address",
        "pl_pl": "Nieprawidłowy adres",
        "comment": " ",
      } +
      {
        "en_us": "An email has been send with reset token.",
        "pl_pl": "Wysnało email z tokenem potrzebnym do ustawienia nowego hasła.",
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
