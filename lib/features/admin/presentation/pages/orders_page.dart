import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';
import 'package:e_commerce/core/theme/app_sizes.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/admin/presentation/bloc/admin_orders_bloc.dart';
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminOrdersBloc>()..add(const LoadAllOrders()),
      child: const _OrdersPageContent(),
    );
  }
}

class _OrdersPageContent extends StatelessWidget {
  const _OrdersPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
      ),
      body: BlocConsumer<AdminOrdersBloc, AdminOrdersState>(
        listener: (context, state) {
          if (state is AdminOrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminOrdersInitial || state is AdminOrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminOrdersError && state is! AdminOrdersLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSizes.spacingMD),
                  Text(
                    state.message,
                    style: AppTextStyles.text14.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingMD),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminOrdersBloc>().add(const LoadAllOrders());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminOrdersLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Text(
                  'Chưa có đơn hàng nào',
                  style: AppTextStyles.text16.copyWith(color: AppColors.placeholder),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _OrderCard(order: order);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.delivery:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.delivery:
        return 'Đang giao hàng';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

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
            Text(
              order.customerName,
              style: AppTextStyles.text14,
            ),
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
                                color: _getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacingSM),
                            Text(_getStatusText(status)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null && newStatus != order.status) {
                        _showConfirmDialog(context, order, newStatus);
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

  void _showConfirmDialog(BuildContext context, Order order, OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận thay đổi'),
        content: Text(
          'Bạn có chắc chắn muốn chuyển đơn hàng #${order.trackingNumber} sang trạng thái "${_getStatusText(newStatus)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminOrdersBloc>().add(
                    UpdateOrderStatus(order.id, newStatus),
                  );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã cập nhật trạng thái'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(newStatus),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

