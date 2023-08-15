import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/repository/users_repository.dart';

import '../../page/user/edit_user_page.i18n.dart';

part 'edit_user_state.dart';

class EditUserCubit extends Cubit<EditUserState> {
  EditUserCubit(this._usersRepository) : super(EditUserInitial());

  final log = Logger('EditUserCubit');
  final UsersRepository _usersRepository;

  bool get anyChanges =>
      ogUser.copyWith(id: 0) != currentUser.copyWith(id: 0) ||
      ogUser.id == Profile.create().id ||
      (ogUser.id != Profile.create().id && password?.isNotEmpty == true);

  String? lang;
  bool? paidBreak;
  String? password;

  late Profile currentUser;
  late Profile ogUser;

  void initWithProfile(Profile user) {
    // if (profile == null) profile = currentProfile;
    ogUser = user.id > 0 ? user : Profile.create();
    currentUser = user;
    lang = user.lang;
    paidBreak = user.paidBreaks;

    emit(EditUserEdit(
      ogUser: ogUser,
      user: currentUser,
      lang: lang,
      isPaidBreaks: paidBreak,
    ));
  }

  onEmailChange(String email) {
    log.finer('email: $email');
    currentUser = currentUser.copyWith(email: email);
    final error = email.isEmpty ? 'Required'.i18n : '';
    emitUpdate(emailError: error);
  }

  void onNameChange(String name) {
    log.finer('name: $name');
    currentUser = currentUser.copyWith(name: name);
    final error = name.isEmpty ? 'Required'.i18n : '';
    emitUpdate(nameError: error);
  }

  void onPhoneChange(String phone) {
    currentUser = currentUser.copyWith(
        allowNull: true, phone: phone.isNotEmpty == true ? int.tryParse(phone) : null);
    emitUpdate();
  }

  void onPhonePrefixChange(String phonePrefix) {
    currentUser = currentUser.copyWith(phonePrefix: phonePrefix);
    emitUpdate();
  }

  void onHourRateChange(String hourRate) {
    log.finest('onHourRateChange: $hourRate');
    double? value = double.tryParse(hourRate);
    String error = '';
    if (value == null || hourRate.isEmpty) {
      error = 'Invalid value'.i18n;
    } else if (value >= 1000) {
      error = 'Must be less than 1000.0'.i18n;
    }
    currentUser = currentUser.copyWith(hourRate: hourRate);
    emitUpdate(hourRateError: error);
  }

  void onCurrencyChange(String currency) {
    final error = currency.isEmpty ? 'Required'.i18n : '';
    currentUser = currentUser.copyWith(rateCurrency: currency);
    emitUpdate(currencyError: error);
  }

  void onLangChange(String? lang) {
    this.lang = lang;
    currentUser = currentUser.copyWith(lang: lang);
    // langChanged = ogUser.lang != lang;
    emitUpdate();
  }

  void onBreakChange(bool? b) {
    this.paidBreak = b;
    currentUser = currentUser.copyWith(isPaidBreaks: b);
    emitUpdate();
  }

  void onAdminInfoChange(String text) {
    currentUser = currentUser.copyWith(adminInfo: text);
    emitUpdate();
  }

  void onEmployeeInfoChange(String text) {
    currentUser = currentUser.copyWith(employeeInfo: text);
    emitUpdate();
  }

  void onPasswordChanged(String text) {
    password = text;
    String error;
    if (password!.isEmpty) {
      if (ogUser.isCreate) {
        error = 'Required'.i18n;
      } else {
        error = '';
      }
    } else if (password!.length < 8) {
      error = 'Must be at least 8 characters'.i18n;
    } else {
      error = '';
    }
    emitUpdate(passwordError: error);
  }

  void changeUserPermissions(Profile user) {
    currentUser = currentUser.copyWith(
      allowEdit: user.allowEdit,
      allowVerifiedAdd: user.allowVerifiedAdd,
      assignAllToProject: user.assignAllToProject,
      allowRemove: user.allowRemove,
      allowBonus: user.allowBonus,
      allowNewRate: user.allowNewRate,
      allowRateEdit: user.allowRateEdit,
      allowWageView: user.allowWageView,
      allowOwnProjects: user.allowOwnProjects,
      allowWeb: user.allowWeb,
      trackGps: user.trackGps,
      supervisorAllowAdd: user.supervisorAllowAdd,
      supervisorAllowEdit: user.supervisorAllowEdit,
      supervisorAllowBonusAdd: user.supervisorAllowBonusAdd,
      supervisorAllowWageView: user.supervisorAllowWageView,
      supervisorFilesAccess: user.supervisorFilesAccess,
    );
    emitUpdate();
  }

  void savedConsumed() {
    emit(EditUserEdit(
      ogUser: ogUser,
      user: currentUser,
      requireSaving: anyChanges,
      lang: lang,
      isPaidBreaks: paidBreak,
    ));
  }

  void errorConsumed() {
    emit(EditUserEdit(
      ogUser: ogUser,
      user: currentUser,
      requireSaving: anyChanges,
      lang: lang,
      isPaidBreaks: paidBreak,
    ));
  }

  void emitUpdate({
    String? hourRateError,
    String? currencyError,
    String? nameError,
    String? emailError,
    String? phoneError,
    String? passwordError,
    String? generalError,
  }) {
    final EditUserState s = state;
    if (s is EditUserEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        user: currentUser,
        hourRateError: hourRateError,
        currencyError: currencyError,
        nameError: nameError,
        emailError: emailError,
        phoneError: phoneError,
        passwordError: passwordError,
        lang: lang,
        isPaidBreaks: paidBreak,
      ));
    } else {
      emit(EditUserEdit(
        requireSaving: anyChanges,
        user: currentUser,
        ogUser: ogUser,
        hourRateError: hourRateError,
        nameError: nameError,
        emailError: emailError,
        phoneError: phoneError,
        generalError: generalError,
        passwordError: passwordError,
        lang: lang,
        isPaidBreaks: paidBreak,
      ));
    }
  }

  void saveChanges() {
    emit(EditUserProcessing(readForm: true));
  }

  void updateUser(
    String email,
    String name,
    String password,
    String phone,
    String phonePrefix,
    String hourRate,
    String currency,
    String adminInfo,
    String employeeInfo,
  ) {
    emit(EditUserProcessing());
    log.finest('updateUser: $currentUser, $ogUser');
    _usersRepository.updateOrCreate(currentUser, password: password).then(
      (value) {
        ogUser = value;
        currentUser = value;
        emit(EditUserSaved(ogUser));
      },
      onError: (e, stack) {
        log.shout('updateUser', e, stack);
        if (e is AppError) {
          if (e.formErrors?.isNotEmpty == true) {
            emit(EditUserEdit(
              ogUser: ogUser,
              user: currentUser,
              requireSaving: anyChanges,
              lang: lang,
              isPaidBreaks: paidBreak,
              nameError: e.formErrors!.firstWhereOrNull((e) => e.field == 'name')?.message,
              phoneError: e.formErrors!.firstWhereOrNull((e) => e.field == 'phone')?.message,
              hourRateError: e.formErrors!.firstWhereOrNull((e) => e.field == 'hourRate')?.message,
              emailError: e.formErrors!.firstWhereOrNull((e) => e.field == 'email')?.message,
              passwordError: e.formErrors!.firstWhereOrNull((e) => e.field == 'password')?.message,
            ));
          } else {
            emit(EditUserEdit(
              ogUser: ogUser,
              user: currentUser,
              requireSaving: anyChanges,
              lang: lang,
              isPaidBreaks: paidBreak,
              generalError: e.apiError!.message,
            ));
          }
        } else {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: 'An error occurred'.i18n,
          ));
        }
      },
    );
  }

  void generateNewPin() {
    emit(EditUserProcessing());
    _usersRepository.generatePin(ogUser.id).then(
      (value) {
        emit(EditUserEdit(
          ogUser: ogUser,
          user: currentUser,
          requireSaving: anyChanges,
          lang: lang,
          isPaidBreaks: paidBreak,
          successMessage: 'New pin code: %s'.i18n.fill([value]),
          successAsDialog: true,
        ));
      },
      onError: (e, stack) {
        if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: e.apiError!.message,
          ));
        } else {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: 'An error occurred'.i18n,
          ));
        }
      },
    );
  }

  void removePin() {
    emit(EditUserProcessing());
    _usersRepository.removePin(ogUser.id).then(
      (value) {
        emit(EditUserEdit(
          ogUser: ogUser,
          user: currentUser,
          requireSaving: anyChanges,
          lang: lang,
          isPaidBreaks: paidBreak,
          successMessage: 'Pin code deleted'.i18n,
        ));
      },
      onError: (e, stack) {
        if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: e.apiError!.message,
          ));
        } else {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: 'An error occurred'.i18n,
          ));
        }
      },
    );
  }

  void resetPassword() {
    emit(EditUserProcessing());
    _usersRepository.resetPassword(ogUser.id).then(
      (value) {
        emit(EditUserEdit(
          ogUser: ogUser,
          user: currentUser,
          requireSaving: anyChanges,
          lang: lang,
          isPaidBreaks: paidBreak,
          successMessage: 'Reset password instructions send'.i18n,
        ));
      },
      onError: (e, stack) {
        if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: e.apiError!.message,
          ));
        } else {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: 'An error occurred'.i18n,
          ));
        }
      },
    );
  }

  void deleteUser() {
    // _usersRepository.deleteUser(ogUser.id);
  }

  void deactivateUser() {
    emit(EditUserProcessing());
    _usersRepository.deactivateUser(ogUser.id).then(
      (value) {
        ogUser = value;
        currentUser = currentUser.copyWith(status: value.status);
        emit(EditUserEdit(
          ogUser: ogUser,
          user: currentUser,
          requireSaving: anyChanges,
          lang: lang,
          isPaidBreaks: paidBreak,
          successMessage: 'User deactivated'.i18n,
        ));
      },
      onError: (e, stack) {
        if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: e.apiError!.message,
          ));
        } else {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: 'An error occurred'.i18n,
          ));
        }
      },
    );
  }

  void activateUser() {
    emit(EditUserProcessing());
    _usersRepository.activateUser(ogUser.id).then(
      (value) {
        ogUser = value;
        currentUser = currentUser.copyWith(status: value.status);
        emit(EditUserEdit(
          ogUser: ogUser,
          user: currentUser,
          requireSaving: anyChanges,
          lang: lang,
          isPaidBreaks: paidBreak,
          successMessage: 'User activated'.i18n,
        ));
      },
      onError: (e, stack) {
        if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: e.apiError!.message,
          ));
        } else {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: 'An error occurred'.i18n,
          ));
        }
      },
    );
  }

  void setAsEmployee() {
    if (ogUser.id == -1) {
      ogUser = ogUser.copyWith(role: 1);
      currentUser = currentUser.copyWith(role: 1);
      emit(EditUserEdit(
        ogUser: ogUser,
        user: currentUser,
        requireSaving: anyChanges,
        lang: lang,
        isPaidBreaks: paidBreak,
        successMessage: 'User is now an employee '.i18n,
      ));
      return;
    }

    _usersRepository.demoteUser(ogUser.id, role: 1).then(
      (value) {
        ogUser = value;
        currentUser = currentUser.copyWith(role: value.role);
        emit(EditUserEdit(
          ogUser: ogUser,
          user: currentUser,
          requireSaving: anyChanges,
          lang: lang,
          isPaidBreaks: paidBreak,
          successMessage: 'User is now an employee '.i18n,
        ));
      },
      onError: (e, stack) {
        log.shout(e, stack);
        if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: e.apiError!.message,
          ));
        } else {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: 'An error occurred'.i18n,
          ));
        }
      },
    );
  }

  void setAsAdmin() {
    if (ogUser.id == -1) {
      ogUser = ogUser.copyWith(role: 7);
      currentUser = currentUser.copyWith(role: 7);
      emit(EditUserEdit(
        ogUser: ogUser,
        user: currentUser,
        requireSaving: anyChanges,
        lang: lang,
        isPaidBreaks: paidBreak,
        successMessage: 'User is now an admin'.i18n,
      ));
      return;
    }

    _usersRepository.promoteUser(ogUser.id, role: 7).then(
      (value) {
        ogUser = value;
        currentUser = currentUser.copyWith(role: value.role);
        emit(EditUserEdit(
          ogUser: ogUser,
          user: currentUser,
          requireSaving: anyChanges,
          lang: lang,
          isPaidBreaks: paidBreak,
          successMessage: 'User is now an admin'.i18n,
        ));
      },
      onError: (e, stack) {
        log.shout(e, stack);
        if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: e.apiError!.message,
          ));
        } else {
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            generalError: 'An error occurred'.i18n,
          ));
        }
      },
    );
  }

  void setAsSupervisor(bool isPromote) {
    if (ogUser.id == -1) {
      ogUser = ogUser.copyWith(role: 5);
      currentUser = currentUser.copyWith(role: 5);
      emit(EditUserEdit(
        ogUser: ogUser,
        user: currentUser,
        requireSaving: anyChanges,
        lang: lang,
        isPaidBreaks: paidBreak,
        successMessage: 'User is now an Supervisor'.i18n,
      ));
      return;
    }

    if (isPromote)
      _usersRepository.promoteUser(ogUser.id, role: 5).then(
        (value) {
          ogUser = value;
          currentUser = currentUser.copyWith(role: value.role);
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            successMessage: 'User is now an Supervisor'.i18n,
          ));
        },
        onError: (e, stack) {
          log.shout(e, stack);
          if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
            emit(EditUserEdit(
              ogUser: ogUser,
              user: currentUser,
              requireSaving: anyChanges,
              lang: lang,
              isPaidBreaks: paidBreak,
              generalError: e.apiError!.message,
            ));
          } else {
            emit(EditUserEdit(
              ogUser: ogUser,
              user: currentUser,
              requireSaving: anyChanges,
              lang: lang,
              isPaidBreaks: paidBreak,
              generalError: 'An error occurred'.i18n,
            ));
          }
        },
      );
    else
      _usersRepository.demoteUser(ogUser.id, role: 5).then(
        (value) {
          ogUser = value;
          currentUser = currentUser.copyWith(role: value.role);
          emit(EditUserEdit(
            ogUser: ogUser,
            user: currentUser,
            requireSaving: anyChanges,
            lang: lang,
            isPaidBreaks: paidBreak,
            successMessage: 'User is now an Supervisor'.i18n,
          ));
        },
        onError: (e, stack) {
          log.shout(e, stack);
          if (e is AppError && e.apiError?.message?.isNotEmpty == true) {
            emit(EditUserEdit(
              ogUser: ogUser,
              user: currentUser,
              requireSaving: anyChanges,
              lang: lang,
              isPaidBreaks: paidBreak,
              generalError: e.apiError!.message,
            ));
          } else {
            emit(EditUserEdit(
              ogUser: ogUser,
              user: currentUser,
              requireSaving: anyChanges,
              lang: lang,
              isPaidBreaks: paidBreak,
              generalError: 'An error occurred'.i18n,
            ));
          }
        },
      );
  }
}
