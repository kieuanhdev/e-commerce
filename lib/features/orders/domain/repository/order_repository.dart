import 'package:e_commerce/features/orders/domain/entities/order.dart';

abstract class IOrderRepository {
  Future<String> createOrder(Order order);
  Future<List<Order>> getOrdersByUserId(String userId);
  Future<Order?> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, String status);
  Stream<List<Order>> getAllOrders();
}

