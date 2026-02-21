part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

final class LoginRequestEvent extends LoginEvent {
  const LoginRequestEvent({required this.email, required this.password});

  final String email;
  final String password;

  @override
  String toString() {
    return 'LoginRequestEvent{email=$email, password=$password}';
  }

  @override
  List<Object?> get props => [email, password];
}
