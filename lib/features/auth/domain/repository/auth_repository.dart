import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AppUser>> login(String email, String password);

  // ĐÃ CẬP NHẬT: Thêm các trường mới cho đăng ký
  Future<Either<Failure, AppUser>> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  });

  Future<Either<Failure, void>> logout();

  // Stream này giờ sẽ trả về AppUser đầy đủ (lấy từ Firestore)
  Stream<AppUser?> get authStateChanges;
}
