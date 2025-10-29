import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/core/widgets/bottom_nav_bar.dart';
import 'package:e_commerce/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:e_commerce/features/auth/presentation/screens/login_screen.dart';
import 'package:e_commerce/features/auth/presentation/screens/signup_screen.dart';
import 'package:e_commerce/features/home/presentation/home_page.dart';
import 'package:e_commerce/features/shop/presentation/shop_screen.dart';
import 'package:e_commerce/features/bag/presentation/bag_screen.dart';
import 'package:e_commerce/features/favorites/presentation/favorites_screen.dart';
import 'package:e_commerce/features/profile/presentation/profile_screen.dart';
import 'package:go_router/go_router.dart';

class AppGoRouter {
  static final GoRouter route = GoRouter(
    initialLocation: AppRouters.home,
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
            path: AppRouters.favorites,
            name: AppRouteNames.favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppRouters.profile,
            name: AppRouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
