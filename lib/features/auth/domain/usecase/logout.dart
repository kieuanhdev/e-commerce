import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class LogoutUseCase {
  final IAuthRepository repository;
  LogoutUseCase(this.repository);
  // ĐÃ CẬP NHẬT: Thêm các trường mới
  Future<void> call() {
    return repository.logout(
    );
  }
}

