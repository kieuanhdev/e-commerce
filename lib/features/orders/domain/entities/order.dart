import 'order_item.dart';

/// Entity cho một đơn hàng
class Order {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final OrderStatus status;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.status = OrderStatus.processing,
  });

  String get trackingNumber => 'ORD${id.substring(0, id.length.clamp(0, 8)).toUpperCase()}';
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}

enum OrderStatus {
  processing,
  delivery,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.processing:
        return 'PROCESSING';
      case OrderStatus.delivery:
        return 'DELIVERY';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static OrderStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'delivery':
        return OrderStatus.delivery;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.processing;
    }
  }
}

