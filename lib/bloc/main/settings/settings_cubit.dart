import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/company_profile.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/page/settings/settings.i18n.dart';
import 'package:staffmonitor/repository/company_repository.dart';
import 'package:staffmonitor/repository/profile_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';

import '../../../page/settings/settings.i18n.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._authCubit, this._profileRepository, this._userRepository,
      this._profileCompanyRepository)
      : super(SettingsEdit()) {
    init();
  }

  final log = Logger('SettingsCubit');
  final AuthCubit _authCubit;
  final ProfileRepository _profileRepository;
  final UsersRepository _userRepository;
  final CompanyRepository _profileCompanyRepository;

  String? lang;
  Project? defaultProject;
  int? activeEmployee;

  bool nameChanged = false,
      phoneChanged = false,
      lastLimitChanged = false,
      langChanged = false,
      defaultProjectChanged = false,
      preferredChanged = false,
      limitChanged = false,
      hourRateChanged = false,
      companyNameChanged = false,
      fileSizeChanged = false,
      contactDetailChanged = false,
      sessionAfterMidnight = false,
      sessionAfter24 = false;

  bool get anyChanges =>
      nameChanged ||
      phoneChanged ||
      lastLimitChanged ||
      langChanged ||
      defaultProjectChanged ||
      preferredChanged ||
      limitChanged ||
      hourRateChanged ||
      companyNameChanged ||
      fileSizeChanged ||
      contactDetailChanged ||
      sessionAfterMidnight ||
      sessionAfter24;

  Profile? get currentProfile {
    final AuthState state = _authCubit.state;
    if (state is AuthAuthorized) {
      return state.profile;
    }
    return null;
  }

  void init() {}

  Future<void> initWithProfile(Profile profile) async {
    await _userRepository.getAllEmployee().then((value) {
      activeEmployee = value.length;
    });
    if (lang == null || defaultProject == null) {
      lang = profile.lang ?? 'en';
      defaultProject = profile.defaultProject ?? null;
      emit(SettingsEdit(
          lang: lang, defaultProjectId: defaultProject?.id, activeEmployee: activeEmployee));
    }
  }

  void onNameChange(String name) {
    nameChanged = name != currentProfile?.name;
    log.finer('onNameChange: $name');
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        nameError: name.isEmpty ? 'Required'.i18n : '',
        defaultProjectId: defaultProject?.id,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        nameError: name.isEmpty ? 'Required'.i18n : '',
        lang: lang,
        defaultProjectId: defaultProject?.id,
      ));
    }
  }

  void onPhoneChange(String phone) {
    phoneChanged = int.tryParse(phone) != currentProfile!.phone;
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        defaultProjectId: defaultProject?.id,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        lang: lang,
        defaultProjectId: defaultProject?.id,
      ));
    }
  }

  void onLastLimitChange(String lastLimit) {
    lastLimitChanged = (int.tryParse(lastLimit) ?? 0) != currentProfile?.lastProjectsLimit;
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        defaultProjectId: defaultProject?.id,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        lang: lang,
        defaultProjectId: defaultProject?.id,
      ));
    }
  }

  void onHourRateChange(String hourRate) {
    hourRateChanged = hourRate != currentProfile?.hourRate;

    double? value = double.tryParse(hourRate);
    String? error;

    if (hourRate.isEmpty) {
      error = 'Invalid value'.i18n;
    } else if (value != null && value >= 1000) {
      error = 'Must be less than 1000.0'.i18n;
    } else {
      error = "";
    }
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        hourRateError: error,
        defaultProjectId: defaultProject?.id,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        hourRateError: error,
        lang: lang,
        defaultProjectId: defaultProject?.id,
      ));
    }
  }

  void onLangChange(String? lang) {
    this.lang = lang;
    langChanged = currentProfile!.lang != lang;
    final SettingsState s = state;
    try {
      if (s is SettingsEdit) {
        emit(s.copyWith(
          requireSaving: anyChanges,
          lang: lang,
          defaultProjectId: defaultProject?.id,
        ));
      } else {
        emit(SettingsEdit(
            requireSaving: anyChanges, lang: lang, defaultProjectId: defaultProject?.id));
      }
    } catch (e, stack) {
      log.shout('onLangChange', e, stack);
    }
  }

  void onCompanyNameChanged(String value, String originValue) {
    companyNameChanged = value != originValue;
    log.finer('onCompanyNameChanged: $value');
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        nameError: value.isEmpty ? 'Required'.i18n : '',
        defaultProjectId: defaultProject?.id,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        nameError: value.isEmpty ? 'Required'.i18n : '',
        lang: lang,
        defaultProjectId: defaultProject?.id,
      ));
    }
  }

  void onFileSizeChanged(String value, int originValue) {
    fileSizeChanged = (int.tryParse(value) ?? 0) != originValue;
    log.finer('onFileSizeChanged: $value');
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        nameError: value.isEmpty ? 'Required'.i18n : '',
        defaultProjectId: defaultProject?.id,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        nameError: value.isEmpty ? 'Required'.i18n : '',
        lang: lang,
        defaultProjectId: defaultProject?.id,
      ));
    }
  }

  void onContactDetailChanged(String value, String originValue) {
    contactDetailChanged = value != originValue;
    log.finer('onContactDetailChanged: $value');
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        nameError: value.isEmpty ? 'Required'.i18n : '',
        defaultProjectId: defaultProject?.id,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        nameError: value.isEmpty ? 'Required'.i18n : '',
        lang: lang,
        defaultProjectId: defaultProject?.id,
      ));
    }
  }

  void onDefaultProjectChange(int? id) {
    log.finer('onDefaultProjectChange: $id, $defaultProject');
    defaultProject = currentProfile!.availableProjects!.firstWhereOrNull((p) => p.id == id);
    log.finer('onDefaultProjectChange2 $defaultProject');

    defaultProjectChanged = currentProfile?.defaultProject?.id != defaultProject?.id;
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        defaultProjectId: defaultProject?.id,
      ));
    } else {
      emit(SettingsEdit(
          requireSaving: anyChanges, lang: lang, defaultProjectId: defaultProject?.id));
    }
  }

  void saveChanges() {
    emit(SettingsProcessing(readForm: true));
  }

  void getProfileCompany() async {
    _profileCompanyRepository.getProfileCompany().then((value) {
      return value ?? CompanyProfile.create();
    });
  }

  void updateProfile(
    String name,
    int? phone,
    int? lastLimit,
    String hourRate, {
    String? companyName,
    int? companyFileSizeLimit,
    String? companyContact,
    CompanyProfile? profileCompany,
  }) {
    emit(SettingsProcessing());

    _profileRepository
        .updateProfile(name, lang, phone, hourRate, currentProfile?.rateCurrency, lastLimit,
            defaultProject?.id)
        .then(
      (value) async {
        if (companyName != "" && profileCompany != null) {
          await updateProfileCompany(profileCompany);
        }
        log.fine('updateProfile value: $value');
        _authCubit.updateProfile(value);
        emit(SettingsSaved());
      },
      onError: (e, stack) {
        log.shout('updateProfile', e, stack);
        if (e is AppError) {
          if (e.formErrors?.isNotEmpty == true) {
            emit(SettingsEdit(
              requireSaving: anyChanges,
              lang: lang,
              defaultProjectId: defaultProject?.id,
              nameError: e.formErrors!.firstWhereOrNull((e) => e.field == 'name')?.message,
              phoneError: e.formErrors!.firstWhereOrNull((e) => e.field == 'phone')?.message,
              hourRateError: e.formErrors!.firstWhereOrNull((e) => e.field == 'hourRate')?.message,
              lastLimitError:
                  e.formErrors!.firstWhereOrNull((e) => e.field == 'lastProjectsLimit')?.message,
            ));
          } else {
            emit(SettingsEdit(
              requireSaving: anyChanges,
              lang: lang,
              defaultProjectId: defaultProject?.id,
              generalError: e.apiError!.message,
            ));
          }
        } else
          emit(SettingsEdit(
            requireSaving: anyChanges,
            lang: lang,
            defaultProjectId: defaultProject?.id,
            generalError: 'An error occurred'.i18n,
          ));
      },
    );
  }

  Future<CompanyProfile> updateProfileCompany(CompanyProfile profileCompany) async {
    CompanyProfile result = await _profileCompanyRepository.updateProfileCompany(
        id: profileCompany.id,
        name: profileCompany.name,
        contact: profileCompany.contact,
        autoClose: profileCompany.autoClose ? 1 : 0,
        autoCloseMidnight: profileCompany.autoCloseAfter24 ? 1 : 0);
    return result;
  }

  void validateChanges(String name, int? phone, int? lastLimit, String hourRate, String companyName,
      int? fileSizeLimit, String contactDetail) {
    langChanged = currentProfile!.lang != lang;
    defaultProjectChanged = currentProfile!.defaultProject?.id != defaultProject?.id;
    nameChanged = name != currentProfile?.name;
    phoneChanged = phone != currentProfile!.phone;
    lastLimitChanged = (lastLimit ?? 0) != currentProfile?.lastProjectsLimit;
    hourRateChanged = hourRate != currentProfile?.hourRate;

    log.fine('validateChanges: $defaultProject');
    companyNameChanged = false;
    fileSizeChanged = false;
    contactDetailChanged = false;

    emit(SettingsEdit(
      requireSaving: anyChanges,
      lang: lang,
      defaultProjectId: defaultProject?.id,
    ));
  }

  void closeSessionAfter24Changed(bool b, bool? autoCloseAfter24) {
    sessionAfter24 = b != autoCloseAfter24;
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        defaultProjectId: defaultProject?.id,
        sessionAfter24: b,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        defaultProjectId: defaultProject?.id,
        sessionAfter24: b,
      ));
    }
  }

  void closeSessionAfterMidnightChanged(bool b, bool? autoClose) {
    sessionAfterMidnight = b != autoClose;
    final SettingsState s = state;
    if (s is SettingsEdit) {
      emit(s.copyWith(
        requireSaving: anyChanges,
        defaultProjectId: defaultProject?.id,
        sessionAfterMidnight: b,
      ));
    } else {
      emit(SettingsEdit(
        requireSaving: anyChanges,
        defaultProjectId: defaultProject?.id,
        sessionAfterMidnight: b,
      ));
    }
  }
}
