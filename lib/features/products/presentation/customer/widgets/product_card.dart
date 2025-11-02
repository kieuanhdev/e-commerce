import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    this.imageUrl,
    this.onTap,
    this.padding,
    this.backgroundColor,
    required this.helperText,
    required this.title,
    required this.description,
    required this.price,
  });

  final String? imageUrl;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  final String helperText;
  final String title;
  final String description;
  final num price;

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(20);
    final imageRadius = BorderRadius.circular(16);
    final priceText = NumberFormat.decimalPattern('vi_VN').format(price);

    return Material(
      color: backgroundColor ?? AppColors.placeholder,
      borderRadius: cardRadius,
      child: InkWell(
        borderRadius: cardRadius,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 160.0;
            final imageHeight = width * 0.55;
            return Padding(
              padding: padding ?? const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: imageRadius,
                    child: _buildImagePlaceholder(imageHeight),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    helperText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text11.copyWith(
                      color: AppColors.placeholder,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text16.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text14.copyWith(
                      color: AppColors.text.withOpacity(0.87),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$priceText VND',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text14.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.center,
        color: AppColors.placeholder,
        child: Text(
          'ảnh',
          style: AppTextStyles.text14.copyWith(
            color: AppColors.white,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, _, __) => Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.center,
        color: AppColors.placeholder,
        child: const Text(
          'ảnh',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}


