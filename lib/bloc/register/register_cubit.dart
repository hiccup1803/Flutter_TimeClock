import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chopper/chopper.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/invitation_details.dart';
import 'package:staffmonitor/page/register/register_page.i18n.dart';
import 'package:staffmonitor/service/api/registration_service.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registrationService, {this.code})
      : super(RegisterInitial()) {
    processCode();
  }

  final _log = Logger('RegisterCubit');
  final RegisterService _registrationService;

  String? code;
  InvitationDetails? invitation;
  Timer? _codeDelay;

  void inviteChanged(String newCode) {
    if (state is! RegisterProcessing) {
      var prevCode = code;
      code = newCode;
      if (code!.isNotEmpty != true && prevCode != null) {
        _codeDelay?.cancel();
        emit(RegisterInputCode('Required'.i18n));
      } else if (code != prevCode) {
        _codeDelay?.cancel();
        _codeDelay = Timer(Duration(milliseconds: 1000), processCode);
      }
    }
  }

  void processCode() {
    if (code?.isNotEmpty == true) {
      if (code!.length != 12) {
        emit(RegisterInputCode(
            'The invite code is exactly 12 characters long'.i18n));
        return;
      }

      emit(RegisterProcessing(code, false));
      _registrationService.check(code).then(
        (response) {
          if (response.isSuccessful) {
            invitation = response.body;
            emit(RegisterInputDetails(
              code,
              invitation!.companyName,
              invitation!.lang,
            ));
          } else {
            var error = response.error;
            error = (error is AppError) ? error.apiError?.message : null;
            emit(RegisterInputCode(error as String? ?? 'Error'.i18n));
          }
        },
        onError: (e, stack) {
          var error;
          if (e is Response) {
            error = e.body?.apiError?.message;
          }
          emit(RegisterInputCode(error ?? 'Error'.i18n));
        },
      );
    }
  }

  void registerAccount({
    required String name,
    required String email,
    required String password,
    required String repeatedPassword,
  }) {
    String? nameError;
    String? emailError;
    String? passwordError;
    String? repeatedPasswordError;
    bool invalid = false;

    if (name.isNotEmpty != true) {
      nameError = 'Required'.i18n;
      invalid = true;
    }
    if (email.isNotEmpty != true) {
      emailError = 'Required'.i18n;
      invalid = true;
    }
    if (password.isNotEmpty != true) {
      passwordError = 'Required'.i18n;
      invalid = true;
    }

    if (repeatedPassword != password) {
      repeatedPasswordError = 'Passwords are different'.i18n;
      invalid = true;
    }
    if (repeatedPassword.isNotEmpty != true) {
      repeatedPasswordError = 'Required'.i18n;
      invalid = true;
    }

    if (invalid) {
      emit(RegisterInputDetails(code, invitation!.companyName, invitation!.lang,
          nameError: nameError,
          emailError: emailError,
          passwordError: passwordError,
          repeatPasswordError: repeatedPasswordError));
    } else {
      _processRegistration(name, email, password);
    }
  }

  void _processRegistration(
    String name,
    String email,
    String password,
  ) {
    emit(RegisterProcessing(code, true));
    _registrationService.register(code, name, email, password).then(
      (profile) {
        emit(RegisterFinish());
      },
      onError: (e, stack) {
        if (e is Response) {
          AppError? error = e.body as AppError?;
          if (error?.formErrors?.isNotEmpty == true) {
            var codeError = error!.formErrors!
                .firstWhereOrNull((element) => element.field == 'code')
                ?.message;
            if (codeError?.isNotEmpty != false) {
              emit(RegisterInputCode(codeError));
            } else
              emit(RegisterInputDetails(
                code,
                invitation!.companyName,
                invitation!.lang,
                nameError: error.formErrors!
                    .firstWhereOrNull((element) => element.field == 'name')
                    ?.message,
                emailError: error.formErrors!
                    .firstWhereOrNull((element) => element.field == 'email')
                    ?.message,
                passwordError: error.formErrors!
                    .firstWhereOrNull((element) => element.field == 'password')
                    ?.message,
              ));
          } else {
            emit(RegisterError(error!.apiError?.message));
          }
        } else {
          _log.shout('register error', e, stack);
          emit(RegisterError('An error occurred'.i18n));
        }
      },
    );
  }

  void nameChanged(String value) {
    if (state is RegisterInputDetails) {
      RegisterInputDetails invalid = state as RegisterInputDetails;
      var error = '';
      if (value.isNotEmpty != true) {
        error = 'Required'.i18n;
      }
      emit(invalid.copyWith(nameError: error));
    }
  }

  void emailChanged(String value) {
    if (state is RegisterInputDetails) {
      RegisterInputDetails invalid = state as RegisterInputDetails;
      var error = '';
      if (value.isNotEmpty != true) {
        error = 'Required'.i18n;
      }
      emit(invalid.copyWith(emailError: error));
    }
  }

  void passwordChanged(String value, String repeated) {
    if (state is RegisterInputDetails) {
      RegisterInputDetails invalid = state as RegisterInputDetails;
      var error = '';
      if (value.isNotEmpty != true) {
        error = 'Required'.i18n;
      }
      var error2 = '';
      if (value.compareTo(repeated) != 0) {
        error2 = 'Passwords are different'.i18n;
      }
      if (repeated.isNotEmpty != true) {
        error2 = 'Required'.i18n;
      }
      emit(invalid.copyWith(passwordError: error, repeatPasswordError: error2));
    }
  }

  void onErrorClosed() {
    processCode();
  }
}
