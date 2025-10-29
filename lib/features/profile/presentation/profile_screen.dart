import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // thêm import go_router

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('images/avatar.png'),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Kieuanhdev",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "kieuanh.dev@gmail.com",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

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
          ],
        ),
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
