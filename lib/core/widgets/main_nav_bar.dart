import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/core/theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;
  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRouters.home)) return 0;
    if (location.startsWith(AppRouters.shop)) return 1;
    if (location.startsWith(AppRouters.bag)) return 2;
    if (location.startsWith(AppRouters.profile)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouters.home);
        break;
      case 1:
        context.go(AppRouters.shop);
        break;
      case 2:
        context.go(AppRouters.bag);
        break;
      case 3:
        context.go(AppRouters.profile);
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
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.placeholder,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Cửa hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
