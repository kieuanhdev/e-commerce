import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/features/bag/domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.quantity,
    super.color,
    super.size,
    required super.addedAt,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      productId: data['productId'] as String,
      userId: data['userId'] as String,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      color: data['color'] as String?,
      size: data['size'] as String?,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'userId': userId,
      'quantity': quantity,
      'color': color,
      'size': size,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory CartItemModel.fromEntity(CartItem entity) => CartItemModel(
    id: entity.id,
    productId: entity.productId,
    userId: entity.userId,
    quantity: entity.quantity,
    color: entity.color,
    size: entity.size,
    addedAt: entity.addedAt,
  );
}

