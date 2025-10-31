import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/usecases/add_product.dart';
import 'package:e_commerce/features/products/domain/usecases/update_product.dart';
import 'package:flutter/material.dart';


class ProductFormPage extends StatefulWidget {
  final Product? product;
  final AddProduct addUseCase;
  final UpdateProduct updateUseCase;

  const ProductFormPage({
    super.key,
    this.product,
    required this.addUseCase,
    required this.updateUseCase,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late double _price;
  late int _quantity;
  bool _isVisible = true;
  int _lowStockThreshold = 10;
  String? _imageUrl;
  String _shortDescription = '';
  String _longDescription = '';
  String? _categoryId;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newProduct = Product(
      id: widget.product?.id ?? '',
      name: _name,
      price: _price,
      quantity: _quantity,
      isVisible: _isVisible,
      lowStockThreshold: _lowStockThreshold,
      imageUrl: _imageUrl,
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
                ? 'Product added successfully 🎉'
                : 'Product updated successfully ✅',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              TextFormField(
                initialValue: _name,
                decoration: _inputDecoration('Product Name', icon: Icons.label),
                validator: (v) => v!.isEmpty ? 'Enter product name' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _shortDescription,
                decoration: _inputDecoration(
                  'Short Description',
                  icon: Icons.notes,
                ),
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter short description'
                    : null,
                onSaved: (v) => _shortDescription = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _longDescription,
                decoration: _inputDecoration(
                  'Long Description',
                  icon: Icons.description,
                ),
                maxLines: 4,
                onSaved: (v) => _longDescription = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _categoryId ?? '',
                decoration: _inputDecoration('Category ID', icon: Icons.category),
                onSaved: (v) {
                  final val = (v ?? '').trim();
                  _categoryId = val.isEmpty ? null : val;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price == 0 ? '' : _price.toString(),
                decoration: _inputDecoration(
                  'Price',
                  icon: Icons.monetization_on,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter price' : null,
                onSaved: (v) => _price = double.parse(v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _quantity == 0 ? '' : _quantity.toString(),
                decoration: _inputDecoration('Quantity', icon: Icons.numbers),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter quantity' : null,
                onSaved: (v) => _quantity = int.parse(v!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Visible'),
                value: _isVisible,
                onChanged: (v) => setState(() => _isVisible = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _lowStockThreshold.toString(),
                decoration: _inputDecoration('Low stock threshold', icon: Icons.warning),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final val = int.tryParse((v ?? '').trim());
                  if (val == null || val <= 0) return 'Enter a positive number';
                  return null;
                },
                onSaved: (v) => _lowStockThreshold = int.tryParse(v ?? '') ?? 10,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _imageUrl ?? '',
                decoration: _inputDecoration('Image URL', icon: Icons.image),
                validator: (v) {
                  final val = (v ?? '').trim();
                  if (val.isEmpty) return null; // optional
                  final uri = Uri.tryParse(val);
                  final isHttp = uri != null && (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
                  return isHttp ? null : 'Please enter a valid http/https URL';
                },
                onSaved: (v) {
                  final val = (v ?? '').trim();
                  _imageUrl = val.isEmpty ? null : val;
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(
                  isEdit ? Icons.save_rounded : Icons.add_circle_outline,
                ),
                label: Text(isEdit ? 'Update Product' : 'Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
