import 'package:flutter/material.dart';

class ProductGridSliver extends StatelessWidget {
  const ProductGridSliver({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.childAspectRatio = 0.78,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    // Responsive columns based on screen width
    // Mobile: 2 columns, Tablet/Web: 4 columns
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => itemBuilder(context, index),
          childCount: itemCount,
        ),
      ),
    );
  }
}


