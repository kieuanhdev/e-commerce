import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart';
import 'package:e_commerce/features/orders/domain/repository/order_repository.dart';
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

  Stream<OverviewStats> call() async* {
    await for (final orders in _orderRepository.getAllOrders()) {
      // Calculate total orders and revenue
      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(
        0,
        (sum, order) => sum + order.totalAmount,
      );

      // Get total customers
      final users = await _authRepository.getAllUsers().first;
      final totalCustomers = users.where((u) => u.role == 'customer').length;

      // Get total products
      final products = await _productRepository.getProducts();
      final totalProducts = products.length;

      yield OverviewStats(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        totalCustomers: totalCustomers,
        totalProducts: totalProducts,
      );
    }
  }
}
