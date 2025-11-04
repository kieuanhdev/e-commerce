import 'dart:async';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/repositories/product_repository.dart';

class OverviewStats {
  final int totalOrders;
  final double totalRevenue;
  final int totalCustomers;
  final int totalProducts;

  OverviewStats({
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCustomers,
    required this.totalProducts,
  });
}

class GetOverviewStatsUseCase {
  final IOrderRepository _orderRepository;
  final IAuthRepository _authRepository;
  final ProductRepository _productRepository;

  GetOverviewStatsUseCase(
    this._orderRepository,
    this._authRepository,
    this._productRepository,
  );

  Stream<OverviewStats> call() {
    final controller = StreamController<OverviewStats>();
    StreamSubscription<List<Order>>? ordersSubscription;
    
    // Cache để tránh fetch lại mỗi lần orders stream emit
    List<AppUser>? cachedUsers;
    List<Product>? cachedProducts;

    Future<void> calculateStats(List<Order> orders) async {
      try {
        // Calculate total orders and revenue
        final totalOrders = orders.length;
        final totalRevenue = orders.fold<double>(
          0,
          (sum, order) => sum + order.totalAmount,
        );

        // Get total customers (cache để tránh fetch lại nhiều lần)
        cachedUsers ??= await _authRepository.getAllUsers().first;
        final totalCustomers = cachedUsers!
            .where((u) => u.role == 'customer')
            .length;

        // Get total products (cache để tránh fetch lại nhiều lần)
        cachedProducts ??= await _productRepository.getProducts();
        final totalProducts = cachedProducts!.length;

        if (!controller.isClosed) {
          controller.add(OverviewStats(
            totalOrders: totalOrders,
            totalRevenue: totalRevenue,
            totalCustomers: totalCustomers,
            totalProducts: totalProducts,
          ));
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    ordersSubscription = _orderRepository.getAllOrders().listen(
      (orders) {
        calculateStats(orders);
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
      cancelOnError: false,
    );

    controller.onCancel = () {
      ordersSubscription?.cancel();
    };

    return controller.stream;
  }
}

