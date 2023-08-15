import 'package:json_annotation/json_annotation.dart';

class JsonStringConverter implements JsonConverter<String, int?> {
  const JsonStringConverter();

  @override
  String fromJson(int? json) => json.toString();

  @override
  int? toJson(String? object) {
    if (object == null) {
      return null;
    } else {
      return int.parse(object);
    }
  }
}
