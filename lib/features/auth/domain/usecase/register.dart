import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;
  RegisterUseCase(this.repository);
  // ĐÃ CẬP NHẬT: Thêm các trường mới
  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) {
    return repository.register(
      email: email,
      password: password,
      displayName: displayName,
      phoneNumber: phoneNumber,
    );
  }
}
