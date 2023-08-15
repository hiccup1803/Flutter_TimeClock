// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 1;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      fields[0] as int,
      fields[1] as String?,
      fields[2] as String?,
      fields[3] as int?,
      fields[4] as String?,
      fields[5] as String?,
      (fields[6] as List?)?.cast<int>(),
      fields[7] as int?,
      fields[8] as int?,
      fields[9] as String?,
      fields[10] as String?,
      fields[11] as int?,
      fields[12] as int?,
      fields[13] as String?,
      fields[14] as String?,
      fields[15] as Project?,
      (fields[16] as List?)?.cast<Project>(),
      fields[17] as bool,
      fields[18] as bool,
      fields[19] as bool,
      fields[20] as bool,
      fields[21] as bool,
      fields[22] as bool,
      fields[23] as bool,
      fields[24] as bool,
      fields[25] as bool,
      fields[26] as bool,
      fields[27] as bool,
      fields[28] as bool,
      fields[29] as bool,
      fields[30] as bool,
      fields[31] as bool,
      fields[32] as bool,
      fields[33] as bool,
      fields[34] as DateTime?,
      fields[35] as DateTime?,
      fields[36] as bool,
      fields[37] as String?,
      fields[38] as bool,
      fields[39] as bool,
      fields[40] as bool,
      fields[41] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(42)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.phonePrefix)
      ..writeByte(5)
      ..write(obj.lang)
      ..writeByte(6)
      ..write(obj.preferredProjects)
      ..writeByte(7)
      ..write(obj.lastProjectsLimit)
      ..writeByte(8)
      ..write(obj.maxFilesInSession)
      ..writeByte(9)
      ..write(obj.employeeInfo)
      ..writeByte(10)
      ..write(obj.adminInfo)
      ..writeByte(11)
      ..write(obj.role)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.hourRate)
      ..writeByte(14)
      ..write(obj.rateCurrency)
      ..writeByte(15)
      ..write(obj.defaultProject)
      ..writeByte(16)
      ..write(obj.availableProjects)
      ..writeByte(17)
      ..write(obj.allowEdit)
      ..writeByte(18)
      ..write(obj.allowVerifiedAdd)
      ..writeByte(19)
      ..write(obj.allowRemove)
      ..writeByte(20)
      ..write(obj.allowBonus)
      ..writeByte(21)
      ..write(obj.allowWageView)
      ..writeByte(22)
      ..write(obj.allowOwnProjects)
      ..writeByte(23)
      ..write(obj.assignAllToProject)
      ..writeByte(24)
      ..write(obj.allowWeb)
      ..writeByte(25)
      ..write(obj.allowRateEdit)
      ..writeByte(26)
      ..write(obj.allowNewRate)
      ..writeByte(27)
      ..write(obj.swaggerApiAccess)
      ..writeByte(28)
      ..write(obj.supervisorAllowEdit)
      ..writeByte(29)
      ..write(obj.supervisorAllowAdd)
      ..writeByte(30)
      ..write(obj.supervisorAllowBonusAdd)
      ..writeByte(31)
      ..write(obj.supervisorAllowWageView)
      ..writeByte(32)
      ..write(obj.supervisorFilesAccess)
      ..writeByte(33)
      ..write(obj.supervisorGpsAccess)
      ..writeByte(34)
      ..write(obj.createdAt)
      ..writeByte(35)
      ..write(obj.updatedAt)
      ..writeByte(36)
      ..write(obj.trackGps)
      ..writeByte(37)
      ..write(obj.timezone)
      ..writeByte(38)
      ..write(obj.allowClosingOwnTasks)
      ..writeByte(39)
      ..write(obj.allowClosingAssignedTasks)
      ..writeByte(40)
      ..write(obj.paidBreaks)
      ..writeByte(41)
      ..write(obj.supervisorCalendarAccess);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      json['id'] as int,
      json['name'] as String?,
      json['email'] as String?,
      json['phone'] as int?,
      json['phonePrefix'] as String?,
      json['lang'] as String?,
      (json['preferredProjects'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      json['lastProjectsLimit'] as int?,
      json['maxFilesInSession'] as int?,
      json['employeeInfo'] as String?,
      json['adminInfo'] as String?,
      json['role'] as int?,
      json['status'] as int?,
      json['hourRate'] as String?,
      json['rateCurrency'] as String?,
      json['defaultProject'] == null
          ? null
          : Project.fromJson(json['defaultProject'] as Map<String, dynamic>),
      (json['availableProjects'] as List<dynamic>?)
          ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      const JsonBoolConverter().fromJson(json['allowEdit'] as int?),
      const JsonBoolConverter().fromJson(json['allowVerifiedAdd'] as int?),
      const JsonBoolConverter().fromJson(json['allowRemove'] as int?),
      const JsonBoolConverter().fromJson(json['allowBonus'] as int?),
      const JsonBoolConverter().fromJson(json['allowWageView'] as int?),
      const JsonBoolConverter().fromJson(json['allowOwnProjects'] as int?),
      const JsonBoolConverter().fromJson(json['assignAllToProject'] as int?),
      const JsonBoolConverter().fromJson(json['allowWeb'] as int?),
      const JsonBoolConverter().fromJson(json['allowRateEdit'] as int?),
      const JsonBoolConverter().fromJson(json['allowNewRate'] as int?),
      const JsonBoolConverter().fromJson(json['swaggerApiAccess'] as int?),
      const JsonBoolConverter().fromJson(json['supervisorAllowEdit'] as int?),
      const JsonBoolConverter().fromJson(json['supervisorAllowAdd'] as int?),
      const JsonBoolConverter()
          .fromJson(json['supervisorAllowBonusAdd'] as int?),
      const JsonBoolConverter()
          .fromJson(json['supervisorAllowWageView'] as int?),
      const JsonBoolConverter().fromJson(json['supervisorFilesAccess'] as int?),
      const JsonBoolConverter().fromJson(json['supervisorGpsAccess'] as int?),
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
      const JsonBoolConverter().fromJson(json['trackGps'] as int?),
      json['timezone'] as String?,
      const JsonBoolConverter().fromJson(json['allowClosingOwnTasks'] as int?),
      const JsonBoolConverter()
          .fromJson(json['allowClosingAssignedTasks'] as int?),
      const JsonBoolConverter().fromJson(json['paidBreaks'] as int?),
      const JsonBoolConverter()
          .fromJson(json['supervisorCalendarAccess'] as int?),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'phonePrefix': instance.phonePrefix,
      'lang': instance.lang,
      'preferredProjects': instance.preferredProjects,
      'lastProjectsLimit': instance.lastProjectsLimit,
      'maxFilesInSession': instance.maxFilesInSession,
      'employeeInfo': instance.employeeInfo,
      'adminInfo': instance.adminInfo,
      'role': instance.role,
      'status': instance.status,
      'hourRate': instance.hourRate,
      'rateCurrency': instance.rateCurrency,
      'defaultProject': instance.defaultProject,
      'availableProjects': instance.availableProjects,
      'allowEdit': const JsonBoolConverter().toJson(instance.allowEdit),
      'allowVerifiedAdd':
          const JsonBoolConverter().toJson(instance.allowVerifiedAdd),
      'allowRemove': const JsonBoolConverter().toJson(instance.allowRemove),
      'allowBonus': const JsonBoolConverter().toJson(instance.allowBonus),
      'allowWageView': const JsonBoolConverter().toJson(instance.allowWageView),
      'allowOwnProjects':
          const JsonBoolConverter().toJson(instance.allowOwnProjects),
      'assignAllToProject':
          const JsonBoolConverter().toJson(instance.assignAllToProject),
      'allowWeb': const JsonBoolConverter().toJson(instance.allowWeb),
      'allowRateEdit': const JsonBoolConverter().toJson(instance.allowRateEdit),
      'allowNewRate': const JsonBoolConverter().toJson(instance.allowNewRate),
      'swaggerApiAccess':
          const JsonBoolConverter().toJson(instance.swaggerApiAccess),
      'supervisorAllowEdit':
          const JsonBoolConverter().toJson(instance.supervisorAllowEdit),
      'supervisorAllowAdd':
          const JsonBoolConverter().toJson(instance.supervisorAllowAdd),
      'supervisorAllowBonusAdd':
          const JsonBoolConverter().toJson(instance.supervisorAllowBonusAdd),
      'supervisorAllowWageView':
          const JsonBoolConverter().toJson(instance.supervisorAllowWageView),
      'supervisorFilesAccess':
          const JsonBoolConverter().toJson(instance.supervisorFilesAccess),
      'supervisorGpsAccess':
          const JsonBoolConverter().toJson(instance.supervisorGpsAccess),
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
      'trackGps': const JsonBoolConverter().toJson(instance.trackGps),
      'timezone': instance.timezone,
      'allowClosingOwnTasks':
          const JsonBoolConverter().toJson(instance.allowClosingOwnTasks),
      'allowClosingAssignedTasks':
          const JsonBoolConverter().toJson(instance.allowClosingAssignedTasks),
      'paidBreaks': const JsonBoolConverter().toJson(instance.paidBreaks),
      'supervisorCalendarAccess':
          const JsonBoolConverter().toJson(instance.supervisorCalendarAccess),
    };
