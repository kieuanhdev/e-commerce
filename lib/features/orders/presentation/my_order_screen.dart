import 'package:flutter/material.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_Order> deliveryOrders = List.generate(
    3,
    (i) => _Order(
      id: '123456',
      trackingNumber: 'KA456789',
      quantity: 1,
      date: DateTime(2025, 9, 28),
      totalAmount: 100000,
      statusText: 'DELIVERY',
      statusColor: const Color(0xFF19B072),
    ),
  );

  final List<_Order> processingOrders = List.generate(
    3,
    (i) => _Order(
      id: '987654',
      trackingNumber: 'KB123456',
      quantity: 2,
      date: DateTime(2025, 9, 29),
      totalAmount: 250000,
      statusText: 'PROCESSING',
      statusColor: const Color(0xFFF5A524),
    ),
  );

  final List<_Order> cancelledOrders = List.generate(
    2,
    (i) => _Order(
      id: '111222',
      trackingNumber: 'KC654321',
      quantity: 1,
      date: DateTime(2025, 9, 30),
      totalAmount: 90000,
      statusText: 'CANCELLED',
      statusColor: const Color(0xFFE5484D),
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _SegmentedTabBar(controller: _tabController),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: TabBarView(
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
  final List<_Order> orders;
  final String Function(num) formatAmount;

  const _OrderList({
    required this.orders,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
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
  final _Order order;
  final String Function(num) formatAmount;

  const _OrderCard({
    required this.order,
    required this.formatAmount,
  });

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
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tracking number : ${order.trackingNumber}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Quantity:  ${order.quantity}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(order.date),
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
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('DETAILS'),
                ),
                const Spacer(),
                Text(
                  order.statusText,
                  style: TextStyle(
                    color: order.statusColor,
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
}

class _Order {
  final String id;
  final String trackingNumber;
  final int quantity;
  final DateTime date;
  final num totalAmount;
  final String statusText;
  final Color statusColor;

  const _Order({
    required this.id,
    required this.trackingNumber,
    required this.quantity,
    required this.date,
    required this.totalAmount,
    required this.statusText,
    required this.statusColor,
  });
}

String _formatDate(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year.toString();
  return '$day - $month - $year';
}


