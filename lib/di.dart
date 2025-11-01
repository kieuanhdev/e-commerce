import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/features/auth/data/datasource/firebase_auth_datasource.dart';
import 'package:e_commerce/features/auth/data/repository/auth_repository_impl.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';
import 'package:e_commerce/features/auth/domain/usecase/get_auth_state_changes.dart';
import 'package:e_commerce/features/auth/domain/usecase/login.dart';
import 'package:e_commerce/features/auth/domain/usecase/logout.dart';
import 'package:e_commerce/features/auth/domain/usecase/register.dart';
import 'package:e_commerce/features/auth/domain/usecase/forgot_password.dart';
import 'package:e_commerce/features/auth/domain/usecase/google_sign_in.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:e_commerce/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:e_commerce/features/settings/domain/usecase/get_current_user.dart';
import 'package:e_commerce/features/settings/domain/usecase/update_user_settings.dart';
import 'package:e_commerce/features/settings/domain/usecase/change_password.dart';
import 'package:e_commerce/features/settings/domain/usecase/upload_avatar_image.dart';
import 'package:e_commerce/core/data/cloudinary_service.dart';
import 'package:e_commerce/features/bag/data/datasource/bag_datasource.dart';
import 'package:e_commerce/features/bag/data/repository/bag_repository_impl.dart';
import 'package:e_commerce/features/bag/domain/repository/bag_repository.dart';
import 'package:e_commerce/features/bag/domain/usecase/get_cart_items_with_products.dart';
import 'package:e_commerce/features/bag/domain/usecase/add_to_cart.dart';
import 'package:e_commerce/features/bag/domain/usecase/remove_from_cart.dart';
import 'package:e_commerce/features/bag/domain/usecase/update_cart_item_quantity.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_bloc.dart';
import 'package:e_commerce/features/products/data/datasources/product_remote_datasource.dart';
import 'package:e_commerce/features/products/data/repositories/product_repository_impl.dart';
import 'package:e_commerce/features/products/domain/repositories/product_repository.dart';

final sl = GetIt.instance;

void initDI() {
  // --- Auth Feature ---

  // BLoC
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getAuthStateChangesUseCase: sl(),
        forgotPasswordUseCase: sl(),
        googleSignInUseCase: sl(),
      ));

  // --- External (đăng ký trước để dùng cho các dependencies khác) ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // --- Cloudinary Service (dùng chung cho toàn app, đăng ký trước) ---
  sl.registerLazySingleton(() => CloudinaryService());

  // --- DataSource (đăng ký trước Repository) ---
  sl.registerLazySingleton(() => FirebaseAuthDatasource(sl(), sl()));

  // --- Repository (inject CloudinaryService cho upload avatar) ---
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(sl(), sl()));

  // --- UseCases (dùng Repository, nên đăng ký sau) ---
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetAuthStateChangesUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));


  // (Gộp vào AuthBloc) Bỏ đăng ký ForgotPasswordBloc
  
  // --- Settings UseCases (dùng chung IAuthRepository) ---
  sl.registerFactory(() => GetCurrentUserUseCase(sl()));
  sl.registerFactory(() => UpdateUserSettingsUseCase(sl()));
  sl.registerFactory(() => ChangePasswordUseCase(sl()));
  sl.registerFactory(() => UploadAvatarImageUseCase(sl()));
  
  // --- Settings Bloc ---
  sl.registerFactory(() => SettingsBloc(
    getCurrentUser: sl(),
    updateUserSettings: sl(),
    changePasswordUseCase: sl(),
    uploadAvatarImageUseCase: sl(),
  ));

  // --- Bag Feature ---
  
  // Product Repository (dùng chung với products feature)
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(ProductRemoteDataSourceImpl()));
  
  // Bag Datasource (sử dụng FirebaseRemoteDS internally, không cần inject FirebaseFirestore)
  sl.registerLazySingleton<BagRemoteDataSource>(() => BagRemoteDataSourceImpl());
  
  // Bag Repository
  sl.registerLazySingleton<IBagRepository>(() => BagRepositoryImpl(sl()));
  
  // Bag UseCases
  sl.registerFactory(() => GetCartItemsWithProductsUseCase(sl(), sl()));
  sl.registerFactory(() => AddToCartUseCase(sl()));
  sl.registerFactory(() => RemoveFromCartUseCase(sl()));
  sl.registerFactory(() => UpdateCartItemQuantityUseCase(sl()));
  
  // Bag Bloc
  sl.registerFactory(() => BagBloc(
    getCartItemsUseCase: sl(),
    addToCartUseCase: sl(),
    removeFromCartUseCase: sl(),
    updateQuantityUseCase: sl(),
  ));
}