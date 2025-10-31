import 'package:flutter/material.dart';

import '../../presentation/widgets/product_popular_section.dart';
import '../../presentation/widgets/product_grid_sliver.dart';
import '../../presentation/widgets/product_pagination.dart';
import '../../presentation/widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  static const int itemsPerPage = 10;
  int currentPage = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _allProductKey = GlobalKey();

  late final List<int> _mock = List.generate(32, (i) => i);

  int get pageCount => (_mock.length / itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, _mock.length);
    final visible = end - start;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('All product')),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(child: PopularProductsSection()),
            SliverToBoxAdapter(
              child: Padding(
                key: _allProductKey,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: const Text('All product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            ProductGridSliver(
              itemCount: visible,
              itemBuilder: (context, index) => const ProductCard(
                helperText: 'Helper Text',
                title: 'Subheading',
                description: 'Descriptive Items',
                price: 100000000,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: ProductPagination(
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
                        _scrollController.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


