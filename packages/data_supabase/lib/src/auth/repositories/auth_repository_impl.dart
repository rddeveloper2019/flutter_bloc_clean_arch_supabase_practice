import 'dart:async';

import 'package:core/errors.dart';
import 'package:domain/auth.dart';
import 'package:fpdart/fpdart.dart';

import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDatasource authRemoteDatasource})
    : _authRemoteDatasource = authRemoteDatasource;

  final AuthRemoteDatasource _authRemoteDatasource;

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    final controller = StreamController<UserEntity?>();
    final subscription = _authRemoteDatasource.onAuthStateChanged.listen(
      (UserModel? userModel) {
        controller.add(userModel);
      },
      onError: (error) {
        print('Auth stream error :  $error');
        controller.add(null);
      },
    );

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  @override
  Future<Either<Failure, void>> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await _authRemoteDatasource.signup(
        email: email,
        password: password,
        username: username,
      );

      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _authRemoteDatasource.login(email: email, password: password);

      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _authRemoteDatasource.logout();
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }
}
