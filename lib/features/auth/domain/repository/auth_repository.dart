import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:image_picker/image_picker.dart';

abstract class IAuthRepository {
  Future<AppUser> login(String email, String password);
  Future<AppUser> googleSignIn();

  // ĐÃ CẬP NHẬT: Thêm các trường mới cho đăng ký
  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  });

  Future<void> logout();

  // Quên mật khẩu: gửi email đặt lại mật khẩu
  Future<void> forgotPassword(String email);

  // Stream này giờ sẽ trả về AppUser đầy đủ (lấy từ Firestore)
  Stream<AppUser?> get authStateChanges;

  // Lấy user hiện tại, dùng cho ProfileBloc
  Future<AppUser?> getCurrentUser();

  // Update user info theo profile (cho Settings)
  Future<AppUser?> updateUser({String? displayName, String? avatarUrl, String? phoneNumber, String? defaultAddressId});

  // Đổi mật khẩu (yêu cầu re-auth)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Upload ảnh avatar lên Cloudinary và cập nhật vào user profile
  /// Trả về AppUser đã được cập nhật với avatarUrl mới
  Future<AppUser?> uploadAvatarImage(XFile imageFile);
  
  // Admin functions
  /// Lấy tất cả users (cho admin)
  Stream<List<AppUser>> getAllUsers();

  /// Cập nhật trạng thái khóa/mở khóa tài khoản (cho admin)
  Future<void> updateUserStatus(String userId, bool isDisabled);

  /// Tạo user mới bởi admin
  Future<AppUser> createUserByAdmin({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    String role = 'customer',
  });
}
