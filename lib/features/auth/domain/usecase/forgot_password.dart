import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class ForgotPasswordUseCase {
  final IAuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.forgotPassword(email);
  }
}


