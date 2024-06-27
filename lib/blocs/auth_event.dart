import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserLoggedIn extends AuthEvent {
  final User user;
  const AuthUserLoggedIn({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUserLoggedOut extends AuthEvent {}