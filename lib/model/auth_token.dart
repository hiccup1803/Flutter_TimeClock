import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_token.g.dart';

abstract class AuthToken extends Equatable {
  String get accessToken;

  String get refreshToken;

  String get bearerToken;

  bool get isValid;

  bool get isRefreshValid;
}

@JsonSerializable()
class JwtToken extends AuthToken {
  final String access;
  final String refresh;
  final DateTime expiration;
  final DateTime refreshExpiration;

  JwtToken(
    this.access,
    this.refresh,
  )   : this.expiration = _parseExpiration(access),
        this.refreshExpiration = _parseExpiration(refresh);

  String get accessToken => access;

  String get refreshToken => refresh;

  factory JwtToken.fromJson(Map<String, dynamic> json) => _$JwtTokenFromJson(json);

  Map<String, dynamic> toJson() => _$JwtTokenToJson(this);

  static DateTime _parseExpiration(String jwt) {
    if (jwt.isNotEmpty != true) {
      throw FormatException('Error when parsing token: is empty');
    }
    var split = jwt.split('.');
    if (split.length < 2 || split[1].isEmpty) {
      throw FormatException('Error when parsing token');
    }
    var data = split[1];

    String output = data.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    String decoded = utf8.decode(base64Url.decode(output));

    var decodedJson = json.decode(decoded);
    var exp = decodedJson['exp']; // int.parse(decodedJson['exp']);
    var dateTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

    return dateTime;
  }

  @override
  bool get isRefreshValid {
    return refresh.isNotEmpty == true && DateTime.now().isBefore(refreshExpiration);
  }

  @override
  bool get isValid {
    return access.isNotEmpty == true && DateTime.now().isBefore(expiration);
  }

  @override
  String get bearerToken => 'Bearer $access';

  @override
  List<Object> get props => [access, refresh, expiration, refreshExpiration];

  @override
  String toString() =>
      'AuthToken{ access: $isValid, expiration: $expiration, refresh: $isRefreshValid , expiration: $refreshExpiration}';
}