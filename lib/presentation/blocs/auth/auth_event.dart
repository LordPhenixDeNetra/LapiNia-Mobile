part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthEmailPasswordSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthEmailPasswordSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthEmailPasswordSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthEmailPasswordSignUpRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserProfileUpdated extends AuthEvent {
  final Map<String, dynamic> profile;

  const AuthUserProfileUpdated({required this.profile});

  @override
  List<Object?> get props => [profile];
}
