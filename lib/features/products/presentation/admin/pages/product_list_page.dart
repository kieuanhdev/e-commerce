import 'package:e_commerce/di.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';
import 'package:e_commerce/core/theme/app_sizes.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/usecases/add_product.dart';
import 'package:e_commerce/features/products/domain/usecases/delete_product.dart';
import 'package:e_commerce/features/products/domain/usecases/get_products.dart';
import 'package:e_commerce/features/products/domain/usecases/update_product.dart';
import 'package:e_commerce/features/products/domain/usecases/upload_product_image.dart';
import 'package:e_commerce/features/products/presentation/admin/pages/product_form_page.dart';
import 'package:flutter/material.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final _getAllProducts = sl<GetProducts>();
  late final _addProduct = sl<AddProduct>();
  late final _updateProduct = sl<UpdateProduct>();
  late final _deleteProduct = sl<DeleteProduct>();
  late final _uploadProductImage = sl<UploadProductImage>();

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
          uploadImageUseCase: _uploadProductImage,
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
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.placeholder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.placeholder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sản phẩm'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        label: const Text('Thêm sản phẩm'),
        icon: const Icon(Icons.add_rounded),
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.paddingMD, AppSizes.paddingMD, AppSizes.paddingMD, AppSizes.spacingXS),
              child: TextField(
                decoration: _inputDecoration(
                  'Tìm kiếm sản phẩm...',
                  icon: Icons.search,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Filter Dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.paddingMD, AppSizes.spacingXS, AppSizes.paddingMD, AppSizes.spacingMD),
              child: DropdownButtonFormField<String>(
                decoration: _inputDecoration(
                  'Lọc theo danh mục',
                  icon: Icons.category,
                ),
                initialValue: _selectedCategory,
                items: [
                  const DropdownMenuItem<String>(
                    value: 'All',
                    child: Text('Tất cả danh mục'),
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
                  ? Center(
                      child: Text(
                        'Không tìm thấy sản phẩm nào 💤',
                        style: AppTextStyles.text16.copyWith(color: AppColors.placeholder),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingMD,
                        vertical: AppSizes.spacingSM,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        final bool isHidden = !p.isVisible;
                        return Card(
                          color: isHidden ? AppColors.background : AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                          ),
                          elevation: AppSizes.cardElevation,
                          margin: const EdgeInsets.only(bottom: AppSizes.spacingMD),
                          child: ListTile(
                            leading: SizedBox(
                              width: 120,
                              child: AspectRatio(
                                aspectRatio: 3 / 4, // 3x4
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                      child: ColorFiltered(
                                        colorFilter: isHidden
                                            ? const ColorFilter.mode(
                                                Colors.black26,
                                                BlendMode.darken,
                                              )
                                            : const ColorFilter.mode(
                                                Colors.transparent,
                                                BlendMode.dst,
                                              ),
                                        child:
                                            (p.imageUrl != null &&
                                                p.imageUrl!.isNotEmpty)
                                            ? Image.network(
                                                p.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color: AppColors.background,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: AppColors.placeholder,
                                                      ),
                                                    ),
                                              )
                                            : Container(
                                                color: AppColors.background,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: AppColors.placeholder,
                                                ),
                                              ),
                                      ),
                                    ),
                                    if (isHidden)
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          margin: const EdgeInsets.all(AppSizes.spacingMD),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSizes.spacingSM,
                                            vertical: AppSizes.spacingXS,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              AppSizes.radiusXS,
                                            ),
                                          ),
                                          child: const Text(
                                            'ĐÃ ẨN',
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            title: Text(
                              p.name,
                              style: AppTextStyles.text16.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isHidden ? AppColors.placeholder : null,
                                decoration: isHidden
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
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
                                      style: AppTextStyles.text11.copyWith(
                                        color: Colors.orange[800],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                Text(
                                  'Danh mục: ${p.categoryId ?? '-'}',
                                  style: AppTextStyles.text14.copyWith(
                                    color: AppColors.placeholder,
                                    height: 1.3,
                                  ),
                                ),
                                Text(
                                  p.shortDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.text14.copyWith(
                                    color: isHidden
                                        ? AppColors.placeholder
                                        : AppColors.placeholder,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  'Giá: \$${p.price.toStringAsFixed(2)} | SL: ${p.quantity}',
                                  style: AppTextStyles.text14.copyWith(
                                    color: AppColors.placeholder,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    p.isVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.orange,
                                  ),
                                  tooltip: p.isVisible
                                      ? 'Ẩn sản phẩm'
                                      : 'Hiển thị sản phẩm',
                                  onPressed: () => _toggleVisibility(p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'Chỉnh sửa',
                                  onPressed: () => _openForm(p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: AppColors.error,
                                  ),
                                  tooltip: 'Xóa',
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
