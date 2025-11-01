import 'package:e_commerce/features/bag/domain/entities/cart_item.dart';

/// Repository interface cho Bag feature
abstract class IBagRepository {
  /// Lấy tất cả cart items của user hiện tại
  Future<List<CartItem>> getCartItems(String userId);

  /// Thêm sản phẩm vào giỏ hàng
  /// Nếu sản phẩm đã có trong giỏ (cùng productId, color, size), tăng quantity
  Future<CartItem> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    String? color,
    String? size,
  });

  /// Xóa một cart item
  Future<void> removeFromCart(String cartItemId);

  /// Cập nhật số lượng của cart item
  Future<void> updateQuantity(String cartItemId, int newQuantity);

  /// Xóa tất cả cart items của user
  Future<void> clearCart(String userId);
}

