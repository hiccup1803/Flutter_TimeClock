import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Registration",
        "pl_pl": "Rejestracja",
        "comment": " ",
      } +
      {
        "en_us": "Invite code",
        "pl_pl": "Kod zaproszenia",
        "comment": " ",
      } +
      {
        "en_us": "The invite code is exactly 12 characters long",
        "pl_pl": "Kod musi mieć 12 znaków",
        "comment": " ",
      } +
      {
        "en_us": "Creating an employee account in company ",
        "pl_pl": "Tworzysz konto pracownika w firmie ",
        "comment": " ",
      } +
      {
        "en_us": "First & last name",
        "pl_pl": "Imie i nazwisko",
        "comment": " ",
      } +
      {
        "en_us": "Language",
        "pl_pl": "Język",
        "comment": " ",
      } +
      {
        "en_us": "Email",
        "pl_pl": "Email",
        "comment": " ",
      } +
      {
        "en_us": "Company name",
        "pl_pl": "Nazwa firmy",
        "comment": " ",
      } +
      {
        "en_us": "Rate currency",
        "pl_pl": "Waluta rozliczeń",
        "comment": " ",
      } +
      {
        "en_us": "Password",
        "pl_pl": "Hasło",
        "comment": " ",
      } +
      {
        "en_us": "Repeat password",
        "pl_pl": "Powtórz hasło",
        "comment": " ",
      } +
      {
        "en_us": "Create account",
        "pl_pl": "Stwórz konto",
        "comment": " ",
      } +
      {
        "en_us": "I accept ",
        "pl_pl": "Akceptuję ",
        "comment": " ",
      } +
      {
        "en_us": "Terms",
        "pl_pl": "Regulamin",
        "comment": " ",
      } +
      {
        "en_us": " and ",
        "pl_pl": " oraz ",
        "comment": " ",
      } +
      {
        "en_us": "Privacy Policy",
        "pl_pl": "Politykę prywatności",
        "comment": " ",
      } +

      {
        "en_us": "Invalid address",
        "pl_pl": "Nieprawidłowy adres",
        "comment": " ",
      } +
      {
        "en_us": "Account has been created",
        "pl_pl": "Konto zostało stworzone",
        "comment": " ",
      } +
      {
        "en_us": "You can log in now",
        "pl_pl": "Możesz się teraz zalogować",
        "comment": " ",
      } +
      {
        "en_us": "Passwords are different",
        "pl_pl": "Hasła są różne",
        "comment": " ",
      } +
      {
        "en_us": "A company name cannot remain without value.",
        "pl_pl": "Nazwa firmy nie może pozostać bez wartości.",
        "comment": " ",
      } +
      {
        "en_us": "The name and surname of the administrator cannot remain without value.",

        "pl_pl": "Imię i nazwisko administratora nie może pozostać bez wartości.",
        "comment": " ",
      } +
      {
        "en_us": "The administrator's email must not be left without value.",
        "pl_pl": "Email administratora nie może pozostać bez wartości.",
        "comment": " ",
      } +
      {
        "en_us": "The administrator password cannot be left empty.",
        "pl_pl": "Hasło administratora nie może pozostać bez wartości",
        "comment": " ",
      } +
      {
        "en_us": "https://staffmonitor.app/terms",
        "pl_pl": "https://staffmonitor.app/terms_pl",
        "comment": " ",
      } +
      {
        "en_us": "You can now log in with new password.",
        "pl_pl": "Możesz teraz zalogować się za pomocą nowego hasła.",
        "comment": " ",
      } +
      {
        "en_us": "I already have account - login",
        "pl_pl": "Mam już konto - zaloguj",
        "comment": " ",
      };

/* @EndTranslation */

  static var t = commonTranslations * _translation;

  String get i18n {
    return localize(this, t);
  }

  String i18nAs(String lang){
    return localize(this, t, locale: lang);
  }

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, t);

  String version(Object modifier) => localizeVersion(modifier, this, t);

  Map<String?, String> allVersions() => localizeAllVersions(this, t);
}
