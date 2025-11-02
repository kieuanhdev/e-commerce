import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/entities/order_item.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.userId,
    required super.customerName,
    required super.customerEmail,
    required super.items,
    required super.totalAmount,
    required super.createdAt,
    super.status,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData
        .map((item) => OrderItem(
              productId: item['productId'] as String,
              productName: item['productName'] as String,
              productImageUrl: item['productImageUrl'] as String?,
              quantity: (item['quantity'] as num).toInt(),
              price: (item['price'] as num).toDouble(),
              color: item['color'] as String?,
              size: item['size'] as String?,
            ))
        .toList();

    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String,
      customerName: data['customerName'] as String,
      customerEmail: data['customerEmail'] as String,
      items: items,
      totalAmount: (data['totalAmount'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: OrderStatus.fromString(data['status'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'items': items.map((item) => {
            'productId': item.productId,
            'productName': item.productName,
            'productImageUrl': item.productImageUrl,
            'quantity': item.quantity,
            'price': item.price,
            'color': item.color,
            'size': item.size,
          }).toList(),
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.displayName,
    };
  }

  factory OrderModel.fromEntity(Order entity) => OrderModel(
        id: entity.id,
        userId: entity.userId,
        customerName: entity.customerName,
        customerEmail: entity.customerEmail,
        items: entity.items,
        totalAmount: entity.totalAmount,
        createdAt: entity.createdAt,
        status: entity.status,
      );

  Order toEntity() => Order(
        id: id,
        userId: userId,
        customerName: customerName,
        customerEmail: customerEmail,
        items: items,
        totalAmount: totalAmount,
        createdAt: createdAt,
        status: status,
      );
}

