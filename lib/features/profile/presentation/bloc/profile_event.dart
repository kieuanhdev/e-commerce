import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String? displayName;
  final String? avatarUrl;
  final String? phoneNumber;
  const UpdateProfile({this.displayName, this.avatarUrl, this.phoneNumber});
  @override
  List<Object?> get props => [displayName, avatarUrl, phoneNumber];
}
