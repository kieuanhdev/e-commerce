import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class CreateUserByAdminUseCase {
  final IAuthRepository _repository;

  CreateUserByAdminUseCase(this._repository);

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    String role = 'customer',
  }) {
    return _repository.createUserByAdmin(
      email: email,
      password: password,
      displayName: displayName,
      phoneNumber: phoneNumber,
      role: role,
    );
  }
}

