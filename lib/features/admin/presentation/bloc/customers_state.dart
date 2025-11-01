part of 'customers_bloc.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object?> get props => [];
}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {
  final List<AppUser> currentUsers;

  const CustomersLoading(this.currentUsers);

  @override
  List<Object?> get props => [currentUsers];
}

class CustomersLoaded extends CustomersState {
  final List<AppUser> users;

  const CustomersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class CustomersError extends CustomersState {
  final String message;

  const CustomersError(this.message);

  @override
  List<Object?> get props => [message];
}

