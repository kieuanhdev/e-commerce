import 'package:equatable/equatable.dart';


class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role; // 'customer' hoặc 'admin'
  final String? defaultAddressId;
  final bool isDisabled;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.defaultAddressId,
    required this.isDisabled,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        phoneNumber,
        avatarUrl,
        role,
        defaultAddressId,
        isDisabled,
        createdAt,
      ];
}