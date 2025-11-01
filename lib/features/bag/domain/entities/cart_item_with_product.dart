import 'package:e_commerce/features/bag/domain/entities/cart_item.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';

/// Entity kết hợp CartItem với Product info để hiển thị trong UI
class CartItemWithProduct {
  final CartItem cartItem;
  final Product product;

  CartItemWithProduct({
    required this.cartItem,
    required this.product,
  });

  double get totalPrice => product.price * cartItem.quantity;
}

