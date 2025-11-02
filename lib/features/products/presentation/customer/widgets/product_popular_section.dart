import 'package:flutter/material.dart';
import 'package:e_commerce/features/products/data/datasources/product_remote_datasource.dart';
import 'package:e_commerce/features/products/data/repositories/product_repository_impl.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/usecases/get_products.dart';

import 'product_card.dart';
import '../pages/product_detail_page.dart';

class PopularProductsSection extends StatelessWidget {
  const PopularProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProductRepositoryImpl(ProductRemoteDataSourceImpl());
    final usecase = GetProducts(repo);

    return FutureBuilder<List<Product>>(
      future: usecase(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final items = (snapshot.data ?? [])
            .where((p) => p.isVisible == true)
            .toList()
          ..sort((a, b) => b.quantity.compareTo(a.quantity));
        final topItems = items.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sản phẩm phổ biến',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (hasError) {
                    return const Center(child: Text('Không thể tải sản phẩm phổ biến'));
                  }
                  if (topItems.isEmpty) {
                    return const Center(child: Text('Không có sản phẩm phổ biến'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    primary: false,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final p = topItems[index];
                      return SizedBox(
                        width: 280,
                        child: ProductCard(
                          imageUrl: p.imageUrl,
                          helperText: p.categoryId ?? 'Sản phẩm',
                          title: p.name,
                          description: p.shortDescription,
                          price: p.price,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(
                                  productId: p.id,
                                  title: p.name,
                                  price: p.price,
                                  brand: 'Thương hiệu',
                                  description: p.longDescription,
                                  imageUrls: p.imageUrl != null && p.imageUrl!.isNotEmpty
                                      ? [p.imageUrl!]
                                      : const [],
                                  inStock: (p.quantity) > 0,
                                  categoryId: p.categoryId,
                                  quantity: p.quantity,
                                  shortDescription: p.shortDescription,
                                  createdAt: p.createdAt,
                                  updatedAt: p.updatedAt,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemCount: topItems.length,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}


