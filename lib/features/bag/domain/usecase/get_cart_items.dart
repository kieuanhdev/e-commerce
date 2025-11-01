import 'package:e_commerce/features/bag/domain/entities/cart_item.dart';
import 'package:e_commerce/features/bag/domain/repository/bag_repository.dart';

class GetCartItemsUseCase {
  final IBagRepository _repository;

  GetCartItemsUseCase(this._repository);

  Future<List<CartItem>> call(String userId) {
    return _repository.getCartItems(userId);
  }
}

