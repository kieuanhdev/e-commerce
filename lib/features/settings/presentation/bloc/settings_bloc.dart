import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:e_commerce/features/settings/domain/usecase/get_current_user.dart';
import 'package:e_commerce/features/settings/domain/usecase/update_user_settings.dart';
import 'package:e_commerce/features/settings/domain/usecase/change_password.dart';
import 'package:e_commerce/core/data/cloudinary_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetCurrentUserUseCase getCurrentUser;
  final UpdateUserSettingsUseCase updateUserSettings;
  final ChangePasswordUseCase changePasswordUseCase;
  final CloudinaryService cloudinaryService;
  
  SettingsBloc({
    required this.getCurrentUser,
    required this.updateUserSettings,
    required this.changePasswordUseCase,
    required this.cloudinaryService,
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

    on<UpdateUserSettings>((event, emit) async {
      emit(SettingsLoading());
      try {
        final updated = await updateUserSettings(
          displayName: event.displayName,
          avatarUrl: event.avatarUrl,
          phoneNumber: event.phoneNumber,
          defaultAddressId: event.defaultAddressId,
        );
        if (updated == null) {
          emit(const SettingsError('Cập nhật thất bại!'));
        } else {
          emit(SettingsUpdated('Cập nhật thành công!'));
          emit(SettingsLoaded(updated));
        }
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });

    on<ChangePasswordRequested>((event, emit) async {
      try {
        final result = await changePasswordUseCase(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        );
        result.fold(
          (l) => emit(SettingsError(l.message)),
          (r) => emit(const SettingsUpdated('Đổi mật khẩu thành công!')),
        );
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });

    on<UploadAvatarImage>((event, emit) async {
      // Lấy user hiện tại để hiển thị trong UploadingAvatar state
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        emit(UploadingAvatar(currentUser));
      } else {
        emit(SettingsLoading());
      }
      
      try {
        print('[SettingsBloc] Bắt đầu upload avatar lên Cloudinary...');
        
        // Upload ảnh lên Cloudinary
        final avatarUrl = await cloudinaryService.uploadAvatarImage(event.imageFile);
        print('[SettingsBloc] Upload Cloudinary thành công, URL: $avatarUrl');
        
        // Cập nhật avatarUrl trong user profile trên Firebase
        print('[SettingsBloc] Đang cập nhật profile trên Firebase...');
        final updated = await updateUserSettings(
          avatarUrl: avatarUrl,
        );
        
        if (updated == null) {
          print('[SettingsBloc] Cập nhật profile thất bại');
          emit(SettingsError('Cập nhật avatar thất bại!'));
          // Reload để có user data
          final user = await getCurrentUser();
          if (user != null) {
            emit(SettingsLoaded(user));
          }
        } else {
          print('[SettingsBloc] Cập nhật profile thành công');
          emit(const SettingsUpdated('Cập nhật avatar thành công!'));
          emit(SettingsLoaded(updated));
        }
      } catch (e, stackTrace) {
        print('[SettingsBloc] Lỗi khi upload avatar: $e');
        print('[SettingsBloc] Stack trace: $stackTrace');
        
        // Reload user để quay về trạng thái ban đầu
        final user = await getCurrentUser();
        if (user != null) {
          emit(SettingsError(e.toString()));
          emit(SettingsLoaded(user)); // Quay về trạng thái loaded sau khi có lỗi
        } else {
          emit(SettingsError(e.toString()));
        }
      }
    });
    
    // Load settings sau khi đã đăng ký tất cả handlers
    add(LoadSettings());
  }
}
