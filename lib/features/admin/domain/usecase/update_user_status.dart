import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class UpdateUserStatusUseCase {
  final IAuthRepository _repository;

  UpdateUserStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId, bool isDisabled) {
    return _repository.updateUserStatus(userId, isDisabled);
  }
}

