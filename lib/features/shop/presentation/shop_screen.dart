import 'package:e_commerce/features/products/data/datasources/product_remote_datasource.dart';
import 'package:e_commerce/features/products/data/repositories/product_repository_impl.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/usecases/get_products.dart';
import 'package:e_commerce/features/products/presentation/customer/pages/product_detail_page.dart';
import 'package:e_commerce/features/products/presentation/customer/widgets/product_card.dart';
import 'package:e_commerce/features/products/presentation/customer/widgets/product_grid_sliver.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late final ProductRemoteDataSource _remote = ProductRemoteDataSourceImpl();
  late final ProductRepositoryImpl _repo = ProductRepositoryImpl(_remote);
  late final GetProducts _getAllProducts = GetProducts(_repo);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  String _searchQuery = '';
  String? _selectedCategory;
  String _sortOption = 'Mặc định'; // Mặc định, Giá tăng dần, Giá giảm dần

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
        _allProducts = visible;
        _applyFilters();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<Product> filtered = List.from(_allProducts);

    // Filter by category
    if (_selectedCategory != null && _selectedCategory != 'Tất cả') {
      filtered = filtered
          .where((p) => p.categoryId == _selectedCategory)
          .toList();
    }

    // Search by name
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(lowerQuery) ||
              (p.shortDescription.toLowerCase().contains(lowerQuery)))
          .toList();
    }

    // Sort
    if (_sortOption == 'Giá tăng dần') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'Giá giảm dần') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  List<String> _getCategories() {
    final categories = _allProducts
        .map((p) => p.categoryId)
        .where((c) => c != null && c.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return ['Tất cả', ...categories.cast<String>()];
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                      _applyFilters();
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
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Category Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory ?? 'Tất cả',
              decoration: InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                prefixIcon: const Icon(Icons.category, size: 20),
              ),
              items: _getCategories().map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value == 'Tất cả' ? null : value;
                  _applyFilters();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // Sort Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _sortOption,
              decoration: InputDecoration(
                labelText: 'Sắp xếp',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                prefixIcon: const Icon(Icons.sort, size: 20),
              ),
              items: const [
                DropdownMenuItem(value: 'Mặc định', child: Text('Mặc định')),
                DropdownMenuItem(
                    value: 'Giá tăng dần', child: Text('Giá tăng dần')),
                DropdownMenuItem(
                    value: 'Giá giảm dần', child: Text('Giá giảm dần')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortOption = value;
                    _applyFilters();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa hàng'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          // Filter Bar
          _buildFilterBar(),
          // Search results info
          if (_searchQuery.isNotEmpty || _selectedCategory != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildFilterInfo(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedCategory = null;
                        _sortOption = 'Mặc định';
                        _applyFilters();
                      });
                    },
                    child: const Text('Xóa bộ lọc'),
                  ),
                ],
              ),
            ),
          // Products List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy sản phẩm nào',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          ProductGridSliver(
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return ProductCard(
                                imageUrl: product.imageUrl,
                                helperText: product.categoryId ?? 'Sản phẩm',
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
                                        brand: product.categoryId ?? 'Brand',
                                        description: product.longDescription,
                                        imageUrls: product.imageUrl != null &&
                                                product.imageUrl!.isNotEmpty
                                            ? [product.imageUrl!]
                                            : const [],
                                        inStock: product.quantity > 0,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 16),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  String _buildFilterInfo() {
    final parts = <String>[];
    if (_searchQuery.isNotEmpty) {
      parts.add('Tìm: "$_searchQuery"');
    }
    if (_selectedCategory != null) {
      parts.add('Danh mục: $_selectedCategory');
    }
    parts.add('Sắp xếp: $_sortOption');
    parts.add('(${_filteredProducts.length} sản phẩm)');
    return parts.join(' • ');
  }
}
