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
import 'package:e_commerce/features/products/domain/services/product_cache_service.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';

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
        SnackBar(
          content: Text('Bạn cần đăng nhập để thanh toán'),
          backgroundColor: AppColors.error,
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

      // Xóa cache sản phẩm để refresh dữ liệu mới
      ProductCacheService.instance.clearCache();

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
            backgroundColor: AppColors.error,
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
        title: Text(
          "Thanh toán",
          style: AppTextStyles.headline3,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Order Summary
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                  Text(
                    "Đơn hàng",
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 12),
                  ...widget.cartItems.map((item) {
                    final cartItem = item.cartItem;
                    final product = item.product;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl!,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 70,
                                        height: 70,
                                        color: AppColors.background,
                                        child: Icon(Icons.image, size: 24, color: AppColors.placeholder),
                                      ),
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: AppColors.background,
                                      child: Icon(Icons.image, size: 24, color: AppColors.placeholder),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: AppTextStyles.text14.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (cartItem.color != null || cartItem.size != null)
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        if (cartItem.color != null)
                                          Text.rich(
                                            TextSpan(
                                              text: 'Màu sắc: ',
                                              style: AppTextStyles.text11.copyWith(color: AppColors.text.withOpacity(0.54)),
                                              children: [
                                                TextSpan(
                                                  text: cartItem.color,
                                                  style: AppTextStyles.text11.copyWith(color: AppColors.error),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (cartItem.size != null)
                                          Text.rich(
                                            TextSpan(
                                              text: 'Kích cỡ: ',
                                              style: AppTextStyles.text11.copyWith(color: AppColors.text.withOpacity(0.54)),
                                              children: [
                                                TextSpan(
                                                  text: cartItem.size,
                                                  style: AppTextStyles.text11.copyWith(color: AppColors.error),
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
                                        style: AppTextStyles.text11.copyWith(color: AppColors.text.withOpacity(0.54)),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatAmount(item.totalPrice, withVnd: true),
                                        style: AppTextStyles.text14.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
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
              ],
            ),
          ),
          // Bottom payment section
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tổng tiền",
                                style: AppTextStyles.text14.copyWith(
                                  color: AppColors.text.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatAmount(widget.totalPrice, withVnd: true),
                                style: AppTextStyles.headline3.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${widget.cartItems.length} sản phẩm',
                            style: AppTextStyles.text14.copyWith(
                              color: AppColors.text.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          disabledBackgroundColor: AppColors.placeholder,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isProcessing
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Xác nhận thanh toán",
                                    style: AppTextStyles.text16.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.check_circle_outline, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

