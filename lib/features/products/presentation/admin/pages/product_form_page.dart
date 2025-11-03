import 'dart:typed_data';

import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';
import 'package:e_commerce/core/theme/app_sizes.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/usecases/add_product.dart';
import 'package:e_commerce/features/products/domain/usecases/update_product.dart';
import 'package:e_commerce/features/products/domain/usecases/upload_product_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  final AddProduct addUseCase;
  final UpdateProduct updateUseCase;
  final UploadProductImage uploadImageUseCase;

  const ProductFormPage({
    super.key,
    this.product,
    required this.addUseCase,
    required this.updateUseCase,
    required this.uploadImageUseCase,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late String _name;
  late double _price;
  late int _quantity;
  bool _isVisible = true;
  int _lowStockThreshold = 10;
  String? _imageUrl;
  String _shortDescription = '';
  String _longDescription = '';
  String? _categoryId;

  XFile? _selectedImage;
  Uint8List? _previewImageBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _price = widget.product?.price ?? 0;
    _quantity = widget.product?.quantity ?? 0;
    _isVisible = widget.product?.isVisible ?? true;
    _lowStockThreshold = widget.product?.lowStockThreshold ?? 10;
    _imageUrl = widget.product?.imageUrl;
    _shortDescription = widget.product?.shortDescription ?? '';
    _longDescription = widget.product?.longDescription ?? '';
    _categoryId = widget.product?.categoryId;
  }

  Future<void> _pickImage() async {
    try {
      // Hiển thị dialog để chọn nguồn ảnh
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chọn ảnh từ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Chọn ảnh
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        // Đọc bytes từ file để preview
        final imageBytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _previewImageBytes = imageBytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload ảnh nếu có ảnh mới được chọn
      String? uploadedImageUrl = _imageUrl;
      if (_selectedImage != null) {
        uploadedImageUrl = await widget.uploadImageUseCase(_selectedImage!);
      }

      final newProduct = Product(
        id: widget.product?.id ?? '',
        name: _name,
        price: _price,
        quantity: _quantity,
        isVisible: _isVisible,
        lowStockThreshold: _lowStockThreshold,
        imageUrl: uploadedImageUrl,
        shortDescription: _shortDescription,
        longDescription: _longDescription,
        categoryId: _categoryId,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product == null) {
        await widget.addUseCase(newProduct);
      } else {
        await widget.updateUseCase(newProduct);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? 'Đã thêm sản phẩm thành công 🎉'
                  : 'Đã cập nhật sản phẩm thành công ✅',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
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
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD, vertical: AppSizes.spacingMD),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Chỉnh sửa Sản phẩm' : 'Thêm Sản phẩm',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              TextFormField(
                initialValue: _name,
                decoration: _inputDecoration('Tên sản phẩm', icon: Icons.label),
                validator: (v) => v!.isEmpty ? 'Nhập tên sản phẩm' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: AppSizes.spacingMD),
              TextFormField(
                initialValue: _shortDescription,
                decoration: _inputDecoration(
                  'Mô tả ngắn',
                  icon: Icons.notes,
                ),
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nhập mô tả ngắn'
                    : null,
                onSaved: (v) => _shortDescription = v!.trim(),
              ),
              const SizedBox(height: AppSizes.spacingMD),
              TextFormField(
                initialValue: _longDescription,
                decoration: _inputDecoration(
                  'Mô tả chi tiết',
                  icon: Icons.description,
                ),
                maxLines: 4,
                onSaved: (v) => _longDescription = v!.trim(),
              ),
              const SizedBox(height: AppSizes.spacingMD),
              TextFormField(
                initialValue: _categoryId ?? '',
                decoration: _inputDecoration(
                  'ID Danh mục',
                  icon: Icons.category,
                ),
                onSaved: (v) {
                  final val = (v ?? '').trim();
                  _categoryId = val.isEmpty ? null : val;
                },
              ),
              const SizedBox(height: AppSizes.spacingMD),
              TextFormField(
                initialValue: _price == 0 ? '' : _price.toString(),
                decoration: _inputDecoration(
                  'Giá',
                  icon: Icons.monetization_on,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Nhập giá' : null,
                onSaved: (v) => _price = double.parse(v!),
              ),
              const SizedBox(height: AppSizes.spacingMD),
              TextFormField(
                initialValue: _quantity == 0 ? '' : _quantity.toString(),
                decoration: _inputDecoration('Số lượng', icon: Icons.numbers),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Nhập số lượng' : null,
                onSaved: (v) => _quantity = int.parse(v!),
              ),
              const SizedBox(height: AppSizes.spacingMD),
              SwitchListTile(
                title: const Text('Hiển thị sản phẩm'),
                value: _isVisible,
                onChanged: (v) => setState(() => _isVisible = v),
              ),
              const SizedBox(height: AppSizes.spacingSM),
              TextFormField(
                initialValue: _lowStockThreshold.toString(),
                decoration: _inputDecoration(
                  'Ngưỡng cảnh báo tồn kho thấp',
                  icon: Icons.warning,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final val = int.tryParse((v ?? '').trim());
                  if (val == null || val <= 0) return 'Nhập số dương';
                  return null;
                },
                onSaved: (v) =>
                    _lowStockThreshold = int.tryParse(v ?? '') ?? 10,
              ),
              const SizedBox(height: AppSizes.spacingLG),
              // Image section
              Text(
                'Ảnh sản phẩm',
                style: AppTextStyles.text14.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.spacingMD),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(color: AppColors.placeholder),
                        ),
                        child: _previewImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                                child: Image.memory(
                                  _previewImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (_imageUrl != null && _imageUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                                child: Image.network(
                                  _imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image,
                                        size: 64,
                                        color: AppColors.placeholder,
                                      ),
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 64,
                                    color: AppColors.placeholder,
                                  ),
                                  SizedBox(height: AppSizes.spacingSM),
                                  Text(
                                    'Chọn ảnh sản phẩm',
                                    style: TextStyle(color: AppColors.placeholder),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSM),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text(
                        _previewImageBytes != null ||
                                (_imageUrl != null && _imageUrl!.isNotEmpty)
                            ? 'Thay đổi ảnh'
                            : 'Chọn ảnh',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _save,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : Icon(
                        isEdit ? Icons.save_rounded : Icons.add_circle_outline,
                      ),
                label: Text(
                  _isUploading
                      ? 'Đang xử lý...'
                      : (isEdit ? 'Cập nhật Sản phẩm' : 'Thêm Sản phẩm'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMD),
                  textStyle: AppTextStyles.text16.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
