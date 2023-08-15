import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'terminal_session_nfc.g.dart';

@JsonSerializable()
class TerminalSessionNfc extends Equatable {
  TerminalSessionNfc(
    this.nfc,
    this.terminalId,
    this.userName,
    this.sessionStatus,
    this.timeInSeconds,
    this.clockId,
  );

  @JsonKey(name: 'nfc')
  final String? nfc;
  @JsonKey(name: 'terminal')
  final String? terminalId;
  @JsonKey(name: 'user')
  final String? userName;
  @JsonKey(name: 'session')
  final String? sessionStatus;
  @JsonKey(name: 'time')
  final int? timeInSeconds;
  @JsonKey(name: 'clockId')
  final int? clockId; // Session Time in Seconds (If Closed)≤

  bool get isStarted => sessionStatus?.toLowerCase() == 'started';

  bool get isClosed => sessionStatus?.toLowerCase() == 'closed';

  bool get hasNfc => nfc != null;

  factory TerminalSessionNfc.fromJson(Map<String, dynamic> json) =>
      _$TerminalSessionNfcFromJson(json);

  Map<String, dynamic> toJson() => _$TerminalSessionNfcToJson(this);

  @override
  String toString() {
    return 'TerminalSessionNfc{nfc: $nfc, terminalId: $terminalId, userName: $userName, sessionStatus: $sessionStatus, timeInSeconds: $timeInSeconds, clockId: $clockId}';
  }

  @override
  List<Object?> get props => [
        this.nfc,
        this.terminalId,
        this.userName,
        this.sessionStatus,
        this.timeInSeconds,
        this.clockId,
      ];
}
