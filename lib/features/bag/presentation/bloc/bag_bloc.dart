import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/bag/domain/usecase/get_cart_items_with_products.dart';
import 'package:e_commerce/features/bag/domain/usecase/add_to_cart.dart';
import 'package:e_commerce/features/bag/domain/usecase/remove_from_cart.dart';
import 'package:e_commerce/features/bag/domain/usecase/update_cart_item_quantity.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_event.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_state.dart';
import 'package:e_commerce/features/bag/domain/entities/cart_item.dart';
import 'package:e_commerce/features/bag/domain/entities/cart_item_with_product.dart';

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
        // Optimistic update: Xóa item khỏi UI ngay lập tức
        final updatedItems = currentState.cartItems
            .where((item) => item.cartItem.id != event.cartItemId)
            .toList();
        emit(BagLoaded(updatedItems, currentState.userId));
        
        try {
          // Sau đó xóa từ server
          await removeFromCartUseCase(event.cartItemId);
          // Không cần reload vì đã update optimistic
        } catch (e) {
          // Nếu lỗi, reload lại để sync với server
          try {
            final cartItems = await getCartItemsUseCase(currentState.userId);
            emit(BagLoaded(cartItems, currentState.userId));
          } catch (_) {
            emit(BagError('Lỗi khi xóa khỏi giỏ hàng: $e'));
          }
        }
      }
    });

    on<UpdateQuantity>((event, emit) async {
      final currentState = state;
      if (currentState is BagLoaded) {
        // Optimistic update: Cập nhật quantity ngay lập tức
        final updatedItems = currentState.cartItems.map((item) {
          if (item.cartItem.id == event.cartItemId) {
            // Tạo CartItem mới với quantity đã cập nhật
            final updatedCartItem = CartItem(
              id: item.cartItem.id,
              productId: item.cartItem.productId,
              userId: item.cartItem.userId,
              quantity: event.newQuantity,
              color: item.cartItem.color,
              size: item.cartItem.size,
              addedAt: item.cartItem.addedAt,
            );
            return CartItemWithProduct(
              cartItem: updatedCartItem,
              product: item.product,
            );
          }
          return item;
        }).toList();
        emit(BagLoaded(updatedItems, currentState.userId));
        
        try {
          // Sau đó cập nhật trên server
          await updateQuantityUseCase(event.cartItemId, event.newQuantity);
          // Không cần reload vì đã update optimistic
        } catch (e) {
          // Nếu lỗi, reload lại để sync với server
          try {
            final cartItems = await getCartItemsUseCase(currentState.userId);
            emit(BagLoaded(cartItems, currentState.userId));
          } catch (_) {
            emit(BagError('Lỗi khi cập nhật số lượng: $e'));
          }
        }
      }
    });
  }
}

