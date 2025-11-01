import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';
import 'package:image_picker/image_picker.dart';

class UploadAvatarImageUseCase {
  final IAuthRepository repo;
  UploadAvatarImageUseCase(this.repo);

  Future<AppUser?> call(XFile imageFile) {
    return repo.uploadAvatarImage(imageFile);
  }
}

