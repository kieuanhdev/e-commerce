import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:e_commerce/features/settings/domain/usecase/get_current_user.dart';
import 'package:e_commerce/features/settings/domain/usecase/update_user_settings.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetCurrentUserUseCase getCurrentUser;
  final UpdateUserSettingsUseCase updateUserSettings;
  SettingsBloc({required this.getCurrentUser, required this.updateUserSettings}) : super(SettingsInitial()) {
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
  }
}
