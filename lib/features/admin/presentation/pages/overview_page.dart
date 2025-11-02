import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/admin/presentation/bloc/overview_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OverviewBloc>()..add(const LoadOverviewStats()),
      child: const _OverviewPageContent(),
    );
  }
}

class _OverviewPageContent extends StatelessWidget {
  const _OverviewPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan')),
      body: BlocBuilder<OverviewBloc, OverviewState>(
        builder: (context, state) {
          if (state is OverviewInitial || state is OverviewLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OverviewError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OverviewBloc>().add(
                        const LoadOverviewStats(),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is OverviewLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _StatCard(
                        title: 'Đơn hàng',
                        value: state.stats.totalOrders.toString(),
                        icon: Icons.shopping_cart,
                        color: Colors.blue,
                      ),
                      _StatCard(
                        title: 'Doanh thu',
                        value: NumberFormat.compact(
                          locale: 'vi',
                        ).format(state.stats.totalRevenue),
                        subtitle: '₫',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                      _StatCard(
                        title: 'Khách hàng',
                        value: state.stats.totalCustomers.toString(),
                        icon: Icons.people,
                        color: Colors.orange,
                      ),
                      _StatCard(
                        title: 'Sản phẩm',
                        value: state.stats.totalProducts.toString(),
                        icon: Icons.inventory,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
