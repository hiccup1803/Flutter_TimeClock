import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'user_location.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class UserLocation extends Equatable {
  final int id;
  final String? event;
  final DateTime timestamp;
  @JsonKey(name: 'uuid')
  final String? deviceUuid;
  final double? odometer;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? speedAccuracy;
  final double? heading;
  final double? headingAccuracy;
  final double? altitude;
  final double? altitudeAccuracy;
  final String? activityType;
  final int? activityConfidence;
  final bool? batteryIsCharging;
  final double? batteryLevel;
  final int? sessionId;
  final DateTime? createdAt;

  UserLocation({
    required this.id,
    this.event,
    required this.timestamp,
    this.deviceUuid,
    this.odometer,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.speedAccuracy,
    this.heading,
    this.headingAccuracy,
    this.altitude,
    this.altitudeAccuracy,
    this.activityType,
    this.activityConfidence,
    this.batteryIsCharging,
    this.batteryLevel,
    this.sessionId,
    this.createdAt,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) => _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);

  @override
  List<Object?> get props => [
        this.id,
        this.event,
        this.timestamp,
        this.deviceUuid,
        this.odometer,
        this.latitude,
        this.longitude,
        this.accuracy,
        this.speed,
        this.speedAccuracy,
        this.heading,
        this.headingAccuracy,
        this.altitude,
        this.altitudeAccuracy,
        this.activityType,
        this.activityConfidence,
        this.batteryIsCharging,
        this.batteryLevel,
        this.sessionId,
        this.createdAt,
      ];
}
