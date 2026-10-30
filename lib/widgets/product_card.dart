import 'package:flutter/material.dart';
import 'package:proudcut_listing_app/models/product_model.dart';
import 'package:proudcut_listing_app/widgets/product_rating.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final ProductModel product;
  final VoidCallback? onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final lifted = _hovered || _pressed;

    return AnimatedScale(
      scale: _pressed ? 0.98 : (_hovered ? 1.02 : 1),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: lifted ? const Color(0xFF90CAF9) : const Color(0xFFE8E8E8),
          ),
          boxShadow: [
            BoxShadow(
              color: lifted ? const Color(0x330D47A1) : const Color(0x1A000000),
              blurRadius: lifted ? 16 : 10,
              offset: Offset(0, lifted ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            mouseCursor: SystemMouseCursors.click,
            hoverColor: const Color(0x143196F3),
            highlightColor: const Color(0x1A2196F3),
            splashColor: const Color(0x332196F3),
            onHover: (hovered) => setState(() => _hovered = hovered),
            onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
            onTap: widget.onTap ?? () {},
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ProductImage(imageUrl: widget.product.imageUrl),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ProductRating(rating: widget.product.rating),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _ProductImageBackground()),
          if (imageUrl.isEmpty)
            const Center(child: _ProductImageFallback())
          else
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                gaplessPlayback: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const _ProductImageFallback();
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductImageBackground extends StatelessWidget {
  const _ProductImageBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F9FC), Color(0xFFE4EBF5)],
        ),
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.image_outlined, color: Colors.grey);
  }
}
