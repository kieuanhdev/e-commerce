import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/utils/failure.dart';
import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';

class UpdateOrderStatusUseCase {
  final IOrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(String orderId, String status) async {
    try {
      await _repository.updateOrderStatus(orderId, status);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}

