import 'dart:async';

import 'package:flutter/material.dart';
import 'package:e_commerce/core/theme/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    this.imageUrls,
    this.height = 180,
    this.interval = const Duration(seconds: 5),
    this.title,
  });

  final List<String>? imageUrls;
  final double height;
  final Duration interval;
  final String? title;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller;
  late Timer _timer;
  int _currentIndex = 0;

  List<String> get _images => widget.imageUrls ?? const [
        'images/banner/banner1.jpg',
        'images/banner/banner2.jpg',
        'images/banner/banner3.jpg',
      ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(widget.interval, (_) => _nextPage());
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!mounted) return;
    final next = (_currentIndex + 1) % _images.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final url = _images[index];
                return _BannerImage(url: url);
              },
            ),
          
            Positioned(
              right: 16,
              bottom: 16,
              child: _BannerIndicator(
                length: _images.length,
                activeIndex: _currentIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    // Placeholder grey panel if url is empty
    if (url.isEmpty) {
      return Container(color: AppColors.placeholder);
    }

    // Load from assets only
    return Image.asset(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.placeholder,
      ),
    );
  }
}

class _BannerIndicator extends StatelessWidget {
  const _BannerIndicator({
    required this.length,
    required this.activeIndex,
  });

  final int length;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 6),
          width: 3,
          height: isActive ? 28 : 14,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(isActive ? 1 : 0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}


