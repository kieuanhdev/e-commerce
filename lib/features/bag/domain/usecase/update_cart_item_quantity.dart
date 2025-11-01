import 'package:e_commerce/features/bag/domain/repository/bag_repository.dart';

class UpdateCartItemQuantityUseCase {
  final IBagRepository _repository;

  UpdateCartItemQuantityUseCase(this._repository);

  Future<void> call(String cartItemId, int newQuantity) {
    return _repository.updateQuantity(cartItemId, newQuantity);
  }
}

