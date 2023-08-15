import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/repository/auth_repository.dart';

class AuthInterceptor implements RequestInterceptor, ResponseInterceptor {
  static const String AUTH_HEADER = "Authorization";

  final AuthRepository authRepository;
  final log = Logger('AuthInterceptor');

  AuthInterceptor(this.authRepository);

  @override
  FutureOr<Request> onRequest(Request request) async {
    final token = await authRepository.getValidAuthTokenOrRefresh();
    log.fine('onRequest: $token');
    var headersWithAuth = Map<String, String>.of(request.headers);
    headersWithAuth[AUTH_HEADER] = token?.bearerToken ?? '';
    return request.copyWith(headers: headersWithAuth);
  }

  @override
  FutureOr<Response> onResponse(Response<dynamic> response) {
    // log.fine('onResponse: $response');
    return response;
  }
}
