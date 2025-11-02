part of 'admin_orders_bloc.dart';

abstract class AdminOrdersState extends Equatable {
  const AdminOrdersState();

  @override
  List<Object?> get props => [];
}

class AdminOrdersInitial extends AdminOrdersState {}

class AdminOrdersLoading extends AdminOrdersState {
  final List<Order> currentOrders;

  const AdminOrdersLoading(this.currentOrders);

  @override
  List<Object?> get props => [currentOrders];
}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<Order> orders;

  const AdminOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class AdminOrdersError extends AdminOrdersState {
  final String message;

  const AdminOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

