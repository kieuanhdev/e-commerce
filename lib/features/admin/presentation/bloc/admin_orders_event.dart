part of 'admin_orders_bloc.dart';

abstract class AdminOrdersEvent extends Equatable {
  const AdminOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllOrders extends AdminOrdersEvent {
  const LoadAllOrders();
}

class OrdersUpdated extends AdminOrdersEvent {
  final List<Order> orders;

  const OrdersUpdated(this.orders);

  @override
  List<Object?> get props => [orders];
}

class UpdateOrderStatus extends AdminOrdersEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdateOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object?> get props => [orderId, newStatus];
}

