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
    // Thực hiện tất cả trong một Firestore batch write để đảm bảo atomicity
    final batch = FirebaseFirestore.instance.batch();

    // 1. Group order items by productId để tính tổng quantity cần giảm cho mỗi product
    final productQuantityMap = <String, int>{};
    for (var item in order.items) {
      productQuantityMap[item.productId] = (productQuantityMap[item.productId] ?? 0) + item.quantity;
    }

    // 2. Fetch products và kiểm tra số lượng tồn kho
    for (var entry in productQuantityMap.entries) {
      final product = await _productRepository.getProduct(entry.key);
      final totalQuantityToReduce = entry.value;
      
      if (product.quantity < totalQuantityToReduce) {
        throw Exception(
          'Sản phẩm "${product.name}" không đủ số lượng. Còn lại: ${product.quantity}, cần: $totalQuantityToReduce',
        );
      }

      // Giảm quantity của sản phẩm
      final newQuantity = product.quantity - totalQuantityToReduce;
      
      // Thêm vào batch update
      batch.update(
        FirebaseFirestore.instance.collection('products').doc(product.id),
        {
          'quantity': newQuantity,
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

