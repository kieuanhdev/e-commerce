import 'package:flutter/material.dart';
import 'package:e_commerce/features/products/data/datasources/product_remote_datasource.dart';
import 'package:e_commerce/features/products/data/repositories/product_repository_impl.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/usecases/get_products.dart';

import '../widgets/product_card.dart';
import '../../../../home/presentation/widgets/bannner.dart';
import '../widgets/product_popular_section.dart';
import '../widgets/product_grid_sliver.dart';
import '../widgets/product_pagination.dart' as pagination_widget;
import 'product_detail_page.dart';

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

  late final ProductRemoteDataSource _remote = ProductRemoteDataSourceImpl();
  late final ProductRepositoryImpl _repo = ProductRepositoryImpl(_remote);
  late final GetProducts _getAllProducts = GetProducts(_repo);

  bool _isLoading = true;
  List<Product> _visibleProducts = [];

  int get pageCount => (_visibleProducts.length / itemsPerPage).ceil().clamp(1, 9999);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await _getAllProducts();
      // Chỉ hiển thị sản phẩm đang bật isVisible
      final visible = items.where((p) => p.isVisible == true).toList();
      setState(() {
        _visibleProducts = visible;
        currentPage = 0;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, _visibleProducts.length);
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
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else
          ProductGridSliver(
            itemCount: visibleCount,
            itemBuilder: (context, index) {
              final product = _visibleProducts[start + index];
              return ProductCard(
                imageUrl: product.imageUrl,
                helperText: product.categoryId ?? 'Product',
                title: product.name,
                description: product.shortDescription,
                price: product.price,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        productId: product.id,
                        title: product.name,
                        price: product.price,
                        brand: 'Brand',
                        description: product.longDescription,
                        imageUrls: product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? [product.imageUrl!]
                            : const [],
                        inStock: (product.quantity) > 0,
                      ),
                    ),
                  );
                },
              );
            },
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

// Removed old mock tile widget


