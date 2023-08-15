// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
      id: json['id'] as int,
      event: json['event'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceUuid: json['uuid'] as String?,
      odometer: (json['odometer'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      speedAccuracy: (json['speedAccuracy'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      headingAccuracy: (json['headingAccuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      altitudeAccuracy: (json['altitudeAccuracy'] as num?)?.toDouble(),
      activityType: json['activityType'] as String?,
      activityConfidence: json['activityConfidence'] as int?,
      batteryIsCharging: json['batteryIsCharging'] as bool?,
      batteryLevel: (json['batteryLevel'] as num?)?.toDouble(),
      sessionId: json['sessionId'] as int?,
      createdAt:
          const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
    );

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event': instance.event,
      'timestamp': instance.timestamp.toIso8601String(),
      'uuid': instance.deviceUuid,
      'odometer': instance.odometer,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'speed': instance.speed,
      'speedAccuracy': instance.speedAccuracy,
      'heading': instance.heading,
      'headingAccuracy': instance.headingAccuracy,
      'altitude': instance.altitude,
      'altitudeAccuracy': instance.altitudeAccuracy,
      'activityType': instance.activityType,
      'activityConfidence': instance.activityConfidence,
      'batteryIsCharging': instance.batteryIsCharging,
      'batteryLevel': instance.batteryLevel,
      'sessionId': instance.sessionId,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
    };
