import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.phoneNumber,
    super.avatarUrl,
    required super.role,
    super.defaultAddressId,
    required super.isDisabled,
    required super.createdAt,
  });

  // Factory để tạo UserModel từ Firestore Document
  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

    return UserModel(
      id: snap.id, // Lấy ID từ document
      email: data['email'],
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      avatarUrl: data['avatarUrl'],
      role: data['role'] ?? 'customer',
      defaultAddressId: data['defaultAddressId'],
      isDisabled: data['isDisabled'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Hàm để chuyển đổi UserModel thành Map để ghi lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role,
      'defaultAddressId': defaultAddressId,
      'isDisabled': isDisabled,
      'createdAt': Timestamp.fromDate(createdAt),
      // Không lưu 'id' vì nó là Document ID
    };
  }
}