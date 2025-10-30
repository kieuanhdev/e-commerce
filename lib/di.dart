import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/features/auth/data/datasource/firebase_auth_datasource.dart';
import 'package:e_commerce/features/auth/data/repository/auth_repository_impl.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';
import 'package:e_commerce/features/auth/domain/usecase/get_auth_state_changes.dart';
import 'package:e_commerce/features/auth/domain/usecase/login.dart';
import 'package:e_commerce/features/auth/domain/usecase/logout.dart';
import 'package:e_commerce/features/auth/domain/usecase/register.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initDI() {
  // --- Auth Feature ---

  // BLoC
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getAuthStateChangesUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetAuthStateChangesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(sl()));

  // DataSource (ĐÃ CẬP NHẬT: Inject cả Auth và Firestore)
  sl.registerLazySingleton(() => FirebaseAuthDatasource(sl(), sl()));

  // --- External ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance); // Thêm Firestore
}