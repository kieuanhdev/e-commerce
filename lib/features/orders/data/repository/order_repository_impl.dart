import 'package:e_commerce/features/orders/data/datasources/order_datasource.dart';
import 'package:e_commerce/features/orders/data/models/order_model.dart';
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final OrderRemoteDataSource _dataSource;

  OrderRepositoryImpl(this._dataSource);

  @override
  Future<String> createOrder(Order order) async {
    final orderModel = OrderModel.fromEntity(order);
    return await _dataSource.createOrder(orderModel);
  }

  @override
  Future<List<Order>> getOrdersByUserId(String userId) async {
    final models = await _dataSource.getOrdersByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    final model = await _dataSource.getOrderById(orderId);
    return model?.toEntity();
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _dataSource.updateOrderStatus(orderId, status);
  }

  @override
  Stream<List<Order>> getAllOrders() {
    return _dataSource.getAllOrders().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}

