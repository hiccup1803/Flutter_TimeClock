// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multiplier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Multiplier _$MultiplierFromJson(Map<String, dynamic> json) => Multiplier(
      (json['multiplier'] as num).toDouble(),
      json['time'] as int?,
    );

Map<String, dynamic> _$MultiplierToJson(Multiplier instance) =>
    <String, dynamic>{
      'multiplier': instance.multiplier,
      'time': instance.time,
    };
