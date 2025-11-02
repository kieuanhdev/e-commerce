import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/products/domain/repositories/product_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

/// Use case để tạo order và giảm số lượng sản phẩm trong một transaction
class CreateOrderWithReduceStockUseCase {
  final ProductRepository _productRepository;

  CreateOrderWithReduceStockUseCase(
    this._productRepository,
  );

  Future<String> call(Order order) async {
    // Lấy các product IDs từ order items
    final productIds = order.items.map((item) => item.productId).toList();

    // Thực hiện tất cả trong một Firestore batch write để đảm bảo atomicity
    final batch = FirebaseFirestore.instance.batch();

    // 1. Lấy thông tin sản phẩm và giảm quantity
    final products = await Future.wait(
      productIds.map((id) => _productRepository.getProduct(id)),
    );

    // Kiểm tra số lượng tồn kho
    for (var i = 0; i < order.items.length; i++) {
      final orderItem = order.items[i];
      final product = products[i];
      
      if (product.quantity < orderItem.quantity) {
        throw Exception(
          'Sản phẩm "${product.name}" không đủ số lượng. Còn lại: ${product.quantity}',
        );
      }

      // Giảm quantity của sản phẩm
      product.quantity -= orderItem.quantity;
      product.updatedAt = DateTime.now();
      
      // Thêm vào batch update
      batch.update(
        FirebaseFirestore.instance.collection('products').doc(product.id),
        {
          'quantity': product.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    // 2. Tạo order document để add vào batch
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    final orderModel = {
      'id': orderRef.id,
      'userId': order.userId,
      'customerName': order.customerName,
      'customerEmail': order.customerEmail,
      'items': order.items.map((item) => {
            'productId': item.productId,
            'productName': item.productName,
            'productImageUrl': item.productImageUrl,
            'quantity': item.quantity,
            'price': item.price,
            'color': item.color,
            'size': item.size,
          }).toList(),
      'totalAmount': order.totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'status': order.status.displayName,
    };
    batch.set(orderRef, orderModel);

    // 3. Commit batch - tất cả sẽ thành công hoặc tất cả sẽ fail
    await batch.commit();

    return orderRef.id;
  }
}

