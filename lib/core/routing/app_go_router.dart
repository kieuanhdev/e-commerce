import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:e_commerce/features/auth/presentation/screens/login_screen.dart';
import 'package:e_commerce/features/auth/presentation/screens/signup_screen.dart';
import 'package:e_commerce/features/home/presentation/home_page.dart';
import 'package:go_router/go_router.dart';

class AppGoRouter {
  static final GoRouter route = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRouters.home,
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
  );
}
