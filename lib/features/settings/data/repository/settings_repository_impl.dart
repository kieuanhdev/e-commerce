import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/settings/data/datasource/settings_datasource.dart';
import 'package:e_commerce/features/settings/domain/repository/settings_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:image_picker/image_picker.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final SettingsDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final userModel = await _datasource.getCurrentUser();
      return userModel;
    } catch (e) {
      print('[SettingsRepository] Lỗi khi lấy current user: $e');
      return null;
    }
  }

  @override
  Future<AppUser?> updateUser({
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? defaultAddressId,
  }) async {
    try {
      final updatedUser = await _datasource.updateUser(
        displayName: displayName,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
        defaultAddressId: defaultAddressId,
      );
      return updatedUser;
    } catch (e) {
      print('[SettingsRepository] Lỗi khi update user: $e');
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _datasource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on firebase.FirebaseAuthException catch (e) {
      final message = _mapFirebaseError(e);
      return Left(Failure(message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<AppUser?> uploadAvatarImage(XFile imageFile) async {
    try {
      // Upload ảnh lên Cloudinary
      final avatarUrl = await _datasource.uploadAvatarImage(imageFile);
      
      // Cập nhật avatarUrl vào user profile
      return await updateUser(avatarUrl: avatarUrl);
    } catch (e) {
      print('[SettingsRepository] Lỗi khi upload avatar: $e');
      rethrow;
    }
  }

  String _mapFirebaseError(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Mật khẩu hiện tại không đúng.';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu. Vui lòng dùng mật khẩu ≥ 6 ký tự.';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để đổi mật khẩu.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi mạng. Kiểm tra kết nối internet và thử lại.';
      default:
        return e.message ?? 'Đổi mật khẩu thất bại';
    }
  }
}

