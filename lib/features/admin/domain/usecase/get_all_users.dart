import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class GetAllUsersUseCase {
  final IAuthRepository _repository;

  GetAllUsersUseCase(this._repository);

  Stream<List<AppUser>> call() {
    return _repository.getAllUsers();
  }
}

