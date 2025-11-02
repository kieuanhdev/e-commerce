import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce/features/bag/domain/entities/cart_item_with_product.dart';
import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/features/orders/domain/entities/order.dart';
import 'package:e_commerce/features/orders/domain/entities/order_item.dart';
import 'package:e_commerce/features/orders/domain/usecases/create_order_with_reduce_stock.dart';
import 'package:e_commerce/di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/features/bag/data/datasource/bag_datasource.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItemWithProduct> cartItems;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  String formatAmount(num amount, {bool withVnd = false}) {
    final formatter = NumberFormat('#,###');
    final formatted = formatter.format(amount);
    return withVnd ? '$formatted VND' : formatted;
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để thanh toán'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      // Tạo order items từ cart items
      final orderItems = widget.cartItems.map((item) {
        return OrderItem(
          productId: item.cartItem.productId,
          productName: item.product.name,
          productImageUrl: item.product.imageUrl,
          quantity: item.cartItem.quantity,
          price: item.product.price,
          color: item.cartItem.color,
          size: item.cartItem.size,
        );
      }).toList();

      // Tạo order
      final order = Order(
        id: '', // Sẽ được generate
        userId: authState.user.id,
        customerName: authState.user.displayName ?? '',
        customerEmail: authState.user.email,
        items: orderItems,
        totalAmount: widget.totalPrice,
        createdAt: DateTime.now(),
        status: OrderStatus.processing,
      );

      // Tạo order và giảm stock
      final createOrderUseCase = sl<CreateOrderWithReduceStockUseCase>();
      final orderId = await createOrderUseCase(order);

      // Xóa giỏ hàng
      final bagDataSource = sl<BagRemoteDataSource>();
      await bagDataSource.clearCart(authState.user.id);

      if (mounted) {
        // Navigate to success screen với orderId
        context.push(
          AppRouters.paymentSuccess,
          extra: {'orderId': orderId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thanh toán: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thanh toán",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Order Summary
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Đơn hàng",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...widget.cartItems.map((item) {
                    final cartItem = item.cartItem;
                    final product = item.product;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image, size: 24),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 24),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (cartItem.color != null || cartItem.size != null)
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        if (cartItem.color != null)
                                          Text.rich(
                                            TextSpan(
                                              text: 'Màu: ',
                                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                                              children: [
                                                TextSpan(
                                                  text: cartItem.color,
                                                  style: const TextStyle(color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (cartItem.size != null)
                                          Text.rich(
                                            TextSpan(
                                              text: 'Size: ',
                                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                                              children: [
                                                TextSpan(
                                                  text: cartItem.size,
                                                  style: const TextStyle(color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'x${cartItem.quantity}',
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatAmount(item.totalPrice, withVnd: true),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng tiền",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatAmount(widget.totalPrice, withVnd: true),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Thanh toán",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

