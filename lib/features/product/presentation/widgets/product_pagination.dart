import 'package:flutter/material.dart';

class ProductPagination extends StatelessWidget {
  const ProductPagination({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.onPageSelected,
  });

  final int pageCount;
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 0 ? () => onPageSelected(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ...List.generate(pageCount, (i) {
          final isActive = i == currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () => onPageSelected(i),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(36, 36),
                side: BorderSide(color: isActive ? const Color(0xFF23B39B) : Colors.grey.shade300),
                foregroundColor: isActive ? const Color(0xFF23B39B) : Colors.black87,
              ),
              child: Text('${i + 1}'),
            ),
          );
        }),
        IconButton(
          onPressed: currentPage < pageCount - 1 ? () => onPageSelected(currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}


