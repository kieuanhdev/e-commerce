import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/core/widgets/main_nav_bar.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:e_commerce/features/auth/presentation/screens/login_screen.dart';
import 'package:e_commerce/features/auth/presentation/screens/signup_screen.dart';

import 'package:e_commerce/features/admin/presentation/admin_screen.dart';
import 'package:e_commerce/features/home/presentation/home_page.dart';
// import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/presentation/admin/pages/products_page.dart';
import 'package:e_commerce/features/settings/presentation/settings_screen.dart';
// import 'package:e_commerce/features/shop/presentation/shop_screen.dart';
import 'package:e_commerce/features/bag/presentation/bag_screen.dart';
import 'package:e_commerce/features/favorites/presentation/favorites_screen.dart';
import 'package:e_commerce/features/profile/presentation/profile_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppGoRouter {
  static final GoRouter route = GoRouter(
    initialLocation: AppRouters.login,
    debugLogDiagnostics: true,
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

      // ---------- MAIN SHELL (navigation dùng chung) ----------
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          // ---------- ADMIN ----------
          GoRoute(
            path: AppRouters.admin,
            name: AppRouteNames.admin,
            builder: (context, state) => const AdminScreen(),
          ),
          GoRoute(
            path: AppRouters.home,
            name: AppRouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRouters.shop,
            name: AppRouteNames.shop,
            builder: (context, state) => const ProductScreen(),
          ),
          GoRoute(
            path: AppRouters.bag,
            name: AppRouteNames.bag,
            builder: (context, state) => const BagScreen(),
          ),
          GoRoute(
            path: AppRouters.favorites,
            name: AppRouteNames.favorites,
            builder: (context, state) => const FavoritesScreen(),
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
      final user = (authState as AuthAuthenticated).user;
      final isAdmin = user.role == 'admin';
      final isGoingToAdmin = location.startsWith('/admin');

      if (isAuthFlow) {
        return isAdmin ? '/admin' : '/home';
      }

      if (!isAdmin && isGoingToAdmin) {
        return '/home';
      }

      return null;
    },
  );
}
