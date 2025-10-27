import 'package:e_commerce/features/auth/domain/entities/user_entity.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class SignIn {
  final AuthRepository _repository;
  SignIn(this._repository);

  Future<UserEntity?> call(String email, String password) {
    return _repository.signIn(email, password);
  }
}
