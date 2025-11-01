import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/settings/domain/repository/settings_repository.dart';

class GetCurrentUserUseCase {
  final ISettingsRepository repo;
  GetCurrentUserUseCase(this.repo);
  Future<AppUser?> call() => repo.getCurrentUser();
}
