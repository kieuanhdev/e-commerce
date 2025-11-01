import 'package:e_commerce/features/products/data/datasources/product_remote_datasource.dart';
import 'package:e_commerce/features/products/data/repositories/product_repository_impl.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/usecases/add_product.dart';
import 'package:e_commerce/features/products/domain/usecases/delete_product.dart';
import 'package:e_commerce/features/products/domain/usecases/get_products.dart';
import 'package:e_commerce/features/products/domain/usecases/update_product.dart';
import 'package:e_commerce/features/products/presentation/admin/pages/product_form_page.dart';
import 'package:flutter/material.dart';


class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final _remote = ProductRemoteDataSourceImpl();
  late final _repo = ProductRepositoryImpl(_remote);

  late final _getAllProducts = GetProducts(_repo);
  late final _addProduct = AddProduct(_repo);
  late final _updateProduct = UpdateProduct(_repo);
  late final _deleteProduct = DeleteProduct(_repo);

  List<Product> _products = [];
  List<Product> _allProducts = [];

  String? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _getAllProducts();
    setState(() {
      _allProducts = products;
      _products = products;
    });
  }

  Future<void> _delete(String id) async {
    await _deleteProduct(id);
    await _loadProducts();
  }

  Future<void> _openForm([Product? product]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          product: product,
          addUseCase: _addProduct,
          updateUseCase: _updateProduct,
        ),
      ),
    );
    if (result == true) _loadProducts();
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Product> filtered = _allProducts;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory != 'All') {
      filtered = filtered
          .where((p) => p.categoryId == _selectedCategory)
          .toList();
    }

    // Search by name
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    setState(() {
      _products = filtered;
    });
  }

  Future<void> _toggleVisibility(Product product) async {
    final updated = Product(
      id: product.id,
      name: product.name,
      price: product.price,
      quantity: product.quantity,
      isVisible: !product.isVisible,
      lowStockThreshold: product.lowStockThreshold,
      imageUrl: product.imageUrl,
      shortDescription: product.shortDescription,
      longDescription: product.longDescription,
      categoryId: product.categoryId,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );
    await _updateProduct(updated);
    setState(() {
      final idx = _products.indexWhere((p) => p.id == product.id);
      if (idx != -1) {
        _products[idx] = updated;
      }
      final allIdx = _allProducts.indexWhere((p) => p.id == product.id);
      if (allIdx != -1) {
        _allProducts[allIdx] = updated;
      }
    });
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: TextField(
                decoration: _inputDecoration(
                  'Search products',
                  icon: Icons.search,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Filter Dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: DropdownButtonFormField<String>(
                decoration: _inputDecoration(
                  'Filter by category',
                  icon: Icons.category,
                ),
                initialValue: _selectedCategory,
                items: [
                  const DropdownMenuItem<String>(
                    value: 'All',
                    child: Text('All Categories'),
                  ),
                  ..._allProducts
                      .map((p) => p.categoryId)
                      .toSet()
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category ?? ''),
                        ),
                      ),
                ],
                onChanged: (value) => _filterByCategory(value),
              ),
            ),

            Expanded(
              child: _products.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found 💤',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        final bool isHidden = !p.isVisible;
                        return Card(
                          color: isHidden ? Colors.grey[100] : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 3,
                          child: ListTile(
                            leading: SizedBox(
                              width: 120,
                              child: AspectRatio(
                                aspectRatio: 3 / 4, // 3x4
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ColorFiltered(
                                        colorFilter: isHidden
                                            ? const ColorFilter.mode(Colors.black26, BlendMode.darken)
                                            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                                        child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                                            ? Image.network(
                                                p.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                              ),
                                      ),
                                    ),
                                    if (isHidden)
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          margin: const EdgeInsets.all(6),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'ĐÃ ẨN',
                                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            title: Text(
                              p.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isHidden ? Colors.grey : null,
                                decoration: isHidden ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isHidden)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      'Sản phẩm này đang được ẩn',
                                      style: TextStyle(color: Colors.orange[800], fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                Text(
                                  'Category: ${p.categoryId ?? '-'}',
                                  style: TextStyle(color: Colors.grey.shade700, height: 1.3),
                                ),
                                Text(
                                  p.shortDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isHidden ? Colors.grey : Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  'Price: \$${p.price.toStringAsFixed(2)} | Qty: ${p.quantity}',
                                  style: TextStyle(color: Colors.grey.shade800, height: 1.3),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    p.isVisible ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.orange,
                                  ),
                                  tooltip: p.isVisible ? 'Ẩn sản phẩm' : 'Hiển thị sản phẩm',
                                  onPressed: () => _toggleVisibility(p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.blueAccent,
                                  ),
                                  tooltip: 'Edit',
                                  onPressed: () => _openForm(p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: 'Delete',
                                  onPressed: () => _delete(p.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
