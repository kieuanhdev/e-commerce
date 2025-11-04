import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:e_commerce/features/settings/domain/usecase/get_current_user.dart';
import 'package:e_commerce/features/settings/domain/usecase/update_user_settings.dart';
import 'package:e_commerce/features/settings/domain/usecase/change_password.dart';
import 'package:e_commerce/features/settings/domain/usecase/upload_avatar_image.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetCurrentUserUseCase getCurrentUser;
  final UpdateUserSettingsUseCase updateUserSettings;
  final ChangePasswordUseCase changePasswordUseCase;
  final UploadAvatarImageUseCase uploadAvatarImageUseCase;
  
  SettingsBloc({
    required this.getCurrentUser,
    required this.updateUserSettings,
    required this.changePasswordUseCase,
    required this.uploadAvatarImageUseCase,
  }) : super(SettingsInitial()) {
    on<LoadSettings>((event, emit) async {
      emit(SettingsLoading());
      try {
        final user = await getCurrentUser();
        if (user == null) {
          emit(const SettingsError('Không tìm thấy tài khoản!'));
        } else {
          emit(SettingsLoaded(user));
        }
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });

    // Khi chọn ảnh, chỉ lưu path để preview, chưa upload
    on<ImageSelected>((event, emit) async {
      final currentState = state;
      if (currentState is SettingsLoaded) {
        // Giữ nguyên user, chỉ thêm selectedImagePath để preview
        emit(SettingsLoaded(currentState.user, selectedImagePath: event.imageFile.path));
      }
    });

    on<UpdateUserSettings>((event, emit) async {
      emit(SettingsLoading());
      try {
        String? avatarUrl;
        
        // Nếu có ảnh mới được chọn, upload lên Cloudinary trước
        if (event.avatarImageFile != null) {
          try {
            final updated = await uploadAvatarImageUseCase(event.avatarImageFile!);
            if (updated != null) {
              avatarUrl = updated.avatarUrl;
            } else {
              emit(const SettingsError('Upload avatar thất bại!'));
              final user = await getCurrentUser();
              if (user != null) {
                emit(SettingsLoaded(user));
              }
              return;
            }
          } catch (e) {
            emit(SettingsError('Lỗi khi upload avatar: $e'));
            final user = await getCurrentUser();
            if (user != null) {
              emit(SettingsLoaded(user));
            }
            return;
          }
        }
        
        // Cập nhật thông tin user (bao gồm avatarUrl nếu có)
        final updated = await updateUserSettings(
          displayName: event.displayName,
          avatarUrl: avatarUrl,
          phoneNumber: event.phoneNumber,
          defaultAddressId: event.defaultAddressId,
        );
        if (updated == null) {
          emit(const SettingsError('Cập nhật thất bại!'));
        } else {
          emit(SettingsUpdated('Cập nhật thành công!'));
          emit(SettingsLoaded(updated)); // Xóa selectedImagePath sau khi lưu thành công
        }
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });

    on<ChangePasswordRequested>((event, emit) async {
      try {
        await changePasswordUseCase(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        );
        emit(const SettingsUpdated('Đổi mật khẩu thành công!'));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });

    
    // Load settings sau khi đã đăng ký tất cả handlers
    add(LoadSettings());
  }
}
