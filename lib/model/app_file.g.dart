// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppFileAdapter extends TypeAdapter<AppFile> {
  @override
  final int typeId = 5;

  @override
  AppFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppFile(
      fields[0] as int?,
      fields[1] as int?,
      fields[2] as String?,
      fields[3] as String?,
      fields[4] as int?,
      fields[5] as String?,
      fields[6] as int?,
      fields[7] as String?,
      fields[8] as String?,
      fields[9] as Uploader?,
      fields[10] as Project?,
      fields[11] as DateTime?,
      fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppFile obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.size)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.thumbnailStatus)
      ..writeByte(7)
      ..write(obj.fileDownloadUrl)
      ..writeByte(8)
      ..write(obj.thumbnailDownloadUrl)
      ..writeByte(9)
      ..write(obj.uploader)
      ..writeByte(10)
      ..write(obj.project)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppFile _$AppFileFromJson(Map<String, dynamic> json) => AppFile(
      json['id'] as int?,
      json['sessionId'] as int?,
      json['name'] as String?,
      json['type'] as String?,
      json['size'] as int?,
      json['note'] as String?,
      json['thumbnailStatus'] as int?,
      json['fileDownloadUrl'] as String?,
      json['thumbnailDownloadUrl'] as String?,
      json['uploader'] == null
          ? null
          : Uploader.fromJson(json['uploader'] as Map<String, dynamic>),
      json['project'] == null
          ? null
          : Project.fromJson(json['project'] as Map<String, dynamic>),
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$AppFileToJson(AppFile instance) => <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'note': instance.note,
      'thumbnailStatus': instance.thumbnailStatus,
      'fileDownloadUrl': instance.fileDownloadUrl,
      'thumbnailDownloadUrl': instance.thumbnailDownloadUrl,
      'uploader': instance.uploader,
      'project': instance.project,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
    };
