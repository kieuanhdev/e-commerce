import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final IAuthRepository repo;
  GetCurrentUserUseCase(this.repo);
  Future<AppUser?> call() => repo.getCurrentUser();
}
