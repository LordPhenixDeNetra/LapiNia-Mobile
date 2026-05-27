part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthPhoneSubmitted extends AuthEvent {
  final String phone;

  const AuthPhoneSubmitted({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class AuthOtpSubmitted extends AuthEvent {
  final String phone;
  final String token;

  const AuthOtpSubmitted({required this.phone, required this.token});

  @override
  List<Object?> get props => [phone, token];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserProfileUpdated extends AuthEvent {
  final Map<String, dynamic> profile;

  const AuthUserProfileUpdated({required this.profile});

  @override
  List<Object?> get props => [profile];
}
