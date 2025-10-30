import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class LogoutUseCase {
  final IAuthRepository repository;
  LogoutUseCase(this.repository);
  // ĐÃ CẬP NHẬT: Thêm các trường mới
  Future<Either<Failure, void>> call() {
    return repository.logout(
    );
  }
}

