import 'package:flutter/material.dart';

class ProductImageCarousel extends StatefulWidget {
  const ProductImageCarousel({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late final PageController _controller;
  int _index = 0;

  List<String> get _images => widget.imageUrls.isEmpty ? List.generate(3, (i) => '') : widget.imageUrls;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: _images.length,
              itemBuilder: (context, i) {
                final url = _images[i];
                if (url.isEmpty) {
                  return Container(color: Colors.grey.shade200);
                }
                return Image.network(url, fit: BoxFit.cover);
              },
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Row(
                children: List.generate(
                  _images.length,
                  (i) => Container(
                    margin: const EdgeInsets.only(left: 6),
                    width: i == _index ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index ? Colors.white : Colors.white70,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


