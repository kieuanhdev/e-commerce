import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_bloc.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_event.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_state.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';

class BuyNowSheet extends StatefulWidget {
  const BuyNowSheet({
    super.key,
    required this.productId,
    required this.title,
    required this.unitPrice,
  });
  final String productId;
  final String title;
  final double unitPrice;

  @override
  State<BuyNowSheet> createState() => _BuyNowSheetState();
}

class _BuyNowSheetState extends State<BuyNowSheet> {
  int quantity = 2;
  double get total => widget.unitPrice * quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: AppTextStyles.text16.copyWith(fontWeight: FontWeight.w700)),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đơn giá', style: AppTextStyles.text14.copyWith(color: AppColors.text.withOpacity(0.54))),
                      const SizedBox(height: 8),
                      Text('\$${widget.unitPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.headline2.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Text('Số lượng', style: AppTextStyles.text14.copyWith(color: AppColors.text.withOpacity(0.54))),
                const SizedBox(width: 8),
                _QtyControl(value: quantity, onChanged: (v) => setState(() => quantity = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('\$${total.toStringAsFixed(2)}',
                                  style: AppTextStyles.headline3.copyWith(color: AppColors.white, fontWeight: FontWeight.w800)),
                              Text('Tổng tiền', style: AppTextStyles.text11.copyWith(color: AppColors.white.withOpacity(0.7))),
                            ],
                          ),
                        ),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            if (authState is AuthAuthenticated) {
                              return BlocProvider<BagBloc>(
                                create: (_) => sl<BagBloc>(),
                                child: BlocConsumer<BagBloc, BagState>(
                                  listener: (context, bagState) {
                                    if (bagState is BagItemAdded) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(bagState.message),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                    if (bagState is BagError) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(bagState.message),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  },
                                  builder: (context, bagState) {
                                    final isLoading = bagState is BagLoading;
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.white,
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              context.read<BagBloc>().add(
                                                    AddToCart(
                                                      userId: authState.user.id,
                                                      productId: widget.productId,
                                                      quantity: quantity,
                                                    ),
                                                  );
                                            },
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : Text('Thêm vào giỏ', style: AppTextStyles.text14.copyWith(fontWeight: FontWeight.w700)),
                                    );
                                  },
                                ),
                              );
                            }
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Vui lòng đăng nhập để thêm vào giỏ hàng'),
                                    backgroundColor: AppColors.saleHot,
                                  ),
                                );
                              },
                              child: Text('Add to cart', style: AppTextStyles.text14.copyWith(fontWeight: FontWeight.w700)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(icon: Icons.remove, onTap: () => onChanged(value > 1 ? value - 1 : 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$value', style: AppTextStyles.text16.copyWith(fontWeight: FontWeight.w700)),
        ),
        _QtyButton(icon: Icons.add, onTap: () => onChanged(value + 1)),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.placeholder),
        ),
        child: Icon(icon),
      ),
    );
  }
}


