import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/data/datasource/firebase_auth_datasource.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';
import 'package:e_commerce/core/data/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:image_picker/image_picker.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthDatasource dataSource;
  final CloudinaryService cloudinaryService;

  AuthRepositoryImpl(this.dataSource, this.cloudinaryService);

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
  Future<Either<Failure, AppUser>> googleSignIn() async {
    try {
      final userModel = await dataSource.signInWithGoogle();
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

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      final message = _mapFirebaseError(e, isRegister: false);
      return Left(Failure(message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<AppUser?> uploadAvatarImage(XFile imageFile) async {
    try {
      // Upload lên Cloudinary
      final avatarUrl = await cloudinaryService.uploadImage(
        imageFile: imageFile,
        folder: 'avatars',
        publicIdPrefix: 'avatar',
      );
      // Cập nhật avatarUrl vào Firestore
      return await updateUser(avatarUrl: avatarUrl);
    } catch (e) {
      // Repository không throw exception, trả về null để bloc xử lý
      print('[AuthRepository] Lỗi khi upload avatar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<AppUser>> getAllUsers() {
    return dataSource.getAllUsers();
  }

  @override
  Future<void> updateUserStatus(String userId, bool isDisabled) async {
    await dataSource.updateUserStatus(userId, isDisabled);
  }

  @override
  Future<AppUser> createUserByAdmin({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    String role = 'customer',
  }) async {
    try {
      final userModel = await dataSource.createUserByAdmin(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
      );
      return userModel;
    } on firebase.FirebaseAuthException catch (e) {
      final message = _mapFirebaseError(e, isRegister: true);
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
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