import 'package:json_annotation/json_annotation.dart';

class JsonDateTimeConverter implements JsonConverter<DateTime?, int?> {
  const JsonDateTimeConverter();

  //zamienic na sekund bo api nie rozumie milisekund
  @override
  int? toJson(DateTime? object) {
    return object != null ? object.millisecondsSinceEpoch ~/ 1000 : null;
  }

  @override
  DateTime? fromJson(int? json) {
    if (json != null)
      return DateTime.fromMillisecondsSinceEpoch(json * 1000);
    else
      return null;
  }
}
