import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);
  Future<void> call() {
    return repository.signOut();
  }
}
