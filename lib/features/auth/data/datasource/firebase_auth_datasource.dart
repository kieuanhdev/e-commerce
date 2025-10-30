import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/features/auth/data/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:rxdart/rxdart.dart';



class FirebaseAuthDatasource {
  final firebase.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDatasource(this._auth, this._firestore);

  // Tham chiếu đến collection 'users'
  CollectionReference get _usersCollection => _firestore.collection('users');

  // ĐÃ CẬP NHẬT: Login
  Future<UserModel> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Sau khi đăng nhập Auth, lấy profile từ Firestore
    final userDoc =
        await _usersCollection.doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      throw Exception('Không tìm thấy thông tin người dùng.');
    }
    return UserModel.fromSnapshot(userDoc);
  }

  // ĐÃ CẬP NHẬT: Register
  Future<UserModel> register(
      String email, String password, String displayName, String? phoneNumber) async {
    try {
      // 1. Tạo user trong Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 2. Tạo đối tượng UserModel mới
      final newUser = UserModel(
        id: uid,
        email: email,
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: 'customer', // Mặc định là customer
        isDisabled: false,
        createdAt: DateTime.now(),
        avatarUrl: null, // Có thể cập nhật sau
        defaultAddressId: null,
      );

      // 3. Ghi đối tượng này vào Firestore
      await _usersCollection.doc(uid).set(newUser.toMap());

      // 3b. Xác thực đã ghi
      final written = await _usersCollection.doc(uid).get();
      if (!written.exists) {
        throw Exception('Không thể lưu người dùng vào Firestore.');
      }

      // Cập nhật displayName trong Auth (tùy chọn)
      await userCredential.user?.updateDisplayName(displayName);

      return newUser;
    } on firebase.FirebaseException catch (e) {
      // Ném lỗi để tầng trên mapping thông điệp rõ ràng
      throw Exception(e.message ?? 'Lỗi Firestore khi tạo người dùng');
    }
  }

  Future<void> logout() => _auth.signOut();

  // ĐÃ CẬP NHẬT: Lấy stream user đầy đủ
  Stream<UserModel?> get authStateChanges {
    // Lắng nghe stream trạng thái của FirebaseAuth
    return _auth.authStateChanges().switchMap((firebaseUser) {
      if (firebaseUser == null) {
        // Nếu user là null (đã đăng xuất), trả về stream chứa null
        return Stream.value(null);
      } else {
        // Nếu đã đăng nhập, dùng uid để lắng nghe thay đổi
        // trên document của user đó trong Firestore
        return _usersCollection
            .doc(firebaseUser.uid)
            .snapshots()
            .map((snapshot) {
          if (snapshot.exists) {
            return UserModel.fromSnapshot(snapshot);
          } else {
            // Trường hợp hiếm: có user Auth nhưng không có
            // record Firestore (có thể do lỗi lúc đăng ký)
            return null; 
          }
        });
      }
    });
  }
}
