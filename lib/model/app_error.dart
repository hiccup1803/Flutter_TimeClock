import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_error.g.dart';

class AppError extends Equatable implements Exception {
  final ApiError? apiError;
  final List<FormErrorMessage>? formErrors;

  List<String?> get messages => (apiError?.message?.isNotEmpty == true)
      ? [apiError!.message]
      : <String?>[] + formErrors!.map((e) => e.message).toList();

  String? formatted() {
    if (messages.length == 1) {
      return messages[0];
    } else {
      return messages.join('\n');
    }
  }

  @override
  String toString() => 'AppError{apiError: $apiError, formErrors: $formErrors}';

  AppError(this.apiError, this.formErrors);

  AppError.fromMessage(String message) : this(ApiError(0, 0, null, message), null);

  @override
  List<Object?> get props => [this.apiError, this.formErrors];

  static AppError from(dynamic e) => e is AppError
      ? e
      : e is Exception
          ? AppError.fromMessage(e.toString())
          : AppError(null, null);
}

@JsonSerializable()
class ApiError extends Equatable {
  final int? status;
  final int? code;
  final String? name;
  final String? message;

  @override
  String toString() => 'ApiError{status: $status, code: $code, name: $name, message: $message}';

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  ApiError(this.status, this.code, this.name, this.message);

  @override
  List<Object?> get props => [this.status, this.code, this.name, this.message];
}

@JsonSerializable()
class FormErrorMessage extends Equatable {
  final String? field;
  final String? message;

  @override
  String toString() => 'FormErrorMessage{field: $field, message: $message}';

  factory FormErrorMessage.fromJson(Map<String, dynamic> json) => _$FormErrorMessageFromJson(json);

  Map<String, dynamic> toJson() => _$FormErrorMessageToJson(this);

  FormErrorMessage(this.field, this.message);

  @override
  List<Object?> get props => [this.field, this.message];
}
