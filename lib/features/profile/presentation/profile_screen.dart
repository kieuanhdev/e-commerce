import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/core/routing/app_routers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            final avatar = (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : const AssetImage('images/avatar.png') as ImageProvider;
            
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: avatar,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'No Name',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildNavTile(
                    context,
                    "My orders",
                    "View your order history",
                    AppRouters.orders,
                  ),
                  _buildNavTile(
                    context,
                    "Settings",
                    "Notifications, password",
                    AppRouters.settings,
                  ),
                  _buildNavTile(
                    context,
                    "Logout",
                    "Sign out from your account",
                    "",
                    isLogout: true,
                  ),
                ],
              ),
            );
          }
          
          // Nếu chưa đăng nhập hoặc đang loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context,
    String title,
    String subtitle,
    String route, {
    bool isLogout = false,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
          trailing: const Icon(Icons.chevron_right),
          contentPadding: EdgeInsets.zero,
          onTap: () {
            if (isLogout) {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            } else {
              context.push(route);
            }
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
}
