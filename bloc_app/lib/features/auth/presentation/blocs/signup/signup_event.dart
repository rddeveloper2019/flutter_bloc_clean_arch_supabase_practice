part of 'signup_bloc.dart';

sealed class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

final class SignupRequestEvent extends SignupEvent {
  const SignupRequestEvent({
    required this.email,
    required this.password,
    required this.username,
  });

  final String email;
  final String password;
  final String username;

  @override
  List<Object?> get props => [email, password, username];

  @override
  String toString() {
    return 'SignupRequestEvent{email=$email, password=$password, username=$username}';
  }
}
