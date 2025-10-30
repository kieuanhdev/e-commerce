part of 'auth_bloc.dart';


// --- EVENT ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStateChanged extends AuthEvent {
  final AppUser? user; // AppUser giờ đã là entity đầy đủ
  const AuthStateChanged(this.user);
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested(this.email, this.password);
}

// ĐÃ CẬP NHẬT: Event đăng ký thêm trường mới
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String? phoneNumber;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
    this.phoneNumber,
  });
}

class AuthLogoutRequested extends AuthEvent {}
