import 'package:data_supabase/auth.dart';
import 'package:data_supabase/post.dart';
import 'package:domain/auth.dart';
import 'package:domain/post.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/blocs/authentication/authentication_bloc.dart';
import '../config/router/app_router.dart';

@module
abstract class RegisterModule {
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @singleton
  GoRouter router(AuthenticationBloc authBloc) => createRouter(authBloc);
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

  //posts

  @LazySingleton(as: PostRemoteDatasource)
  SupabasePostRemoteDatasource get postRemoteDatasource;

  @LazySingleton(as: PostRepository)
  PostRepositoryImpl get postRepository;

  @injectable
  GetPostsUsecase get getPostsUsecase;
}
