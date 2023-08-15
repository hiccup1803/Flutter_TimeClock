import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Terminal registered",
        "pl_pl": "Terminal zarejestrowany",
        "comment": " ",
      } +
      {
        "en_us": "I'm an employer",
        "pl_pl": "Jestem pracodawcą",
        "comment": " ",
      } +
      {
        "en_us": "Setup terminal",
        "pl_pl": "Zamień w terminal",
        "comment": " ",
      } +
      {
        "en_us": "Terminal registered",
        "pl_pl": "Zarejestrowano terminal",
        "comment": " ",
      } +
      {
        "en_us": "Register device as terminal",
        "pl_pl": "Zarejestruj urządzenie jako terminal",
        "comment": " ",
      } +
      {
        "en_us": "Terminal ID",
        "pl_pl": "Terminal ID",
        "comment": " ",
      } +
      {
        "en_us": "One time code",
        "pl_pl": "Kod jednorazowy",
        "comment": " ",
      } +
      {
        "en_us": "Submit",
        "pl_pl": "Zatwierdź",
        "comment": " ",
      } +
      {
        "en_us": "You can generate ID and code at web version",
        "pl_pl": "Możesz wygenerować ID oraz kod na stronie internetowej",
        "comment": " ",
      } +
      {
        "en_us": "Your session will start in %ds",
        "pl_pl": "Twoja sesja rozpocznie się za %ds",
        "comment": " ",
      } +
      {
        "en_us": "Your session will end in %ds",
        "pl_pl": "Twoja sesja zakończy się za %ds",
        "comment": " ",
      } +
      {
        "en_us": "Work time",
        "pl_pl": "Czas pracy",
        "comment": " ",
      } +
      {
        "en_us": "Scan QR",
        "pl_pl": "Zeskanuj QR",
        "comment": " ",
      } +
      {
        "en_us": "Use PIN",
        "pl_pl": "Użyj PIN",
        "comment": " ",
      } +
      {
        "en_us": "Type one time code to deactivate this terminal",
        "pl_pl": "Podaj jednorazowy kod aby deaktywować ten terminal",
        "comment": " ",
      } +
      {
        "en_us": "Your session has ended.",
        "pl_pl": "Twoja sesja została zakończona.",
        "comment": " ",
      } +
      {
        "en_us": "New Terminal",
        "pl_pl": "Nowy Terminal",
        "comment": " ",
      } +
      {
        "en_us": "Name",
        "pl_pl": "Nazwa",
        "comment": " ",
      } +
      {
        "en_us": "Photo Verification",
        "pl_pl": "Weryfikacja zdjęcia",
        "comment": " ",
      } +
      {
        "en_us": "Select assigned project",
        "pl_pl": "Wybierz przypisany projekt",
        "comment": " ",
      } +
      {
        "en_us": "Add a checkpoint",
        "pl_pl": "Dodaj punkt kontrolny",
        "comment": " ",
      } +
      {
        "en_us": "Checkpoint",
        "pl_pl": "Punkty Kontrolne",
        "comment": " ",
      } +
      {
        "en_us": "Your session has started now.",
        "pl_pl": "Nowa sesja została rozpoczęta.",
        "comment": " ",
      } +
      {
        "en_us": "Terminal Access Code",
        "pl_pl": "Kod dostępu dla terminala",
        "comment": " ",
      } +
      {
        "en_us": "Generate access code",
        "pl_pl": "Wygeneruj kod dostępu",
        "comment": " ",
      } +
      {
        "en_us": "Confirmation required",
        "pl_pl": "Wymagane potwierdzenie",
        "comment": " ",
      } +
      {
        "en_us": "Are you sure you want to generate new access code for this terminal?",
        "pl_pl": "Czy na pewno wygenerować jednorazowy kod dostępu do terminala?",
        "comment": " ",
      } +
      {
        "en_us": "NFC Serial number",
        "pl_pl": "Numer seryjny taga NFC",
        "comment": " ",
      } +
      {
        "en_us": "Description",
        "pl_pl": "Opis",
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
