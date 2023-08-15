part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  Locale? get locale => null;

  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthAuthorized extends AuthState {
  AuthAuthorized(this.profile);

  final Profile? profile;

  @override
  Locale? get locale {
    if (profile?.lang?.toLowerCase() == 'pl') {
      return Locale('pl', 'PL');
    } else if (profile?.lang?.toLowerCase() == 'en') {
      return Locale('en', 'US');
    }
    return null;
  }

  @override
  List<Object?> get props => [profile];
}

class AuthUnauthorized extends AuthState {
  final AppError? error;

  AuthUnauthorized([this.error]);

  @override
  List<Object?> get props => [error];
}
