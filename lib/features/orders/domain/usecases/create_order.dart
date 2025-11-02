import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';

class CreateOrderUseCase {
  final IOrderRepository _repository;

  CreateOrderUseCase(this._repository);

  Future<String> call(Order order) {
    return _repository.createOrder(order);
  }
}

