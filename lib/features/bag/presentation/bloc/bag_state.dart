import 'package:equatable/equatable.dart';
import 'package:e_commerce/features/bag/domain/entities/cart_item_with_product.dart';

abstract class BagState extends Equatable {
  const BagState();

  @override
  List<Object?> get props => [];
}

class BagInitial extends BagState {}

class BagLoading extends BagState {}

class BagLoaded extends BagState {
  final List<CartItemWithProduct> cartItems;
  final String userId;
  const BagLoaded(this.cartItems, this.userId);

  @override
  List<Object?> get props => [cartItems, userId];
  
  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}

class BagError extends BagState {
  final String message;
  const BagError(this.message);

  @override
  List<Object?> get props => [message];
}

class BagItemAdded extends BagState {
  final String message;
  const BagItemAdded(this.message);

  @override
  List<Object?> get props => [message];
}

