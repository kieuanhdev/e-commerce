import 'package:e_commerce/features/bag/domain/entities/cart_item_with_product.dart';
import 'package:e_commerce/features/bag/domain/repository/bag_repository.dart';
import 'package:e_commerce/features/products/domain/repositories/product_repository.dart';

class GetCartItemsWithProductsUseCase {
  final IBagRepository _bagRepository;
  final ProductRepository _productRepository;

  GetCartItemsWithProductsUseCase(this._bagRepository, this._productRepository);

  Future<List<CartItemWithProduct>> call(String userId) async {
    // Lấy cart items
    final cartItems = await _bagRepository.getCartItems(userId);
    
    // Lấy product info cho mỗi cart item
    final List<CartItemWithProduct> result = [];
    for (final cartItem in cartItems) {
      try {
        final product = await _productRepository.getProduct(cartItem.productId);
        result.add(CartItemWithProduct(
          cartItem: cartItem,
          product: product,
        ));
      } catch (e) {
        // Nếu product không tồn tại, bỏ qua cart item này
        print('[GetCartItemsWithProducts] Product ${cartItem.productId} not found: $e');
      }
    }
    
    return result;
  }
}

