import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/bag/domain/usecase/get_cart_items_with_products.dart';
import 'package:e_commerce/features/bag/domain/usecase/add_to_cart.dart';
import 'package:e_commerce/features/bag/domain/usecase/remove_from_cart.dart';
import 'package:e_commerce/features/bag/domain/usecase/update_cart_item_quantity.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_event.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_state.dart';

class BagBloc extends Bloc<BagEvent, BagState> {
  final GetCartItemsWithProductsUseCase getCartItemsUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartItemQuantityUseCase updateQuantityUseCase;

  BagBloc({
    required this.getCartItemsUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateQuantityUseCase,
  }) : super(BagInitial()) {
    on<LoadCartItems>((event, emit) async {
      emit(BagLoading());
      try {
        final cartItems = await getCartItemsUseCase(event.userId);
        emit(BagLoaded(cartItems, event.userId));
      } catch (e) {
        emit(BagError(e.toString()));
      }
    });

    on<AddToCart>((event, emit) async {
      try {
        await addToCartUseCase(
          userId: event.userId,
          productId: event.productId,
          quantity: event.quantity,
          color: event.color,
          size: event.size,
        );
        emit(const BagItemAdded('Đã thêm vào giỏ hàng!'));
        
        // Reload cart items với product info
        final cartItems = await getCartItemsUseCase(event.userId);
        emit(BagLoaded(cartItems, event.userId));
      } catch (e) {
        emit(BagError('Lỗi khi thêm vào giỏ hàng: $e'));
      }
    });

    on<RemoveFromCart>((event, emit) async {
      final currentState = state;
      if (currentState is BagLoaded) {
        try {
          await removeFromCartUseCase(event.cartItemId);
          
          // Reload cart items
          final cartItems = await getCartItemsUseCase(currentState.userId);
          emit(BagLoaded(cartItems, currentState.userId));
        } catch (e) {
          emit(BagError('Lỗi khi xóa khỏi giỏ hàng: $e'));
        }
      }
    });

    on<UpdateQuantity>((event, emit) async {
      final currentState = state;
      if (currentState is BagLoaded) {
        try {
          await updateQuantityUseCase(event.cartItemId, event.newQuantity);
          
          // Reload cart items
          final cartItems = await getCartItemsUseCase(currentState.userId);
          emit(BagLoaded(cartItems, currentState.userId));
        } catch (e) {
          emit(BagError('Lỗi khi cập nhật số lượng: $e'));
        }
      }
    });
  }
}

