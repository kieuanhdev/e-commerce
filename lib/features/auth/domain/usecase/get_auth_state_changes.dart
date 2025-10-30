
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class GetAuthStateChangesUseCase {
  final IAuthRepository _repository;
  GetAuthStateChangesUseCase(this._repository);

 Stream<AppUser?> call() => _repository.authStateChanges;
}
