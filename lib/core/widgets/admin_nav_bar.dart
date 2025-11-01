import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_commerce/core/routing/app_routers.dart';

class AdminNavigation extends StatefulWidget {
  final Widget child;
  const AdminNavigation({super.key, required this.child});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRouters.adminOverview)) return 0;
    if (location.startsWith(AppRouters.adminProducts)) return 1;
    if (location.startsWith(AppRouters.adminCustomers)) return 2;
    if (location.startsWith(AppRouters.adminOrders)) return 3;
    if (location.startsWith(AppRouters.adminProfile)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouters.adminOverview);
        break;
      case 1:
        context.go(AppRouters.adminProducts);
        break;
      case 2:
        context.go(AppRouters.adminCustomers);
        break;
      case 3:
        context.go(AppRouters.adminOrders);
        break;
      case 4:
        context.go(AppRouters.adminProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Sản phẩm'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Khách hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


