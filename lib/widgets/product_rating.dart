import 'package:flutter/material.dart';

class ProductRating extends StatelessWidget {
  const ProductRating({super.key, required this.rating, this.size = 14});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(_iconFor(star), color: const Color(0xFFFFB300), size: size),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontSize: size - 1, color: const Color(0xFF666666)),
        ),
      ],
    );
  }

  IconData _iconFor(int star) {
    if (rating >= star) return Icons.star;
    if (rating >= star - 0.5) return Icons.star_half;
    return Icons.star_border;
  }
}
