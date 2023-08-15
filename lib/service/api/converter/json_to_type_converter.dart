import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/app_error.dart';

class JsonToTypeConverter extends JsonConverter {
  JsonToTypeConverter(this.typeToJsonFactoryMap);

  final Map<Type, Function> typeToJsonFactoryMap;
  final log = Logger('JsonToTypeConverter');

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    try {
      return response.copyWith(
        body: fromJsonData<BodyType, InnerType>(
          response.body,
          typeToJsonFactoryMap[InnerType],
          response.headers,
        ),
      );
    } catch (e, stack) {
      log.finer('convertResponse ${BodyType.runtimeType}, ${InnerType.toString()}');
      log.shout('parse error', e, stack);
      throw AppError.fromMessage('Parse Error: $e');
    }
  }

  T? fromJsonData<T, InnerType>(
    String jsonData,
    Function? jsonParser, [
    Map<String, String>? headers,
  ]) {
    if (jsonParser == null) {
      return null;
    }
    var jsonMap = json.decode(jsonData);

    if (jsonMap is List) {
      return jsonMap.map((item) => jsonParser(item as Map<String, dynamic>) as InnerType).toList()
          as T;
    }

    return jsonParser(jsonMap);
  }
}
