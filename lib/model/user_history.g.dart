// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHistory _$UserHistoryFromJson(Map<String, dynamic> json) => UserHistory(
      json['username'] as String,
      const JsonDateTimeConverter().fromJson(json['current'] as int?),
      (json['lastWeek'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(DateTime.parse(k), e as int),
      ),
      json['currentMonth'] as int,
      json['previousMonth'] as int,
      json['photoVerification'] as int,
    );

Map<String, dynamic> _$UserHistoryToJson(UserHistory instance) =>
    <String, dynamic>{
      'username': instance.username,
      'current': const JsonDateTimeConverter()
          .toJson(instance.currentSessionStartedAt),
      'lastWeek':
          instance.lastWeek.map((k, e) => MapEntry(k.toIso8601String(), e)),
      'currentMonth': instance.currentMonthSeconds,
      'previousMonth': instance.previousMonthSeconds,
      'photoVerification': instance.photoVerification,
    };
