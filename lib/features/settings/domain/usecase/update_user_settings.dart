import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/settings/domain/repository/settings_repository.dart';

class UpdateUserSettingsUseCase {
  final ISettingsRepository repo;
  UpdateUserSettingsUseCase(this.repo);
  Future<AppUser?> call({
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? defaultAddressId,
  }) {
    return repo.updateUser(
      displayName: displayName,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
      defaultAddressId: defaultAddressId,
    );
  }
}
