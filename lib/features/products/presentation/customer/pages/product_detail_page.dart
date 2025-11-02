import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/buy_now_sheet.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.title,
    required this.price,
    this.brand = '',
    this.description,
    this.imageUrls = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = false,
    this.categoryId,
    this.quantity = 0,
    this.shortDescription,
    this.createdAt,
    this.updatedAt,
  });

  final String productId;
  final String title;
  final num price;
  final String brand;
  final String? description;
  final String? shortDescription;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final String? categoryId;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ProductImageCarousel(imageUrls: images),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    if (widget.categoryId != null && widget.categoryId!.isNotEmpty)
                      Text(
                        widget.categoryId!.toUpperCase(),
                        style: AppTextStyles.text11.copyWith(
                          color: AppColors.placeholder,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (widget.categoryId != null && widget.categoryId!.isNotEmpty)
                      const SizedBox(height: 8),
                    // Product Name
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Price
                    Text(
                      '${NumberFormat.decimalPattern('vi_VN').format(widget.price)} VND',
                      style: AppTextStyles.headline2.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    // Short Description
                    if (widget.shortDescription != null && widget.shortDescription!.isNotEmpty) ...[
                      Text(
                        'Mô tả ngắn',
                        style: AppTextStyles.text16.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text.withOpacity(0.87),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.shortDescription!,
                        style: AppTextStyles.text14.copyWith(
                          color: AppColors.text.withOpacity(0.87),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Long Description
                    Text(
                      'Mô tả chi tiết',
                      style: AppTextStyles.text16.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text.withOpacity(0.87),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description ?? 'Không có mô tả',
                      style: AppTextStyles.text14.copyWith(
                        color: AppColors.text.withOpacity(0.87),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    // Additional Info
                    _buildInfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Số lượng tồn kho',
                      value: widget.quantity.toString(),
                      color: widget.quantity > 0 ? AppColors.success : AppColors.saleHot,
                    ),
                    const SizedBox(height: 12),
                    if (widget.createdAt != null)
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Ngày tạo',
                        value: DateFormat('dd/MM/yyyy').format(widget.createdAt!),
                      ),
                    if (widget.createdAt != null) const SizedBox(height: 12),
                    if (widget.updatedAt != null)
                      _buildInfoRow(
                        icon: Icons.update_outlined,
                        label: 'Cập nhật lần cuối',
                        value: DateFormat('dd/MM/yyyy HH:mm').format(widget.updatedAt!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${NumberFormat.decimalPattern('vi_VN').format(widget.price)} VND',
                        style: AppTextStyles.headline3.copyWith(color: AppColors.white, fontWeight: FontWeight.w800),
                      ),
                      Text('Đơn giá', style: AppTextStyles.text11.copyWith(color: AppColors.white.withOpacity(0.7))),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) => BuyNowSheet(
                        productId: widget.productId,
                        title: widget.title,
                        unitPrice: widget.price.toDouble(),
                      ),
                    );
                  },
                  child: Text('Mua ngay', style: AppTextStyles.text14.copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.placeholder),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTextStyles.text14.copyWith(
            color: AppColors.placeholder,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.text14.copyWith(
              color: color ?? AppColors.text.withOpacity(0.87),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
