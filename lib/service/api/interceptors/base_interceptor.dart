import 'dart:async';

import 'package:chopper/chopper.dart';

import '../converter/json_date_time_converter.dart';

class BaseInterceptor extends RequestInterceptor {
  final dateTimeConverter = JsonDateTimeConverter();

  @override
  FutureOr<Request> onRequest(Request request) {
    final parameters = Map<String, dynamic>.from(request.parameters);
    request.parameters.forEach((key, value) {
      if (value is DateTime) {
        parameters[key] = dateTimeConverter.toJson(value);
      }
    });

    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';

    return request.copyWith(parameters: parameters, headers: headers);
  }
}
