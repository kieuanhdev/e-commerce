import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/features/home/presentation/home_page.dart';
import 'package:go_router/go_router.dart';

class AppGoRouter {
  static final GoRouter route = GoRouter(
    initialLocation: AppRouters.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRouters.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
