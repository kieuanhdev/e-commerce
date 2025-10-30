import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/data/datasource/firebase_auth_datasource.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthDatasource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AppUser>> login(String email, String password) async {
    try {
      // DataSource giờ đã trả về UserModel đầy đủ từ Firestore
      final userModel = await dataSource.login(email, password);
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      final message = _mapFirebaseError(e, isRegister: false);
      return Left(Failure(message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      // DataSource giờ đã trả về UserModel đầy đủ
      final userModel = await dataSource.register(
          email, password, displayName, phoneNumber);
      return Right(userModel);
    } on firebase.FirebaseAuthException catch (e) {
      final message = _mapFirebaseError(e, isRegister: true);
      return Left(Failure(message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSource.logout();
      return const Right(null);
    } catch (_) {
      return Left(Failure('Đăng xuất thất bại'));
    }
  }

  @override
  Stream<AppUser?> get authStateChanges => dataSource.authStateChanges;

  @override
  Future<AppUser?> getCurrentUser() async {
    return dataSource.getCurrentUser(); // Triển khai ở datasource, dùng FirebaseAuth
  }

  @override
  Future<AppUser?> updateUser({String? displayName, String? avatarUrl, String? phoneNumber, String? defaultAddressId}) async {
    await dataSource.updateUser(
      displayName: displayName,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
      defaultAddressId: defaultAddressId,
    );
    return getCurrentUser();
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await dataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      final message = _mapFirebaseError(e, isRegister: false);
      return Left(Failure(message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  String _mapFirebaseError(firebase.FirebaseAuthException e, {required bool isRegister}) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng. Hãy dùng email khác.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng dùng mật khẩu ≥ 6 ký tự.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản. Vui lòng kiểm tra lại.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật. Hãy bật Email/Password trong Firebase Console.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi mạng. Kiểm tra kết nối internet và thử lại.';
      default:
        return e.message ?? (isRegister ? 'Đăng ký thất bại' : 'Đăng nhập thất bại');
    }
  }
}