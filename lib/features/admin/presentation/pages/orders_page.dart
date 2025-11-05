import 'dart:async';

import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';
import 'package:e_commerce/core/theme/app_sizes.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/admin/domain/usecase/get_all_orders.dart';
import 'package:e_commerce/features/admin/domain/usecase/update_order_status.dart';
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  StreamSubscription<List<Order>>? _ordersSubscription;
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  final _getAllOrdersUseCase = sl<GetAllOrdersUseCase>();
  // final _updateOrderStatusUseCase = sl<UpdateOrderStatusUseCase>();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersSubscription?.cancel();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _ordersSubscription = _getAllOrdersUseCase().listen(
      (orders) {
        if (mounted) {
          setState(() {
            _orders = orders;
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
    _ordersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý Đơn hàng')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý Đơn hàng')),
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
                onPressed: _loadOrders,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý Đơn hàng')),
        body: Center(
          child: Text(
            'Chưa có đơn hàng nào',
            style: AppTextStyles.text16.copyWith(color: AppColors.placeholder),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Đơn hàng')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMD),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order.trackingNumber}',
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(order.createdAt),
                  style: AppTextStyles.text11.copyWith(
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMD),

            // Customer info
            Text(order.customerName, style: AppTextStyles.text14),
            Text(
              order.customerEmail,
              style: AppTextStyles.text11.copyWith(
                color: AppColors.placeholder,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSM),

            // Total amount
            Text(
              'Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(order.totalAmount)}',
              style: AppTextStyles.text14.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.saleHot,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMD),

            // Status dropdown
            Row(
              children: [
                Text(
                  'Trạng thái: ',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: DropdownButton<OrderStatus>(
                    value: order.status,
                    isExpanded: true,
                    items: OrderStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacingSM),
                            Text(status.text),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null && newStatus != order.status) {
                        _confirmAndUpdate(context, newStatus);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndUpdate(BuildContext context, OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận thay đổi'),
        content: Text(
          'Bạn có chắc chắn muốn chuyển đơn hàng #${order.trackingNumber} sang trạng thái "${newStatus.text}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await sl<UpdateOrderStatusUseCase>()(
                  order.id,
                  newStatus.displayName,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật trạng thái'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

extension OrderStatusX on OrderStatus {
  String get text {
    switch (this) {
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.delivery:
        return 'Đang giao hàng';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.delivery:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}
