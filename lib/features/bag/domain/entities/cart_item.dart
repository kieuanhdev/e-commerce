/// Entity cho một item trong giỏ hàng
class CartItem {
  final String id; // ID của cart item trong Firestore
  final String productId; // ID của sản phẩm
  final String userId; // ID của user sở hữu cart item này
  final int quantity; // Số lượng
  final String? color; // Màu sắc (optional)
  final String? size; // Kích thước (optional)
  final DateTime addedAt; // Thời gian thêm vào giỏ

  CartItem({
    required this.id,
    required this.productId,
    required this.userId,
    required this.quantity,
    this.color,
    this.size,
    required this.addedAt,
  });
}

