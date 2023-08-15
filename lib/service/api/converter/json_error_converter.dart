import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/app_error.dart';

class JsonErrorConverter extends ErrorConverter {
  final log = Logger('JsonErrorConverter');

  @override
  FutureOr<Response> convertError<BodyType, InnerType>(
      Response response) async {
    // log.fine("parse error, ${response.statusCode}, body: ${response.body}");

    if (response.statusCode == 404) {
      // return response.copyWith(bodyError: AppError.fromMessage('Error 404'));

      return response.copyWith(bodyError: AppError.fromMessage(json.decode(response.body)["message"]));
    }
    try {
      final decoded = jsonDecode(response.bodyString);
      var formErrors;
      var apiError;
      log.fine('jsonDecode2: ${decoded.runtimeType}');
      if (decoded is List) {
        formErrors = decoded
            .map((e) => FormErrorMessage.fromJson(e))
            .toList(growable: false);
      } else {
        apiError = ApiError.fromJson(decoded);
      }
      log.warning('parsed errors: $apiError, $formErrors');

      return response.copyWith(bodyError: AppError(apiError, formErrors));
    } catch (e, stack) {
      log.shout('parse error', e, stack);
      return response.copyWith(
          bodyError: AppError.fromMessage('Parse error: $e'));
    }
  }
}
