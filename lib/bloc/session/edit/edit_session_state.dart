part of 'edit_session_cubit.dart';

abstract class EditSessionState extends Equatable {
  const EditSessionState();
}

class EditSessionInitial extends EditSessionState {
  @override
  List<Object> get props => [];
}

class EditSessionReady extends EditSessionState {
  EditSessionReady(this.session, this.requireSaving, this.hadClockOut, this.changed,
      {this.sessionUserId:-1});

  final Session? session;
  final bool requireSaving;
  final hadClockOut;
  final changed;
  final sessionUserId;

  @override
  List<Object?> get props => [
        this.session,
        this.requireSaving,
        this.hadClockOut,
        this.changed,
        this.sessionUserId
      ];
}

class EditSessionProcessing extends EditSessionState {
  EditSessionProcessing(this.session);

  final Session? session;

  @override
  List<Object?> get props => [this.session];
}

class EditSessionError extends EditSessionState {
  EditSessionError(this.session, this.error);

  final Session? session;
  final AppError error;

  @override
  List<Object?> get props => [this.session, this.error];
}

class EditSessionSaved extends EditSessionState {
  EditSessionSaved(this.session, {this.closePage = false, this.silent = false});

  final Session? session;
  final bool closePage;
  final bool silent;

  @override
  List<Object?> get props => [this.session, this.closePage, this.silent];
}

class EditSessionDeleted extends EditSessionSaved {
  EditSessionDeleted(Session? session) : super(session, closePage: true);
}
