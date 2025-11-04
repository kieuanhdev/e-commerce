import 'dart:async';

import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';
import 'package:e_commerce/core/theme/app_sizes.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/admin/domain/usecase/get_overview_stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOverviewPage extends StatefulWidget {
  const AdminOverviewPage({super.key});

  @override
  State<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage> {
  StreamSubscription<OverviewStats>? _statsSubscription;
  OverviewStats? _stats;
  bool _isLoading = true;
  String? _error;

  final _getOverviewStatsUseCase = sl<GetOverviewStatsUseCase>();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _statsSubscription?.cancel();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _statsSubscription = _getOverviewStatsUseCase().listen(
      (stats) {
        if (mounted) {
          setState(() {
            _stats = stats;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tổng quan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tổng quan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSizes.spacingMD),
              Text(
                _error!,
                style: AppTextStyles.text14.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingMD),
              ElevatedButton(
                onPressed: _loadStats,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_stats == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tổng quan')),
        body: const Center(child: Text('Không có dữ liệu')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSizes.spacingMD,
              mainAxisSpacing: AppSizes.spacingMD,
              childAspectRatio: 1.2,
              children: [
                _StatCard(
                  title: 'Đơn hàng',
                  value: _stats!.totalOrders.toString(),
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Doanh thu',
                  value: NumberFormat.compact(locale: 'vi').format(_stats!.totalRevenue),
                  subtitle: '₫',
                  icon: Icons.attach_money,
                  color: AppColors.success,
                ),
                _StatCard(
                  title: 'Khách hàng',
                  value: _stats!.totalCustomers.toString(),
                  icon: Icons.people,
                  color: AppColors.saleHot,
                ),
                _StatCard(
                  title: 'Sản phẩm',
                  value: _stats!.totalProducts.toString(),
                  icon: Icons.inventory,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
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
      elevation: AppSizes.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizes.iconXL, color: color),
            const SizedBox(height: AppSizes.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: AppTextStyles.headline3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingXS),
            Text(
              title,
              style: AppTextStyles.text14.copyWith(color: AppColors.placeholder),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
