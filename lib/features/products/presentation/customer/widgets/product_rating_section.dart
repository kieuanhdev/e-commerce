import 'package:flutter/material.dart';

class ProductRatingSection extends StatelessWidget {
  const ProductRatingSection({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.distribution,
  });

  final double rating;
  final int reviewCount;
  final List<double> distribution; // from 5 to 1

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 4),
                    const Text('/5', style: TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Based on $reviewCount Reviews', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                _StarRow(rating: rating),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < 5; i++) ...[
                  Row(
                    children: [
                      Text('${5 - i} Star', style: const TextStyle(color: Colors.black54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: distribution[i].clamp(0.0, 1.0),
                            backgroundColor: const Color(0xFFE8EAEE),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.25 && (rating - full) < 0.75;
    final empty = 5 - full - (hasHalf ? 1 : 0);
    return Row(
      children: [
        for (int i = 0; i < full; i++) const Icon(Icons.star, color: Color(0xFFFFC107)),
        if (hasHalf) const Icon(Icons.star_half, color: Color(0xFFFFC107)),
        for (int i = 0; i < empty; i++) const Icon(Icons.star_border, color: Color(0xFFFFC107)),
      ],
    );
  }
}


