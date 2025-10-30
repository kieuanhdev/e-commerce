import 'package:equatable/equatable.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final AppUser user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
