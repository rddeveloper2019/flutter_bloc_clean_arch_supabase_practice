part of 'authentication_bloc.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.authenticationStatus = AuthenticationStatus.unknown,
    this.user,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(UserEntity user)
    : this._(
        authenticationStatus: AuthenticationStatus.authenticated,
        user: user,
      );

  const AuthenticationState.unauthenticated()
    : this._(authenticationStatus: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus authenticationStatus;
  final UserEntity? user;

  @override
  List<Object?> get props => [authenticationStatus, user];
}
