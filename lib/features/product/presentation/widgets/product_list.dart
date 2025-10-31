import 'package:flutter/material.dart';

import './product_card.dart';
import '../../../home/presentation/widgets/bannner.dart';
import './product_popular_section.dart';
import './product_grid_sliver.dart';
import './product_pagination.dart' as pagination_widget;
import '../pages/product_detail_page.dart';

class ProductListBody extends StatefulWidget {
  const ProductListBody({super.key});

  @override
  State<ProductListBody> createState() => _ProductListBodyState();
}

class _ProductListBodyState extends State<ProductListBody> {
  static const int itemsPerPage = 10;
  int currentPage = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _allProductKey = GlobalKey();

  late final List<({String helper, String title, String description, int price})> products = List.generate(
    32,
    (index) => (
      helper: 'Helper Text',
      title: 'Subheading',
      description: 'Descriptive Items',
      price: 100000000,
    ),
  );

  int get pageCount => (products.length / itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, products.length);
    final visibleCount = end - start;

    return CustomScrollView(
      controller: _scrollController,
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
        SliverToBoxAdapter(
          child: Padding(
            key: _allProductKey,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: const Text(
              'All product',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        ProductGridSliver(
          itemCount: visibleCount,
          itemBuilder: (context, index) => const _ProductTile(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: pagination_widget.ProductPagination(
              pageCount: pageCount,
              currentPage: currentPage,
              onPageSelected: (p) {
                setState(() => currentPage = p);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final ctx = _allProductKey.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      alignment: 0.02,
                    );
                  } else {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              },
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
    return ProductCard(
      helperText: 'Helper Text',
      title: 'Sleeveless Ruffle',
      description: 'Descriptive Items',
      price: 140.00,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProductDetailPage(
              title: 'Sleeveless Ruffle',
              price: 140.00,
              brand: 'Lipsy London',
            ),
          ),
        );
      },
    );
  }
}


