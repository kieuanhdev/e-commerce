import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String? orderId;

  const PaymentSuccessScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    void navigateToOrderDetail() {
      if (orderId != null) {
        context.go('${AppRouters.orders}/$orderId');
      } else {
        context.go(AppRouters.orders);
      }
    }
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 60,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Success Message
              Text(
                "Thanh toán thành công!",
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Cảm ơn bạn đã mua sắm tại cửa hàng của chúng tôi.\nĐơn hàng của bạn đã được xử lý thành công.",
                style: AppTextStyles.text14.copyWith(
                  color: AppColors.text.withOpacity(0.54),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(AppRouters.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Về trang chủ",
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: navigateToOrderDetail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.success, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Xem đơn hàng",
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

