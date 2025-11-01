import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:image_picker/image_picker.dart';

/// Repository interface cho Settings feature
/// Sử dụng chung entity AppUser từ auth feature
abstract class ISettingsRepository {
  /// Lấy thông tin user hiện tại
  Future<AppUser?> getCurrentUser();

  /// Cập nhật thông tin user
  Future<AppUser?> updateUser({
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? defaultAddressId,
  });

  /// Đổi mật khẩu
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Upload ảnh avatar lên Cloudinary và cập nhật vào user profile
  /// Trả về AppUser đã được cập nhật
  Future<AppUser?> uploadAvatarImage(XFile imageFile);
}

