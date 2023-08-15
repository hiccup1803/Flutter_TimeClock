// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_nfc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminNfc _$AdminNfcFromJson(Map<String, dynamic> json) => AdminNfc(
      json['id'] as int,
      json['userId'] as int?,
      json['serialNumber'] as String,
      json['type'] as String?,
      json['description'] as String?,
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
    );

Map<String, dynamic> _$AdminNfcToJson(AdminNfc instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'serialNumber': instance.serialNumber,
      'type': instance.type,
      'description': instance.description,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
    };

ApiNfc _$ApiNfcFromJson(Map<String, dynamic> json) => ApiNfc(
      json['serialNumber'] as String?,
      type: json['type'] as String?,
      description: json['description'] as String?,
      userId: json['userId'] as int?,
    );

Map<String, dynamic> _$ApiNfcToJson(ApiNfc instance) {
  final val = <String, dynamic>{
    'serialNumber': instance.serialNumber,
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  writeNotNull('userId', instance.userId);
  return val;
}
