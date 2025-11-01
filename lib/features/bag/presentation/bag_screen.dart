import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_bloc.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_event.dart';
import 'package:e_commerce/features/bag/presentation/bloc/bag_state.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce/di.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce/core/routing/app_routers.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  String formatAmount(num amount, {bool withVnd = false}) {
    final formatter = NumberFormat('#,###');
    final formatted = formatter.format(amount);
    return withVnd ? '$formatted VND' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "My Bag",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              backgroundColor: Colors.white,
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
              title: const Text(
                "My Bag",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              centerTitle: false,
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.black),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            body: BlocConsumer<BagBloc, BagState>(
              listener: (context, state) {
                if (state is BagError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is BagLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BagError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
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
                    return const Center(
                      child: Text('Giỏ hàng trống'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.cartItems.length,
                            itemBuilder: (context, index) {
                              final item = state.cartItems[index];
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
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.image),
                                                ),
                                              )
                                            : Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image),
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
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (cartItem.color != null || cartItem.size != null)
                                                        Row(
                                                          children: [
                                                            if (cartItem.color != null)
                                                              Text.rich(
                                                                TextSpan(
                                                                  text: 'Color: ',
                                                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                                  children: [
                                                                    TextSpan(
                                                                      text: cartItem.color,
                                                                      style: const TextStyle(color: Colors.red),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            if (cartItem.color != null && cartItem.size != null)
                                                              const SizedBox(width: 16),
                                                            if (cartItem.size != null)
                                                              Text.rich(
                                                                TextSpan(
                                                                  text: 'Size: ',
                                                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(24),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.08),
                                                        blurRadius: 6,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  child: Row(
                                                    children: [
                                                      _CircleIconButton(
                                                        icon: Icons.remove,
                                                        onPressed: () {
                                                          if (cartItem.quantity > 1) {
                                                            context.read<BagBloc>().add(
                                                                  UpdateQuantity(cartItem.id, cartItem.quantity - 1),
                                                                );
                                                          }
                                                        },
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Text(
                                                          '${cartItem.quantity}',
                                                          style: const TextStyle(fontSize: 16),
                                                        ),
                                                      ),
                                                      _CircleIconButton(
                                                        icon: Icons.add,
                                                        onPressed: () {
                                                          context.read<BagBloc>().add(
                                                                UpdateQuantity(cartItem.id, cartItem.quantity + 1),
                                                              );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  formatAmount(item.totalPrice, withVnd: true),
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tổng tiền", style: TextStyle(fontSize: 16)),
                            Text(
                              formatAmount(state.totalPrice),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
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
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "CHECK OUT",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
      ),
    );
  }
}
