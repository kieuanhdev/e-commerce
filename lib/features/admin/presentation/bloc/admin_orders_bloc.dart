import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:e_commerce/features/admin/domain/usecase/get_all_orders.dart';
import 'package:e_commerce/features/admin/domain/usecase/update_order_status.dart';
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:equatable/equatable.dart';

part 'admin_orders_event.dart';
part 'admin_orders_state.dart';

class AdminOrdersBloc extends Bloc<AdminOrdersEvent, AdminOrdersState> {
  final GetAllOrdersUseCase _getAllOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  StreamSubscription<List<Order>>? _ordersSubscription;

  AdminOrdersBloc({
    required GetAllOrdersUseCase getAllOrdersUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  }) : _getAllOrdersUseCase = getAllOrdersUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       super(AdminOrdersInitial()) {
    on<LoadAllOrders>(_onLoadAllOrders);
    on<OrdersUpdated>(_onOrdersUpdated);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }

  void _onLoadAllOrders(LoadAllOrders event, Emitter<AdminOrdersState> emit) {
    _ordersSubscription?.cancel();
    _ordersSubscription = _getAllOrdersUseCase().listen(
      (orders) {
        add(OrdersUpdated(orders));
      },
      onError: (error) {
        emit(AdminOrdersError(error.toString()));
      },
    );
  }

  void _onOrdersUpdated(OrdersUpdated event, Emitter<AdminOrdersState> emit) {
    emit(AdminOrdersLoaded(event.orders));
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<AdminOrdersState> emit,
  ) async {
    if (state is AdminOrdersLoaded) {
      final currentState = state as AdminOrdersLoaded;

      emit(AdminOrdersLoading(currentState.orders));

      final result = await _updateOrderStatusUseCase(
        event.orderId,
        event.newStatus.displayName,
      );

      result.fold((failure) => emit(AdminOrdersError(failure.message)), (_) {
        // State sẽ được cập nhật tự động qua stream
      });
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
