import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(Icons.star, color: Colors.amber, size: size);
            } else if (index < rating && rating % 1 != 0) {
              return Icon(Icons.star_half, color: Colors.amber, size: size);
            } else {
              return Icon(Icons.star_border, color: Colors.amber, size: size);
            }
          }),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: size * 0.8, color: Colors.grey),
          ),
        ]
      ],
    );
  }
}
