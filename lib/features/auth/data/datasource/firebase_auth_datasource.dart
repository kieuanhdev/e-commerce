import 'package:e_commerce/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth;
  FirebaseAuthDatasource(this._firebaseAuth);

  Future<UserEntity?> signIn(String email, String password) async {
    return _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((userCredential) => _userFromFirebase(userCredential.user));
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  UserEntity? _userFromFirebase(User? user) {
    if (user == null) return null;
    return UserEntity(id: user.uid, email: user.email);
  }
}
