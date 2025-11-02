import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';

class GetOrderByIdUseCase {
  final IOrderRepository _repository;

  GetOrderByIdUseCase(this._repository);

  Future<Order?> call(String orderId) {
    return _repository.getOrderById(orderId);
  }
}

