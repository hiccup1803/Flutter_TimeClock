// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_terminal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTerminal _$AdminTerminalFromJson(Map<String, dynamic> json) =>
    AdminTerminal(
      json['id'] as String,
      json['name'] as String,
      const JsonStringConverter().fromJson(json['code'] as int?),
      json['status'] as int,
      json['photoVerification'] as int?,
      json['project'] == null
          ? null
          : AdminProject.fromJson(json['project'] as Map<String, dynamic>),
      const JsonDateTimeConverter().fromJson(json['codeExpiresAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$AdminTerminalToJson(AdminTerminal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': _$JsonConverterToJson<int?, String>(
          instance.code, const JsonStringConverter().toJson),
      'status': instance.status,
      'photoVerification': instance.photoVerification,
      'project': instance.project,
      'codeExpiresAt':
          const JsonDateTimeConverter().toJson(instance.codeExpiresAt),
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

ApiTerminal _$ApiTerminalFromJson(Map<String, dynamic> json) => ApiTerminal(
      json['name'] as String?,
      projectId: json['projectId'] as int?,
      photoVerification: json['photoVerification'] as int?,
    );

Map<String, dynamic> _$ApiTerminalToJson(ApiTerminal instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'projectId': instance.projectId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('photoVerification', instance.photoVerification);
  return val;
}
