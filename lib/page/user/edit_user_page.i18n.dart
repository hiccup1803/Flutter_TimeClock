import 'package:i18n_extension/i18n_extension.dart';

import '../common_translations.i18n.dart';

extension Localization on String {
  /* @Translation */
  static var _translation = Translations("en_us") +
      {
        "en_us": "Must be at least 8 characters",
        "pl_pl": "Musi zawierać co najmniej 8 znaków",
        "comment": " ",
      } +
      {
        "en_us": "Must be less than 1000.0",
        "pl_pl": "Nie może być więcej niż 1000.0",
        "comment": " ",
      } +
      {
        "en_us": "Email",
        "pl_pl": "Email",
        "comment": " ",
      } +
      {
        "en_us": "First & Last name",
        "pl_pl": "Imię i nazwisko",
        "comment": " ",
      } +
      {
        "en_us": "Phone number",
        "pl_pl": "Numer telefonu",
        "comment": " ",
      } +
      {
        "en_us": "Language",
        "pl_pl": "Język",
        "comment": " ",
      } +
      {
        "en_us": "Projects",
        "pl_pl": "Projekty",
        "comment": " ",
      } +
      {
        "en_us": "Default",
        "pl_pl": "Domyślny",
        "comment": " ",
      } +
      {
        "en_us": "Hourly rate",
        "pl_pl": "Stawka godzinowa",
        "comment": " ",
      } +
      {
        "en_us": "Recent limit",
        "pl_pl": "Liczba ostatnich",
        "comment": " ",
      } +
      {
        "en_us": "Profile",
        "pl_pl": "Profil",
        "comment": " ",
      } +
      {
        "en_us": "Password",
        "pl_pl": "Hasło",
        "comment": " ",
      } +
      {
        "en_us": "Rate currency",
        "pl_pl": "Waluta rozliczeń",
        "comment": " ",
      } +
      {
        "en_us": "Info",
        "pl_pl": "Info",
        "comment": " ",
      } +
      {
        "en_us": "Employee Info",
        "pl_pl": "Informacja dla pracownika",
        "comment": " ",
      } +
      {
        "en_us": "Inner Admin Info",
        "pl_pl": "Wewnętrzne informacje dla Admina",
        "comment": " ",
      } +
      {
        "en_us": "Permissions",
        "pl_pl": "Uprawnienia",
        "comment": " ",
      } +
      {
        "en_us": "Generate Pin",
        "pl_pl": "Generuj Pin",
        "comment": " ",
      } +
      {
        "en_us": "Generate new pin code?",
        "pl_pl": "Generować nowy kod pin?",
        "comment": " ",
      } +
      {
        "en_us": "Generating new pin code will remove current pin code.",
        "pl_pl": "Wygenerowanie nowego kodu pin usunie aktualny kod.",
        "comment": " ",
      } +
      {
        "en_us": "Remove Pin",
        "pl_pl": "Usuń Pin",
        "comment": " ",
      } +
      {
        "en_us": "Remove pin code?",
        "pl_pl": "Usuńąć kod pin?",
        "comment": " ",
      } +
      {
        "en_us": "Reset password",
        "pl_pl": "Resetuj hasło",
        "comment": " ",
      } +
      {
        "en_us": "Reset user password?",
        "pl_pl": "Zresetować hasło użytkownika?",
        "comment": " ",
      } +
      {
        "en_us": "An email with instructions will be send to users email address.",
        "pl_pl": "Wiadomośc email z instrikcjami zostanie wysłana na adres email użytkonika.",
        "comment": " ",
      } +
      {
        "en_us": "Activate",
        "pl_pl": "Aktywuj",
        "comment": " ",
      } +
      {
        "en_us": "Deactivate",
        "pl_pl": "Deaktywuj",
        "comment": " ",
      } +
      {
        "en_us": "Deactivate user %s?",
        "pl_pl": "Deaktywować użytkonika %s?",
        "comment": " ",
      } +
      {
        "en_us": "Activate user %s?",
        "pl_pl": "Aktywować użytkonika %s?",
        "comment": " ",
      } +
      {
        "en_us": "Set as Employee",
        "pl_pl": "Ustaw jako pracownika",
        "comment": " ",
      } +
      {
        "en_us": "Set this user as Employee?",
        "pl_pl": "Ustawić tego użytkonika jako pracownika?",
        "comment": " ",
      } +
      {
        "en_us": "Set as Admin",
        "pl_pl": "Ustaw jako admina",
        "comment": " ",
      } +
      {
        "en_us": "Set this user as Admin?",
        "pl_pl": "Ustawić tego użytkownika jako admina?",
        "comment": " ",
      } +
      {
        "en_us": "Changes saved correctly",
        "pl_pl": "Zmiany poprawnie zapisane",
        "comment": " ",
      } +
      {
        "en_us": "User deactivated",
        "pl_pl": "Użytkownik został dezaktywowany",
        "comment": " ",
      } +
      {
        "en_us": "User activated",
        "pl_pl": "Użytkownik został aktywowany",
        "comment": " ",
      } +
      {
        "en_us": "User is now an employee",
        "pl_pl": "Użytkownik jest teraz pracownikiem",
        "comment": " ",
      } +
      {
        "en_us": "User is now an admin",
        "pl_pl": "Użytkownik jest teraz adminem",
        "comment": " ",
      } +
      {
        "en_us": "Reset password instructions send",
        "pl_pl": "Instruckje resetowania hasła zostały wysłane",
        "comment": " ",
      } +
      {
        "en_us": "New pin code: %s",
        "pl_pl": "Nowy kod pin: %s",
        "comment": " ",
      } +
      {
        "en_us": "Pin code deleted",
        "pl_pl": "Kod pin usunięty",
        "comment": " ",
      } +
      {
        "en_us": "Invalid value",
        "pl_pl": "Nieprawidłowa wartość",
        "comment": " ",
      } +
      {
        "en_us": "Allow Session Edit",
        "pl_pl": "Możliwość edycji sesji",
        "comment": " ",
      } +
      {
        "en_us": "Allow Adding Verified Session",
        "pl_pl": "Możliwość dodawania zatwierdzonych sesji",
        "comment": " ",
      } +
      {
        "en_us": "Adding a session with custom time will be automatically verified.",
        "pl_pl": "Dodanie sesji z wybranym czasem będzie automatycznie zatwierdzone.",
        "comment": " ",
      } +
      {
        "en_us": "Allow Session Remove",
        "pl_pl": "Możliwość usuwania sesji",
        "comment": " ",
      } +
      {
        "en_us": "Allow Bonus Adding",
        "pl_pl": "Możliwość dodawania bonusów",
        "comment": " ",
      } +
      {
        "en_us": "Allow Own Projects",
        "pl_pl": "Możliwość dodawania projektów",
        "comment": " ",
      } +
      {
        "en_us": "Assign All Users To New Project",
        "pl_pl": "Dodanie projektu przypisze do niego wszystkich pracowników",
        "comment": " ",
      } +
      {
        "en_us": "Allow Wage View",
        "pl_pl": "Możliwość zobaczenia swoich zarobków",
        "comment": " ",
      } +
      {
        "en_us": "Allow Hour Rate Edit",
        "pl_pl": "Możliwość edycji własnej stawki godzinowej",
        "comment": " ",
      } +
      {
        "en_us": "User will still not be allowed to edit stored session's rate.",
        "pl_pl": "Użytkownik wciąż nie będzie mógł edytować stawki już zapisanej sesji.",
        "comment": " ",
      } +
      {
        "en_us": "Allow New Session Hour Rate",
        "pl_pl": "Możliwość podania własnej stawki godzinowej dla nowej sesji",
        "comment": " ",
      } +
      {
        "en_us": "Allow Web Usage",
        "pl_pl": "Możliwość używania serwisu web",
        "comment": " ",
      } +
      {
        "en_us": "Allow GPS Tracking",
        "pl_pl": "Zezwól na śledzenie GPS",
        "comment": " ",
      } +
      {
        "en_us": "Allow Editing Verified Employee Session",
        "pl_pl": "Zezwalaj na edytowanie sesji zweryfikowanego pracownika",
        "comment": " ",
      } +
      {
        "en_us": "Allow Adding Verified Employee Session",
        "pl_pl": "Zezwalaj na dodawanie zweryfikowanych sesji pracownika",
        "comment": " ",
      } +
      {
        "en_us": "Allow Employee Bonus Adding",
        "pl_pl": "Zezwalaj na dodawanie premii dla pracowników",
        "comment": " ",
      } +
      {
        "en_us": "Allow All Wage View",
        "pl_pl": "Zezwól na podgląd wszystkich płac",
        "comment": " ",
      } +
      {
        "en_us": "Allow Access to Files Section",
        "pl_pl": "Zezwalaj na dostęp do sekcja plików",
        "comment": " ",
      } +
      {
        "en_us": "New employee",
        "pl_pl": "Nowy pracownik",
        "comment": " ",
      } +
      {
        "en_us": "Employee profile",
        "pl_pl": "Profil pracownika",
        "comment": "Drawer label",
      } +
      {
        "en_us": "Supervisor Permissions",
        "pl_pl": "Uprawnienia Supervisora",
        "comment": "Drawer label",
      } +
      {
        "en_us": "Select new role",
        "pl_pl": "Wybierz nową rolę",
        "comment": "Drawer label",
      } +
      {
        "en_us": "Role :",
        "pl_pl": "Rola :",
        "comment": "",
      } +
      {
        "en_us": "Super Admin",
        "pl_pl": "Super Admin",
        "comment": "",
      } +
      {
        "en_us": "Admin",
        "pl_pl": "Admin",
        "comment": "",
      } +
      {
        "en_us": "Supervisor",
        "pl_pl": "Supervisor",
        "comment": " ",
      } +
      {
        "en_us": "Employee",
        "pl_pl": "Pracownik",
        "comment": " ",
      } +
      {
        "en_us": "Active",
        "pl_pl": "Aktywny",
        "comment": " ",
      } +
      {
        "en_us": "Deactivated",
        "pl_pl": "Dezaktywowany",
        "comment": " ",
      } +
      {
        "en_us": "Registered",
        "pl_pl": "Zarejestrowany",
        "comment": " ",
      } +
      {
        "en_us": "Status :",
        "pl_pl": "Status :",
        "comment": " ",
      } +
      {
        "en_us": "Breaks :",
        "pl_pl": "przerwy :",
        "comment": " ",
      } +
      {
        "en_us": "Employee Information",
        "pl_pl": "Informacje Pracownika",
        "comment": "",
      } +
      {
        "en_us": "User Permissions",
        "pl_pl": "Uprawnienia użytkownika",
        "comment": "",
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
