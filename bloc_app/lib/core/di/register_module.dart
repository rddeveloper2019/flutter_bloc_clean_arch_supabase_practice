import 'package:data_supabase/auth.dart';
import 'package:domain/auth.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class RegisterModule {
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  // Data layer registrations
  //auth
  @LazySingleton(as: AuthRemoteDatasource)
  SupabaseAuthRemoteDatasource get authRemoteDatasource;

  @LazySingleton(as: AuthRepository)
  AuthRepositoryImpl get authRepository;

  // Domain layer registrations (UseCases)
  @injectable
  SignupUseCase get signupUseCase;

  @injectable
  LoginUseCase get loginUseCase;

  @injectable
  LogoutUseCase get logoutUseCase;
}
