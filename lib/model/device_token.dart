import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'device_token.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class DeviceToken extends Equatable {
  const DeviceToken(this.id, this.token, this.createdAt);

  final int id;
  @JsonKey(name: 'device')
  final String token;
  final DateTime createdAt;


  factory DeviceToken.fromJson(Map<String, dynamic> json) {
    return _$DeviceTokenFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DeviceTokenToJson(this);

  @override
  List<Object?> get props => [this.id, this.token, this.createdAt];
}
