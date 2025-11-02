import 'package:flutter/material.dart';
import 'package:e_commerce/features/products/data/datasources/product_remote_datasource.dart';
import 'package:e_commerce/features/products/data/repositories/product_repository_impl.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/usecases/get_products.dart';
import 'package:e_commerce/features/products/domain/services/product_cache_service.dart';

import '../widgets/product_card.dart';
import '../../../../home/presentation/widgets/bannner.dart';
import '../widgets/product_popular_section.dart';
import '../widgets/product_grid_sliver.dart';
import '../widgets/product_pagination.dart' as pagination_widget;
import 'product_detail_page.dart';

class ProductListBody extends StatefulWidget {
  final String searchQuery;
  
  const ProductListBody({super.key, this.searchQuery = ''});

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
  final _cacheService = ProductCacheService.instance;

  bool _isLoading = true;
  List<Product> _allVisibleProducts = [];
  List<Product> _visibleProducts = [];

  int get pageCount => (_visibleProducts.length / itemsPerPage).ceil().clamp(1, 9999);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(ProductListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _applySearch();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool forceRefresh = false}) async {
    // Nếu có cache và không force refresh, dùng cache ngay
    if (!forceRefresh && _cacheService.isCacheValid()) {
      final cached = _cacheService.getCachedProducts();
      if (cached != null) {
        final visible = cached.where((p) => p.isVisible == true).toList();
        if (mounted) {
          setState(() {
            _allVisibleProducts = visible;
            _applySearch();
            _isLoading = false;
          });
        }
        // Chỉ refresh background nếu cache đã > 50% thời gian (tức > 2.5 phút)
        // Tránh refresh quá nhiều khi user chuyển màn hình liên tục
        final cacheAge = _cacheService.lastFetchTime != null 
            ? DateTime.now().difference(_cacheService.lastFetchTime!)
            : const Duration(minutes: 10);
        if (cacheAge.inMinutes >= 2) {
          _cacheService.getProducts(_getAllProducts, forceRefresh: true).then((items) {
            final visible = items.where((p) => p.isVisible == true).toList();
            if (mounted) {
              setState(() {
                _allVisibleProducts = visible;
                _applySearch();
              });
            }
          }).catchError((e) {
            print('Background refresh failed: $e');
          });
        }
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });
    try {
      // Dùng cache service để tránh load lại nếu đã có cache
      final items = await _cacheService.getProducts(_getAllProducts, forceRefresh: forceRefresh);
      // Chỉ hiển thị sản phẩm đang bật isVisible
      final visible = items.where((p) => p.isVisible == true).toList();
      if (mounted) {
        setState(() {
          _allVisibleProducts = visible;
          _applySearch();
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        setState(() {
          _allVisibleProducts = [];
          _visibleProducts = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách sản phẩm: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applySearch() {
    final searchQuery = widget.searchQuery;
    if (searchQuery.isEmpty) {
      setState(() {
        _visibleProducts = _allVisibleProducts;
        currentPage = 0;
      });
      return;
    }

    final lowerQuery = searchQuery.toLowerCase();
    final filtered = _allVisibleProducts.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.shortDescription.toLowerCase().contains(lowerQuery);
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
                        categoryId: product.categoryId,
                        quantity: product.quantity,
                        shortDescription: product.shortDescription,
                        createdAt: product.createdAt,
                        updatedAt: product.updatedAt,
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
