part of 'edit_off_time_cubit.dart';

abstract class EditOffTimeState extends Equatable {
  const EditOffTimeState();
}

class EditOffTimeInitial extends EditOffTimeState {
  @override
  List<Object> get props => [];
}

class EditOffTimeReady extends EditOffTimeState {
  EditOffTimeReady(this.savedOffTime, this.offTime, this.requireSaving, this.changed, this.users);

  final OffTime savedOffTime;
  final OffTime offTime;
  final List<Profile>? users;
  final bool requireSaving;
  final changed;

  @override
  List<Object?> get props => [
        this.offTime,
        this.users,
        this.requireSaving,
        this.changed,
      ];
}

class EditOffTimeProcessing extends EditOffTimeState {
  EditOffTimeProcessing(this.offTime);

  final OffTime offTime;

  @override
  List<Object?> get props => [this.offTime];
}

class EditOffTimeError extends EditOffTimeState {
  EditOffTimeError(this.offTime, this.error);

  final OffTime offTime;
  final AppError error;

  @override
  List<Object?> get props => [this.offTime, this.error];
}

class EditOffTimeSaved extends EditOffTimeState {
  EditOffTimeSaved(this.offTime, {this.closePage = false});

  final OffTime offTime;
  final bool closePage;

  @override
  List<Object?> get props => [this.offTime, this.closePage];
}

class EditOffTimeDeleted extends EditOffTimeSaved {
  EditOffTimeDeleted(OffTime offTime) : super(offTime, closePage: true);
}
