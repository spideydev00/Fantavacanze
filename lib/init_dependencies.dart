import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/features/auth/data/remote_data_source/auth_remote_data_source.dart';
import 'package:fantavacanze_official/features/auth/data/repository/auth_repository_impl.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/apple_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/email_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/email_sign_up.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/get_current_user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/google_sign_in.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    anonKey: AppSecrets.supabaseKey,
    url: AppSecrets.supabaseUrl,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  _initAuth();
}

void _initAuth() {
  serviceLocator
    //datasource
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    //repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(authRemoteDataSource: serviceLocator()),
    )
    //usecases
    ..registerFactory(
      () => GoogleSignIn(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => AppleSignIn(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => EmailSignIn(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => EmailSignUp(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetCurrentUser(authRepository: serviceLocator()),
    )
    //app-wide cubits:
    //1. user cubit
    ..registerLazySingleton(
        () => AppUserCubit(getCurrentUser: serviceLocator()))
    //2. navigation cubit
    ..registerLazySingleton(() => AppNavigationCubit())
    //3. theme cubit
    ..registerLazySingleton<AppThemeCubit>(
      () => AppThemeCubit(prefs: serviceLocator<SharedPreferences>()),
    )
    //bloc
    ..registerLazySingleton(
      () => AuthBloc(
        googleSignIn: serviceLocator(),
        appleSignIn: serviceLocator(),
        appUserCubit: serviceLocator(),
        emailSignIn: serviceLocator(),
        emailSignUp: serviceLocator(),
      ),
    );
}
