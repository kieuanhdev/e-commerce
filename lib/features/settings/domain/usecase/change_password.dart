import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class ChangePasswordUseCase {
  final IAuthRepository repo;
  ChangePasswordUseCase(this.repo);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}


