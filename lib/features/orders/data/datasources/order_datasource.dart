import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/core/data/firebase_remote_data_source.dart';
import 'package:e_commerce/features/orders/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<String> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrdersByUserId(String userId);
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, String status);
  Stream<List<OrderModel>> getAllOrders();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseRemoteDS<OrderModel> _remoteSource;
  final CollectionReference _ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  OrderRemoteDataSourceImpl()
    : _remoteSource = FirebaseRemoteDS<OrderModel>(
        collectionName: 'orders',
        fromFirestore: (doc) => OrderModel.fromFirestore(doc),
        toFirestore: (model) => model.toFirestore(),
      );

  @override
  Future<String> createOrder(OrderModel order) async {
    return await _remoteSource.add(order);
  }

  @override
  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    // Get all orders for this user
    final snapshot = await _ordersCollection
        .where('userId', isEqualTo: userId)
        .get();

    // Sort by createdAt in descending order locally
    final orders = snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList();

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return orders;
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    return await _remoteSource.getById(orderId);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _ordersCollection.doc(orderId).update({'status': status});
  }

  @override
  Stream<List<OrderModel>> getAllOrders() {
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }
}
