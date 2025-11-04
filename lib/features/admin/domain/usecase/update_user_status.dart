import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class UpdateUserStatusUseCase {
  final IAuthRepository _repository;

  UpdateUserStatusUseCase(this._repository);

  Future<void> call(String userId, bool isDisabled) async {
    await _repository.updateUserStatus(userId, isDisabled);
  }
}

