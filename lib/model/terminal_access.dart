import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'terminal_access.g.dart';

@JsonSerializable()
class TerminalAccess extends Equatable {
  TerminalAccess(this.terminalId, this.name, this.companyName, this.status);

  @JsonKey(name: 'terminal')
  final String terminalId;
  final String name;
  @JsonKey(name: 'company')
  final String companyName;
  final int status;

  factory TerminalAccess.fromJson(Map<String, dynamic> json) => _$TerminalAccessFromJson(json);

  Map<String, dynamic> toJson() => _$TerminalAccessToJson(this);

  @override
  String toString() =>
      'TerminalAccess{terminalId: $terminalId, name: $name, companyName: $companyName, status: $status}';

  @override
  List<Object?> get props => [
        this.terminalId,
        this.name,
        this.companyName,
        this.status,
      ];
}
