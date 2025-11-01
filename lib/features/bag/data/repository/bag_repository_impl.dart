import 'package:e_commerce/features/bag/data/datasource/bag_datasource.dart';
import 'package:e_commerce/features/bag/domain/entities/cart_item.dart';
import 'package:e_commerce/features/bag/domain/repository/bag_repository.dart';

class BagRepositoryImpl implements IBagRepository {
  final BagRemoteDataSource _datasource;

  BagRepositoryImpl(this._datasource);

  @override
  Future<List<CartItem>> getCartItems(String userId) async {
    return await _datasource.getCartItems(userId);
  }

  @override
  Future<CartItem> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    String? color,
    String? size,
  }) async {
    return await _datasource.addToCart(
      userId: userId,
      productId: productId,
      quantity: quantity,
      color: color,
      size: size,
    );
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    await _datasource.removeFromCart(cartItemId);
  }

  @override
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    await _datasource.updateQuantity(cartItemId, newQuantity);
  }

  @override
  Future<void> clearCart(String userId) async {
    await _datasource.clearCart(userId);
  }
}

