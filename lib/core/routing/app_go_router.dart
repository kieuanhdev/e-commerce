import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/core/widgets/main_nav_bar.dart';
import 'package:e_commerce/core/widgets/admin_nav_bar.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:e_commerce/features/auth/presentation/screens/login_screen.dart';
import 'package:e_commerce/features/auth/presentation/screens/signup_screen.dart';

import 'package:e_commerce/features/admin/presentation/pages/overview_page.dart';
import 'package:e_commerce/features/admin/presentation/pages/customers_page.dart';
import 'package:e_commerce/features/admin/presentation/pages/orders_page.dart';
import 'package:e_commerce/features/home/presentation/home_page.dart';
// import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/presentation/admin/pages/products_page.dart';
import 'package:e_commerce/features/settings/presentation/settings_screen.dart';
// import 'package:e_commerce/features/shop/presentation/shop_screen.dart';
import 'package:e_commerce/features/bag/presentation/bag_screen.dart';
import 'package:e_commerce/features/bag/presentation/payment_screen.dart';
import 'package:e_commerce/features/bag/presentation/payment_success_screen.dart';
import 'package:e_commerce/features/profile/presentation/profile_screen.dart';
import 'package:e_commerce/features/shop/presentation/shop_screen.dart';
import 'package:e_commerce/features/orders/presentation/my_order_screen.dart';
import 'package:e_commerce/features/orders/presentation/order_detail_screen.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppGoRouter {
  static GoRouter create(BuildContext context) => GoRouter(
    initialLocation: AppRouters.login,
    debugLogDiagnostics: true,
    // Rebuild redirects when AuthBloc state changes
    refreshListenable: GoRouterRefreshStream(context.read<AuthBloc>().stream),
    routes: [
      // ---------- AUTH ----------
      GoRoute(
        path: AppRouters.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouters.register,
        name: AppRouteNames.register,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRouters.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // ---------- PAYMENT ----------
      GoRoute(
        path: AppRouters.payment,
        name: AppRouteNames.payment,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentScreen(
            cartItems: extra?['cartItems'] ?? [],
            totalPrice: extra?['totalPrice'] ?? 0.0,
          );
        },
      ),
      GoRoute(
        path: AppRouters.paymentSuccess,
        name: AppRouteNames.paymentSuccess,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentSuccessScreen(orderId: extra?['orderId']);
        },
      ),

      // ---------- CUSTOMER SHELL ----------
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: AppRouters.home,
            name: AppRouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRouters.shop,
            name: AppRouteNames.shop,
            builder: (context, state) => const ShopScreen(),
          ),
          GoRoute(
            path: AppRouters.bag,
            name: AppRouteNames.bag,
            builder: (context, state) => const BagScreen(),
          ),
          GoRoute(
            path: AppRouters.profile,
            name: AppRouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRouters.settings,
            name: AppRouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRouters.orders,
            name: AppRouteNames.orders,
            builder: (context, state) => const MyOrderScreen(),
          ),
          GoRoute(
            path: AppRouters.orderDetail,
            name: AppRouteNames.orderDetail,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId'] ?? '';
              return OrderDetailScreen(orderId: orderId);
            },
          ),
        ],
      ),
      // ---------- ADMIN SHELL ----------
      ShellRoute(
        builder: (context, state, child) => AdminNavigation(child: child),
        routes: [
          GoRoute(
            path: AppRouters.adminOverview,
            name: AppRouteNames.adminOverview,
            builder: (context, state) => const AdminOverviewPage(),
          ),
          GoRoute(
            path: AppRouters.adminProducts,
            name: AppRouteNames.adminProducts,
            builder: (context, state) => const ProductScreen(),
          ),
          GoRoute(
            path: AppRouters.adminCustomers,
            name: AppRouteNames.adminCustomers,
            builder: (context, state) => const AdminCustomersPage(),
          ),
          GoRoute(
            path: AppRouters.adminOrders,
            name: AppRouteNames.adminOrders,
            builder: (context, state) => const AdminOrdersPage(),
          ),
          GoRoute(
            path: AppRouters.adminProfile,
            name: AppRouteNames.adminProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = context.read<AuthBloc>().state;
      final location = state.matchedLocation;

      // Không còn route '/splash' -> giữ nguyên vị trí khi đang init/loading
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      final isLoggedIn = authState is AuthAuthenticated;
      final isAuthFlow =
          location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';

      if (!isLoggedIn) {
        return isAuthFlow ? null : '/login';
      }

      // ĐÃ đăng nhập
      final user = authState.user;
      final isAdmin = user.role == 'admin';
      final isGoingToAdmin = location.startsWith('/admin');
      final isGoingToCustomerShell = location.startsWith('/home') || location.startsWith('/shop') || location.startsWith('/bag') || location.startsWith('/profile') || location.startsWith('/settings');

      if (isAuthFlow) {
        // Chỉ chuyển khỏi trang auth khi đã đăng nhập
        return isLoggedIn ? (isAdmin ? AppRouters.adminOverview : AppRouters.home) : null;
      }

      if (!isAdmin && isGoingToAdmin) {
        return AppRouters.home;
      }
      if (isAdmin && isGoingToCustomerShell && location != AppRouters.home && location != AppRouters.shop && location != AppRouters.bag && location != AppRouters.profile && location != AppRouters.settings) {
        return AppRouters.adminOverview;
      }

      return null;
    },
  );
}
