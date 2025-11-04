import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _repository;
  LoginUseCase(this._repository);

  Future<AppUser> call(String email, String password) {
    return _repository.login(email, password);
  }
}
