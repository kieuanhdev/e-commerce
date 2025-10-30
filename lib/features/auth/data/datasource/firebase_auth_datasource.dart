import 'dart:async';

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

  // ĐÃ CẬP NHẬT: Lấy stream user đầy đủ (KHÔNG dùng yield*/RxDart, chỉ controller.listen)
  Stream<UserModel?> get authStateChanges {
    final controller = StreamController<UserModel?>();

    StreamSubscription? userDocSub;
    StreamSubscription? authSub;

    authSub = _auth.authStateChanges().listen((firebaseUser) {
      userDocSub?.cancel();
      if (firebaseUser == null) {
        controller.add(null);
      } else {
        userDocSub = _usersCollection.doc(firebaseUser.uid).snapshots().listen((snap) {
          try {
            if (snap.exists && snap.data() != null) {
              controller.add(UserModel.fromSnapshot(snap));
            } else {
              controller.add(null);
            }
          } catch (e, stack) {
            print('[User Stream Error]: $e $stack');
            controller.add(null);
          }
        });
      }
    });

    controller.onCancel = () {
      authSub?.cancel();
      userDocSub?.cancel();
    };

    return controller.stream;
  }

  // Lấy user hiện tại (dùng cho profile)
  Future<UserModel?> getCurrentUser() async {
    final current = _auth.currentUser;
    if (current == null) return null;
    final doc = await _usersCollection.doc(current.uid).get();
    if (doc.exists) {
      return UserModel.fromSnapshot(doc);
    } else {
      return null;
    }
  }

  // Update user profile (cho Settings)
  Future<void> updateUser({String? displayName, String? avatarUrl, String? phoneNumber, String? defaultAddressId}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged-in user!');
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (defaultAddressId != null) data['defaultAddressId'] = defaultAddressId;

    if (data.isEmpty) throw Exception('No update data provided');

    await _usersCollection.doc(user.uid).update(data);
    // Nếu user đổi displayName thì update lên FirebaseAuth profile luôn.
    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
  }
}
