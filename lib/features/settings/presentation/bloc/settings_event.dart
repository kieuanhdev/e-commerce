import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateUserSettings extends SettingsEvent {
  final String? displayName;
  final XFile? avatarImageFile; // Ảnh mới đã chọn (nếu có)
  final String? phoneNumber;
  final String? defaultAddressId;

  const UpdateUserSettings({
    this.displayName,
    this.avatarImageFile,
    this.phoneNumber,
    this.defaultAddressId,
  });

  @override
  List<Object?> get props => [displayName, avatarImageFile, phoneNumber, defaultAddressId];
}

class ChangePasswordRequested extends SettingsEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ImageSelected extends SettingsEvent {
  final XFile imageFile;

  const ImageSelected({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}