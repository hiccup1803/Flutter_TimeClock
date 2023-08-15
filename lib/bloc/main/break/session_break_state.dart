part of 'session_break_cubit.dart';

abstract class SessionBreakState extends Equatable {
  List<SessionBreak> get breakList;

  const SessionBreakState();
}

class SessionBreakIdle extends SessionBreakState {
  final List<SessionBreak> breakList;

  const SessionBreakIdle({this.breakList = const []});

  @override
  List<Object?> get props => [this.breakList];
}

class SessionBreakOpen extends SessionBreakState {
  final List<SessionBreak> breakList;
  final SessionBreak? currentBreak;

  const SessionBreakOpen(this.breakList, this.currentBreak);

  @override
  List<Object?> get props => [this.breakList, this.currentBreak];
}

class SessionBreakApiProcess extends SessionBreakState {
  final List<SessionBreak> breakList;

  const SessionBreakApiProcess({this.breakList = const []});

  @override
  List<Object?> get props => [breakList];
}

class SessionBreakError extends SessionBreakState {
  final dynamic error;

  const SessionBreakError(this.error);

  @override
  List<SessionBreak> get breakList => [];

  @override
  List<Object?> get props => [error];
}
