import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/core/data/cloudinary_service.dart';
import 'package:e_commerce/features/auth/data/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:image_picker/image_picker.dart';

/// Datasource cho Settings feature
/// Kết hợp Firebase Auth/Firestore và Cloudinary Service
class SettingsDatasource {
  final firebase.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  SettingsDatasource(
    this._auth,
    this._firestore,
    this._cloudinaryService,
  );

  // Tham chiếu đến collection 'users'
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Lấy user hiện tại từ Firestore
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

  /// Cập nhật thông tin user trong Firestore
  Future<UserModel?> updateUser({
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? defaultAddressId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged-in user!');
    
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (defaultAddressId != null) data['defaultAddressId'] = defaultAddressId;

    if (data.isEmpty) throw Exception('No update data provided');

    await _usersCollection.doc(user.uid).update(data);
    
    // Nếu user đổi displayName thì update lên FirebaseAuth profile luôn
    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }

    // Lấy lại user đã cập nhật
    return getCurrentUser();
  }

  /// Upload ảnh avatar lên Cloudinary
  Future<String> uploadAvatarImage(XFile imageFile) async {
    return await _cloudinaryService.uploadAvatarImage(imageFile);
  }

  /// Đổi mật khẩu
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged-in user!');
    final email = user.email;
    if (email == null) throw Exception('User has no email');

    final credential = firebase.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}

