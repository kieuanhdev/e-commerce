import 'package:equatable/equatable.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}
class SettingsLoaded extends SettingsState {
  final AppUser user;
  const SettingsLoaded(this.user);
  @override
  List<Object?> get props => [user];
}
class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}
class SettingsUpdated extends SettingsState {
  final String message;
  const SettingsUpdated(this.message);
  @override
  List<Object?> get props => [message];
}

class UploadingAvatar extends SettingsState {
  final AppUser user;
  const UploadingAvatar(this.user);
  @override
  List<Object?> get props => [user];
}