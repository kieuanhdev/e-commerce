import 'package:equatable/equatable.dart';

abstract class BagEvent extends Equatable {
  const BagEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartItems extends BagEvent {
  final String userId;
  const LoadCartItems(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddToCart extends BagEvent {
  final String userId;
  final String productId;
  final int quantity;
  final String? color;
  final String? size;

  const AddToCart({
    required this.userId,
    required this.productId,
    required this.quantity,
    this.color,
    this.size,
  });

  @override
  List<Object?> get props => [userId, productId, quantity, color, size];
}

class RemoveFromCart extends BagEvent {
  final String cartItemId;
  const RemoveFromCart(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class UpdateQuantity extends BagEvent {
  final String cartItemId;
  final int newQuantity;
  const UpdateQuantity(this.cartItemId, this.newQuantity);

  @override
  List<Object?> get props => [cartItemId, newQuantity];
}

