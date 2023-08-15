import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Email",
        "pl_pl": "Email",
        "comment": " ",
      } +
      {
        "en_us": "Sign in",
        "pl_pl": "Zaloguj się",
        "comment": " ",
      } +
      {
        "en_us": "Signed in",
        "pl_pl": "Zalogowano",
        "comment": " ",
      } +
      {
        "en_us": "Password",
        "pl_pl": "Hasło",
        "comment": " ",
      } +
      {
        "en_us": "Forgot password? - Recover it",
        "pl_pl": "Nie pamiętasz hasła? - Odzyskaj je",
        "comment": " ",
      } +
      {
        "en_us": "Have an invite code? - Register now",
        "pl_pl": "Masz zaproszenie? - Zarejestruj się",
        "comment": " ",
      } +
      {
        "en_us": "Don't have an account? - Register now",
        "pl_pl": "Nie masz konta? - Zarejestruj się",
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
