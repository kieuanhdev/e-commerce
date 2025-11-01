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
  final TextEditingController _searchController = TextEditingController();

  late final ProductRemoteDataSource _remote = ProductRemoteDataSourceImpl();
  late final ProductRepositoryImpl _repo = ProductRepositoryImpl(_remote);
  late final GetProducts _getAllProducts = GetProducts(_repo);

  bool _isLoading = true;
  List<Product> _allVisibleProducts = [];
  List<Product> _visibleProducts = [];
  String _searchQuery = '';

  int get pageCount => (_visibleProducts.length / itemsPerPage).ceil().clamp(1, 9999);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        _allVisibleProducts = visible;
        _applySearch();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _visibleProducts = _allVisibleProducts;
        currentPage = 0;
      });
      return;
    }

    final lowerQuery = _searchQuery.toLowerCase();
    final filtered = _allVisibleProducts.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          (product.shortDescription.toLowerCase().contains(lowerQuery));
    }).toList();

    setState(() {
      _visibleProducts = filtered;
      currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, _visibleProducts.length);
    final visibleCount = end - start;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Search Bar
        SliverToBoxAdapter(
          child: _buildSearchBar(),
        ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _applySearch();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applySearch();
          });
        },
      ),
    );
  }
}

// Removed old mock tile widget


