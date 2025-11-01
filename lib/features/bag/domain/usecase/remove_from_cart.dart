import 'package:e_commerce/features/bag/domain/repository/bag_repository.dart';

class RemoveFromCartUseCase {
  final IBagRepository _repository;

  RemoveFromCartUseCase(this._repository);

  Future<void> call(String cartItemId) {
    return _repository.removeFromCart(cartItemId);
  }
}

