import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class GoogleSignInUseCase {
  final IAuthRepository _repository;

  GoogleSignInUseCase(this._repository);

  Future<Either<Failure, AppUser>> call() {
    return _repository.googleSignIn();
  }
}


