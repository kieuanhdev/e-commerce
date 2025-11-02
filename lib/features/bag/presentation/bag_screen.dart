import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_bloc.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_event.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_state.dart';
import 'package:e_commerce/features/bag/domain/entities/cart_item_with_product.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/di.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce/core/routing/app_routers.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatAmount(num amount, {bool withVnd = false}) {
    final formatter = NumberFormat('#,###');
    final formatted = formatter.format(amount);
    return withVnd ? '$formatted VND' : formatted;
  }

  List<CartItemWithProduct> _filterCartItems(List<CartItemWithProduct> items, String query) {
    if (query.isEmpty) {
      return items;
    }
    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.product.name.toLowerCase().contains(lowerQuery) ||
          (item.product.shortDescription.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Giỏ hàng",
                style: AppTextStyles.headline3,
              ),
              backgroundColor: AppColors.white,
              elevation: 0,
            ),
            body: const Center(
              child: Text('Vui lòng đăng nhập để xem giỏ hàng'),
            ),
          );
        }

        final userId = authState.user.id;

        return BlocProvider<BagBloc>(
          create: (_) {
            final bloc = sl<BagBloc>();
            bloc.add(LoadCartItems(userId));
            return bloc;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text(
                    "Giỏ hàng",
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.placeholder.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.text14,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm...',
                          hintStyle: AppTextStyles.text14.copyWith(color: AppColors.placeholder),
                          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.placeholder),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              backgroundColor: AppColors.white,
              elevation: 0,
            ),
            backgroundColor: AppColors.background,
            body: BlocConsumer<BagBloc, BagState>(
              listener: (context, state) {
                if (state is BagError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is BagLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is BagError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: AppTextStyles.text14,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<BagBloc>().add(LoadCartItems(userId));
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is BagLoaded) {
                  if (state.cartItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 100,
                            color: AppColors.placeholder,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Giỏ hàng trống',
                            style: AppTextStyles.headline3.copyWith(
                              color: AppColors.text.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thêm sản phẩm vào giỏ hàng của bạn',
                            style: AppTextStyles.text14.copyWith(
                              color: AppColors.placeholder,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredItems = _filterCartItems(state.cartItems, _searchQuery);
                  
                  if (filteredItems.isEmpty && _searchQuery.isNotEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy sản phẩm nào trong giỏ hàng'),
                    );
                  }

                  final filteredTotalPrice = filteredItems.fold(0.0, (sum, item) => sum + item.totalPrice);

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final cartItem = item.cartItem;
                              final product = item.product;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
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
                                        borderRadius: BorderRadius.circular(12),
                                        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                product.imageUrl!,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: AppColors.background,
                                                  child: Icon(Icons.image, color: AppColors.placeholder),
                                                ),
                                              )
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                color: AppColors.background,
                                                child: Icon(Icons.image, color: AppColors.placeholder),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        product.name,
                                                        style: AppTextStyles.text16.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (cartItem.color != null || cartItem.size != null)
                                                        Row(
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
                                                            if (cartItem.color != null && cartItem.size != null)
                                                              const SizedBox(width: 16),
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
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuButton<int>(
                                                  itemBuilder: (context) => const [
                                                    PopupMenuItem(
                                                      value: 1,
                                                      child: Text('Xóa khỏi giỏ hàng'),
                                                    ),
                                                  ],
                                                  onSelected: (value) {
                                                    if (value == 1) {
                                                      context.read<BagBloc>().add(RemoveFromCart(cartItem.id));
                                                    }
                                                  },
                                                  icon: const Icon(Icons.more_vert),
                                                  tooltip: 'Tùy chọn',
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.background,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: AppColors.placeholder.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          if (cartItem.quantity > 1) {
                                                            context.read<BagBloc>().add(
                                                                  UpdateQuantity(cartItem.id, cartItem.quantity - 1),
                                                                );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(8),
                                                          child: Icon(
                                                            Icons.remove,
                                                            size: 18,
                                                            color: cartItem.quantity > 1 ? AppColors.text : AppColors.placeholder,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                                        child: Text(
                                                          '${cartItem.quantity}',
                                                          style: AppTextStyles.text14.copyWith(
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          context.read<BagBloc>().add(
                                                                UpdateQuantity(cartItem.id, cartItem.quantity + 1),
                                                              );
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(8),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 18,
                                                            color: AppColors.primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  formatAmount(item.totalPrice, withVnd: true),
                                                  style: AppTextStyles.text16.copyWith(
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
                          },
                        ),
                      ),
                      // Bottom checkout section with shadow
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
                                            formatAmount(filteredTotalPrice, withVnd: true),
                                            style: AppTextStyles.headline3.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${filteredItems.length} sản phẩm',
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
                                    onPressed: () {
                                      context.push(
                                        AppRouters.payment,
                                        extra: {
                                          'cartItems': state.cartItems,
                                          'totalPrice': state.totalPrice,
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Thanh toán",
                                          style: AppTextStyles.text16.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20),
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
                  );
                }

                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        );
      },
    );
  }
}
