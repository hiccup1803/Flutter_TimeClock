// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyProfile _$CompanyProfileFromJson(Map<String, dynamic> json) =>
    CompanyProfile(
      json['id'] as int,
      json['name'] as String?,
      json['contact'] as String?,
      json['filesLimit'] as int?,
      json['spaceLimit'] as int?,
      json['fileSizeLimit'] as int?,
      json['spaceLimitUnit'] as String?,
      json['timezone'] as String?,
      json['status'] as int?,
      json['employeeLimit'] as int?,
      const JsonBoolConverter().fromJson(json['autoClose'] as int?),
      const JsonBoolConverter().fromJson(json['autoCloseAfter24'] as int?),
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
      (json['customFields'] as List<dynamic>)
          .map((e) => AdminTaskCustomFiled.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompanyProfileToJson(CompanyProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contact': instance.contact,
      'filesLimit': instance.filesLimit,
      'spaceLimit': instance.spaceLimit,
      'fileSizeLimit': instance.fileSizeLimit,
      'spaceLimitUnit': instance.spaceLimitUnit,
      'timezone': instance.timezone,
      'status': instance.status,
      'employeeLimit': instance.employeeLimit,
      'autoClose': const JsonBoolConverter().toJson(instance.autoClose),
      'autoCloseAfter24':
          const JsonBoolConverter().toJson(instance.autoCloseAfter24),
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
      'customFields': instance.customFields,
    };
