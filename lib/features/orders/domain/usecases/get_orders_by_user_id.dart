import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';

class GetOrdersByUserIdUseCase {
  final IOrderRepository _repository;

  GetOrdersByUserIdUseCase(this._repository);

  Future<List<Order>> call(String userId) {
    return _repository.getOrdersByUserId(userId);
  }
}

