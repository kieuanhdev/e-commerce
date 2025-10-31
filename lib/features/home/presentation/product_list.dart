import 'package:flutter/material.dart';

import 'widgets/product_card.dart';
import 'widgets/bannner.dart';
import 'product_popular.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ProductListBody(),
      ),
    );
  }
}

class ProductListBody extends StatelessWidget {
  const ProductListBody({super.key});

  @override
  Widget build(BuildContext context) {
    final products = List.generate(
      6,
      (index) => (
        helper: 'Helper Text',
        title: 'Subheading',
        description: 'Descriptive Items',
        price: 100000000,
      ),
    );

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: BannerCarousel(
              title: 'Heading 3',
              height: 160,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: PopularProductsSection(),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'All product',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const _ProductTile();
              },
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile();

  @override
  Widget build(BuildContext context) {
    return const ProductCard(
      helperText: 'Helper Text',
      title: 'Subheading',
      description: 'Descriptive Items',
      price: 100000000,
    );
  }
}


