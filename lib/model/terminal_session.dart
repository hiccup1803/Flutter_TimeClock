import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'terminal_session.g.dart';

@JsonSerializable()
class TerminalSession extends Equatable {
  TerminalSession(
    this.terminalId,
    this.userName,
    this.sessionStatus,
    this.timeInSeconds,
    this.clockId,
  );

  @JsonKey(name: 'terminal')
  final String terminalId;
  @JsonKey(name: 'user')
  final String userName;
  @JsonKey(name: 'session')
  final String sessionStatus;
  @JsonKey(name: 'time')
  final int? timeInSeconds;
  @JsonKey(name: 'clockId')
  final int? clockId; // Session Time in Seconds (If Closed)≤

  factory TerminalSession.fromJson(Map<String, dynamic> json) => _$TerminalSessionFromJson(json);

  bool get isStarted => sessionStatus.toLowerCase() == 'started';

  bool get isClosed => sessionStatus.toLowerCase() == 'closed';

  Map<String, dynamic> toJson() => _$TerminalSessionToJson(this);

  @override
  String toString() {
    return 'TerminalSession{terminalId: $terminalId, userName: $userName, sessionStatus: $sessionStatus, timeInSeconds: $timeInSeconds, clockId: $clockId}';
  }

  @override
  List<Object?> get props => [
        this.terminalId,
        this.userName,
        this.sessionStatus,
        this.timeInSeconds,
        this.clockId,
      ];
}
