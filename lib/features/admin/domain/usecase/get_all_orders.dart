import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';

class GetAllOrdersUseCase {
  final IOrderRepository _repository;

  GetAllOrdersUseCase(this._repository);

  Stream<List<Order>> call() {
    return _repository.getAllOrders();
  }
}
