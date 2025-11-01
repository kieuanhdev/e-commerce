import 'package:e_commerce/features/bag/domain/entities/cart_item.dart';
import 'package:e_commerce/features/bag/domain/repository/bag_repository.dart';

class AddToCartUseCase {
  final IBagRepository _repository;

  AddToCartUseCase(this._repository);

  Future<CartItem> call({
    required String userId,
    required String productId,
    required int quantity,
    String? color,
    String? size,
  }) {
    return _repository.addToCart(
      userId: userId,
      productId: productId,
      quantity: quantity,
      color: color,
      size: size,
    );
  }
}

