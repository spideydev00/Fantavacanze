import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit_cubit.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/features/auth/data/remote_data_source/auth_remote_data_source.dart';
import 'package:fantavacanze_official/features/auth/data/repository/auth_repository_impl.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/apple_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/google_sign_in.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    anonKey: AppSecrets.supabaseKey,
    url: AppSecrets.supabaseUrl,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);

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
    //app-wide cubits
    ..registerLazySingleton(() => AppUserCubit())
    //bloc
    ..registerLazySingleton(
      () => AuthBloc(
        googleSignIn: serviceLocator(),
        appleSignIn: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}
