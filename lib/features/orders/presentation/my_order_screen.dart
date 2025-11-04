import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/usecases/get_orders_by_user_id.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Order> _allOrders = [];
  bool _isLoading = true;

  List<Order> get deliveryOrders =>
      _allOrders.where((o) => o.status == OrderStatus.delivery).toList();

  List<Order> get processingOrders =>
      _allOrders.where((o) => o.status == OrderStatus.processing).toList();

  List<Order> get cancelledOrders =>
      _allOrders.where((o) => o.status == OrderStatus.cancelled).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final useCase = sl<GetOrdersByUserIdUseCase>();
      final orders = await useCase(authState.user.id);
      
      if (mounted) {
        setState(() {
          _allOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải đơn hàng: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String formatAmount(num amount) {
    final intPart = amount.floor();
    final intString = intPart
        .toString()
        .replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.");
    return intString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Đơn hàng của tôi',
          style: AppTextStyles.headline3,
        ),
        centerTitle: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.text,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.text14.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              AppTextStyles.text14.copyWith(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Đang giao'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _OrderList(orders: deliveryOrders, formatAmount: formatAmount),
                _OrderList(orders: processingOrders, formatAmount: formatAmount),
                _OrderList(orders: cancelledOrders, formatAmount: formatAmount),
              ],
            ),
    );
  }
}

// Simplified: removed custom segmented control in favor of default TabBar above

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final String Function(num) formatAmount;

  const _OrderList({
    required this.orders,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Không có đơn hàng nào'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _OrderCard(
        order: orders[i],
        formatAmount: formatAmount,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final String Function(num) formatAmount;

  const _OrderCard({
    required this.order,
    required this.formatAmount,
  });

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return AppColors.saleHot; // Màu cam cho processing
      case OrderStatus.delivery:
        return AppColors.success; // Màu xanh cho delivery
      case OrderStatus.cancelled:
        return AppColors.error; // Màu đỏ cho cancelled
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn hàng #${order.id.substring(0, 8)}',
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mã vận đơn: ${order.trackingNumber}',
                        style: AppTextStyles.text11.copyWith(color: AppColors.text.withOpacity(0.54)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Số lượng: ${order.totalQuantity}',
                        style: AppTextStyles.text11.copyWith(color: AppColors.text.withOpacity(0.54)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(order.createdAt),
                      style: AppTextStyles.text11.copyWith(color: AppColors.text.withOpacity(0.54)),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          'Tổng tiền:  ',
                          style: AppTextStyles.text11.copyWith(color: AppColors.text.withOpacity(0.54)),
                        ),
                        Text(
                          '${formatAmount(order.totalAmount)} VND',
                          style: AppTextStyles.text11,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    context.push(
                      '${AppRouters.orders}/${order.id}',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('CHI TIẾT'),
                ),
                const Spacer(),
                Text(
                  order.status.displayName,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day - $month - $year';
  }
}
