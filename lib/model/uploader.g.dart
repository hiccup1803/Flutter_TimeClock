// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uploader.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploaderAdapter extends TypeAdapter<Uploader> {
  @override
  final int typeId = 6;

  @override
  Uploader read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Uploader(
      fields[0] as int,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Uploader obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploaderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Uploader _$UploaderFromJson(Map<String, dynamic> json) => Uploader(
      json['id'] as int,
      json['name'] as String,
    );

Map<String, dynamic> _$UploaderToJson(Uploader instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
