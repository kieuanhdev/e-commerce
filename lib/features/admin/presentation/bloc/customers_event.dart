part of 'customers_bloc.dart';

abstract class CustomersEvent extends Equatable {
  const CustomersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends CustomersEvent {
  const LoadUsers();
}

class UsersUpdated extends CustomersEvent {
  final List<AppUser> users;

  const UsersUpdated(this.users);

  @override
  List<Object?> get props => [users];
}

class ToggleUserStatus extends CustomersEvent {
  final String userId;

  const ToggleUserStatus(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateUser extends CustomersEvent {
  final String email;
  final String password;
  final String displayName;
  final String? phoneNumber;
  final String role;

  const CreateUser({
    required this.email,
    required this.password,
    required this.displayName,
    this.phoneNumber,
    this.role = 'customer',
  });

  @override
  List<Object?> get props => [email, password, displayName, phoneNumber, role];
}

