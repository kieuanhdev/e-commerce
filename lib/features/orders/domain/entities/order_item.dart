/// Entity cho một sản phẩm trong đơn hàng
class OrderItem {
  final String productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double price; // Giá tại thời điểm mua
  final String? color;
  final String? size;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.price,
    this.color,
    this.size,
  });

  double get totalPrice => price * quantity;
}

