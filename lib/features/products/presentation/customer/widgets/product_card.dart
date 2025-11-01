import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final theme = Theme.of(context);
    final cardRadius = BorderRadius.circular(20);
    final imageRadius = BorderRadius.circular(16);
    final priceText = NumberFormat.decimalPattern('vi_VN').format(price);

    return Material(
      color: backgroundColor ?? Colors.grey.shade300,
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$priceText VND',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF23B39B),
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
        color: const Color(0xFF8E4E4E),
        child: const Text(
          'ảnh',
          style: TextStyle(color: Colors.white, fontSize: 20),
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
        color: const Color(0xFF8E4E4E),
        child: const Text(
          'ảnh',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}


