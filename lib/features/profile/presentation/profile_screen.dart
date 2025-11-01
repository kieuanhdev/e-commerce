import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';

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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search),
          ),
        ],
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
                    "Already have 12 orders",
                    "/orders",
                  ),
                  _buildNavTile(context, "Shipping address", "3 address", "/address"),
                  _buildNavTile(context, "Payment methods", "Visa **34", "/payment"),
                  _buildNavTile(
                    context,
                    "Promocodes",
                    "You have special promocodes",
                    "/promocodes",
                  ),
                  _buildNavTile(
                    context,
                    "My reviews",
                    "Review for 4 items",
                    "/reviews",
                  ),
                  _buildNavTile(
                    context,
                    "Settings",
                    "Notifications, password",
                    "/settings",
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    contentPadding: EdgeInsets.zero,
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
    String route,
  ) {
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
          onTap: () => context.push(route), // dùng go_router
        ),
        const Divider(height: 1),
      ],
    );
  }
}
