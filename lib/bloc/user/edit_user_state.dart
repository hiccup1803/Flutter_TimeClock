part of 'edit_user_cubit.dart';

abstract class EditUserState extends Equatable {
  const EditUserState();
}

class EditUserInitial extends EditUserState {
  @override
  List<Object> get props => [];
}

class EditUserProcessing extends EditUserState {
  final bool readForm;

  EditUserProcessing({this.readForm = false});

  @override
  List<Object?> get props => [readForm];
}

class EditUserSaved extends EditUserProcessing {
  final Profile savedProfile;

  EditUserSaved(this.savedProfile);

  @override
  List<Object?> get props => [savedProfile];
}

class EditUserEdit extends EditUserState {
  final Profile ogUser;
  final Profile user;

  final bool requireSaving;
  final bool successAsDialog;

  final String? nameError;
  final String? phoneError;
  final String? hourRateError;
  final String? currencyError;
  final String? emailError;
  final String? passwordError;
  final String? lang;
  final bool? isPaidBreaks;
  final String? generalError;
  final String? successMessage;

  EditUserEdit({
    this.requireSaving = false,
    required this.ogUser,
    required this.user,
    this.nameError,
    this.phoneError,
    this.hourRateError,
    this.currencyError,
    this.emailError,
    this.passwordError,
    this.lang,
    this.isPaidBreaks,
    this.generalError,
    this.successMessage,
    this.successAsDialog = false,
  });

  bool get noErrors =>
      nameError?.isNotEmpty != true &&
      phoneError?.isNotEmpty != true &&
      hourRateError?.isNotEmpty != true &&
      currencyError?.isNotEmpty != true &&
      passwordError?.isNotEmpty != true &&
      emailError?.isNotEmpty != true;

  EditUserEdit copyWith({
    required bool requireSaving,
    String? nameError,
    String? phoneError,
    String? hourRateError,
    String? currencyError,
    String? lang,
    bool? isPaidBreaks,
    String? emailError,
    String? passwordError,
    String? generalError,
    Profile? user,
  }) =>
      EditUserEdit(
        ogUser: ogUser,
        user: user ?? this.user,
        requireSaving: requireSaving,
        generalError: generalError == '' ? null : generalError ?? this.generalError,
        nameError: nameError == '' ? null : (nameError ?? this.nameError),
        phoneError: phoneError == '' ? null : (phoneError ?? this.phoneError),
        passwordError: passwordError == '' ? null : (passwordError ?? this.passwordError),
        hourRateError: hourRateError == '' ? null : (hourRateError ?? this.hourRateError),
        currencyError: currencyError == '' ? null : (currencyError ?? this.currencyError),
        emailError: emailError == '' ? null : (emailError ?? this.emailError),
        lang: lang ?? this.lang,
        isPaidBreaks: isPaidBreaks ?? this.isPaidBreaks,
      );

  @override
  List<Object?> get props => [
        this.ogUser,
        this.user,
        this.requireSaving,
        this.nameError,
        this.phoneError,
        this.hourRateError,
        this.currencyError,
        this.passwordError,
        this.emailError,
        this.lang,
        this.isPaidBreaks,
        this.generalError
      ];
}