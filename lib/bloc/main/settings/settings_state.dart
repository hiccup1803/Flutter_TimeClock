part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  @override
  List<Object> get props => [];
}

class SettingsProcessing extends SettingsState {
  final bool readForm;

  SettingsProcessing({this.readForm = false});

  @override
  List<Object> get props => [readForm];
}

class SettingsSaved extends SettingsProcessing {
  @override
  List<Object> get props => [];
}

class SettingsEdit extends SettingsState {
  final bool requireSaving;

  final String? nameError;
  final String? phoneError;
  final String? hourRateError;
  final String? lastLimitError;
  final String? lang;
  final int? defaultProjectId;
  final int? activeEmployee;
  final String? generalError;
  final bool? sessionAfterMidnight;
  final bool? sessionAfter24;

  SettingsEdit({
    this.requireSaving = false,
    this.nameError,
    this.phoneError,
    this.hourRateError,
    this.lastLimitError,
    this.lang,
    this.defaultProjectId,
    this.activeEmployee,
    this.generalError,
    this.sessionAfterMidnight,
    this.sessionAfter24,
  });

  bool get noErrors =>
      nameError?.isNotEmpty != true &&
      phoneError?.isNotEmpty != true &&
      hourRateError?.isNotEmpty != true &&
      lastLimitError?.isNotEmpty != true;

  SettingsEdit copyWith({
    required bool requireSaving,
    String? nameError,
    String? phoneError,
    String? hourRateError,
    String? lang,
    String? lastLimitError,
    required int? defaultProjectId,
    bool? sessionAfterMidnight,
    bool? sessionAfter24,
  }) =>
      SettingsEdit(
        requireSaving: requireSaving,
        nameError: nameError == '' ? null : nameError ?? this.nameError,
        phoneError: phoneError == '' ? null : phoneError ?? this.phoneError,
        hourRateError: hourRateError == '' ? null : hourRateError ?? this.hourRateError,
        lastLimitError: lastLimitError == '' ? null : lastLimitError ?? this.lastLimitError,
        lang: lang ?? this.lang,
        defaultProjectId: defaultProjectId,
        sessionAfterMidnight: sessionAfterMidnight,
        sessionAfter24: sessionAfter24,
      );

  @override
  List<Object?> get props => [
        this.requireSaving,
        this.nameError,
        this.phoneError,
        this.hourRateError,
        this.lastLimitError,
        this.lang,
        this.defaultProjectId,
        this.activeEmployee,
        this.generalError,
        this.sessionAfterMidnight,
        this.sessionAfter24
      ];
}
