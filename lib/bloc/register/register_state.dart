part of 'register_cubit.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  @override
  List<Object> get props => [];
}

class RegisterInputCode extends RegisterState {
  RegisterInputCode(this.inviteError);

  final String? inviteError;

  @override
  List<Object?> get props => [this.inviteError];
}

class RegisterInputDetails extends RegisterState {
  RegisterInputDetails(
    this.code,
    this.companyName,
    this.lang, {
    this.nameError,
    this.emailError,
    this.passwordError,
    this.repeatPasswordError,
  });

  final String? code;
  final String? companyName;
  final String? lang;

  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? repeatPasswordError;

  RegisterInputDetails copyWith({
    String? nameError,
    String? emailError,
    String? passwordError,
    String? repeatPasswordError,
  }) {
    return RegisterInputDetails(
      code,
      companyName,
      lang,
      nameError: nameError == '' ? null : (nameError ?? this.nameError),
      emailError: emailError == '' ? null : (emailError ?? this.emailError),
      passwordError: passwordError == '' ? null : (passwordError ?? this.passwordError),
      repeatPasswordError:
          repeatPasswordError == '' ? null : repeatPasswordError ?? this.repeatPasswordError,
    );
  }

  @override
  List<Object?> get props => [
        this.code,
        this.companyName,
        this.lang,
        this.nameError,
        this.emailError,
        this.passwordError,
        this.repeatPasswordError,
      ];
}

class RegisterProcessing extends RegisterState {
  final String? code;
  final bool validCode;

  RegisterProcessing(this.code, this.validCode);

  @override
  List<Object?> get props => [this.code, this.validCode];
}

class RegisterError extends RegisterState {
  final String? error;

  RegisterError(this.error);

  @override
  List<Object?> get props => [error];
}

class RegisterFinish extends RegisterState {
  @override
  List<Object> get props => [];
}
