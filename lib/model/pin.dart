import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pin.g.dart';

@JsonSerializable()
class Pin extends Equatable {
  final int id;
  @JsonKey(name: 'pin')
  final String value;

  Pin(this.id, this.value);

  @override
  List<Object?> get props => [id, value];

  factory Pin.fromJson(Map<String, dynamic> json) => _$PinFromJson(json);

  Map<String, dynamic> toJson() => _$PinToJson(this);
}
