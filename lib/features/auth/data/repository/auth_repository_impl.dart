import 'package:e_commerce/features/auth/data/datasource/firebase_auth_datasource.dart';
import 'package:e_commerce/features/auth/domain/entities/user_entity.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final FirebaseAuthDatasource _firebaseAuthDatasource;

  AuthRepositoryImpl(this._firebaseAuthDatasource);

  @override
  Future<UserEntity?> signIn(String email, String password) {
    return _firebaseAuthDatasource.signIn(email, password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuthDatasource.signOut();
  }
}
