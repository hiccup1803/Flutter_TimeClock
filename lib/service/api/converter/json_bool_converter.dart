import 'package:json_annotation/json_annotation.dart';

class JsonBoolConverter implements JsonConverter<bool, int?> {
  const JsonBoolConverter();

  @override
  bool fromJson(int? json) => (json ?? 0) > 0;

  @override
  int? toJson(bool? object) {
    if (object == null) {
      return null;
    } else if (object == true) {
      return 1;
    }
    return 0;
  }
}
