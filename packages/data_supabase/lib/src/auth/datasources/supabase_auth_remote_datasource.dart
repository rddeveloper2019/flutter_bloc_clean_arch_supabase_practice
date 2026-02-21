import 'dart:io';

import 'package:core/errors.dart';
import 'package:core/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class SupabaseAuthRemoteDatasource implements AuthRemoteDatasource {
  SupabaseAuthRemoteDatasource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return _supabaseClient.auth.onAuthStateChange.map((AuthState state) {
      final user = state.session?.user;
      if (user == null) return null;

      return UserModel.fromSupabaseUser(user);
    });
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'username': username, 'role': Roles.user},
      );

      final User? user = response.user;

      if (user == null) {
        throw const AuthenticationException(
          message:
              'Registration was successful but user information could not be retrieved. (User is null)',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } on AuthenticationException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred during signup: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(password: password, email: email);

      final User? user = response.user;

      if (user == null) {
        throw const AuthenticationException(
          message:
              'Sign in was successful but user information could not be retrieved. (User is null)',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } on AuthenticationException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred during login: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred during logout: ${e.toString()}',
      );
    }
  }
}
