import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/usecases/get_orders_by_user_id.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/core/routing/app_routers.dart';

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
            backgroundColor: Colors.red,
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _SegmentedTabBar(controller: _tabController),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
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

class _SegmentedTabBar extends StatelessWidget {
  final TabController controller;
  const _SegmentedTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: const [
          Tab(text: 'Delivery'),
          Tab(text: 'Processing'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }
}

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
        return const Color(0xFFF5A524);
      case OrderStatus.delivery:
        return const Color(0xFF19B072);
      case OrderStatus.cancelled:
        return const Color(0xFFE5484D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tracking number: ${order.trackingNumber}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Quantity: ${order.totalQuantity}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Text(
                          'Total amount:  ',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          '${formatAmount(order.totalAmount)} VND',
                          style: const TextStyle(fontSize: 12),
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
                  child: const Text('DETAILS'),
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
