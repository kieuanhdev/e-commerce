import 'package:flutter/material.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _MyBagScreenState();
}

class _MyBagScreenState extends State<BagScreen> {
  final List<Map<String, dynamic>> products = [
    {
      "name": "Tên áo",
      "color": "Red",
      "size": "XL",
      "price": 100.0,
      "quantity": 1,
      "image": "https://i.imgur.com/BJm7pA4.png",
    },
    {
      "name": "Tên áo",
      "color": "Red",
      "size": "XL",
      "price": 100.0,
      "quantity": 1,
      "image": "https://i.imgur.com/BJm7pA4.png",
    },
    {
      "name": "Tên áo",
      "color": "Red",
      "size": "XL",
      "price": 200.0,
      "quantity": 1,
      "image": "https://i.imgur.com/tG7Q0jT.png",
    },
  ];

  final TextEditingController _couponController = TextEditingController();

  final List<Map<String, dynamic>> coupons = [
    {
      'title': 'SUMMER SALE',
      'code': 'summer2025',
      'remaining': 21,
      'image': 'https://i.imgur.com/UyN2d8u.png',
    },
    {
      'title': 'SUMMER SALE',
      'code': 'summer2025',
      'remaining': 21,
      'image': 'https://i.imgur.com/UyN2d8u.png',
    },
    {
      'title': 'SUMMER SALE',
      'code': 'summer2025',
      'remaining': 21,
      'image': 'https://i.imgur.com/UyN2d8u.png',
    },
  ];

  double get totalPrice {
    return products.fold(
      0,
      (sum, item) => sum + item['price'] * item['quantity'],
    );
  }

  String formatAmount(num amount, {bool withVnd = false}) {
    // Format as 1.234,56 and optionally append VND
    final intPart = amount.floor();
    final fracPart = ((amount - intPart) * 100).round();
    final intString = intPart
        .toString()
        .replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.");
    final fracString = fracPart.toString().padLeft(2, '0');
    final base = "$intString,$fracString";
    return withVnd ? "$base VND" : base;
  }

  void increaseQuantity(int index) {
    setState(() {
      products[index]['quantity']++;
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (products[index]['quantity'] > 1) {
        products[index]['quantity']--;
      }
    });
  }

  void addToFavorites(int index) {
    final name = products[index]['name'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm "$name" vào yêu thích')),
    );
  }

  void removeFromCart(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  void _openCouponSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Nhập mã giảm giá",
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(4),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  controller: _couponController,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Heading 3',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: coupons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final c = coupons[i];
                      return _CouponTile(
                        title: c['title'],
                        code: c['code'],
                        remaining: c['remaining'],
                        imageUrl: c['image'],
                        onApply: () {
                          _couponController.text = c['code'];
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã áp dụng mã ${c['code']}')),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
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
                            child: Image.network(
                              product['image'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
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
                                            product['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  text: 'Color: ',
                                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                  children: [
                                                    TextSpan(
                                                      text: product['color'],
                                                      style: const TextStyle(color: Colors.red),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text.rich(
                                                TextSpan(
                                                  text: 'Size: ',
                                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                  children: [
                                                    TextSpan(
                                                      text: product['size'],
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
                                          value: 0,
                                          child: Text('Thêm mục yêu thích'),
                                        ),
                                        PopupMenuItem(
                                          value: 1,
                                          child: Text('Xóa khỏi giỏ hàng'),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 0) {
                                          addToFavorites(index);
                                        } else if (value == 1) {
                                          removeFromCart(index);
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
                                            onPressed: () => decreaseQuantity(index),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              '${product['quantity']}',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          _CircleIconButton(
                                            icon: Icons.add,
                                            onPressed: () => increaseQuantity(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      formatAmount(product['price'], withVnd: true),
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
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: "Nhập mã giảm giá",
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: _openCouponSheet,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              controller: _couponController,
              readOnly: true,
              onTap: _openCouponSheet,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng tiền", style: TextStyle(fontSize: 16)),
                Text(
                  formatAmount(totalPrice),
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
                onPressed: () {},
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
      ),
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

class _CouponTile extends StatelessWidget {
  final String title;
  final String code;
  final int remaining;
  final String imageUrl;
  final VoidCallback onApply;

  const _CouponTile({
    required this.title,
    required this.code,
    required this.remaining,
    required this.imageUrl,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    code,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$remaining remaining',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF2AC17E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('APPLY'),
            ),
          ],
        ),
      ),
    );
  }
}
