import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';

class UpdateOrderStatusUseCase {
  final IOrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<void> call(String orderId, String status) async {
    await _repository.updateOrderStatus(orderId, status);
  }
}
