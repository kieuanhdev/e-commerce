import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class UpdateUserSettingsUseCase {
  final IAuthRepository repo;
  UpdateUserSettingsUseCase(this.repo);
  Future<AppUser?> call({String? displayName, String? avatarUrl, String? phoneNumber, String? defaultAddressId}) {
    return repo.updateUser(
      displayName: displayName,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
      defaultAddressId: defaultAddressId,
    );
  }
}
