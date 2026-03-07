import 'package:flutter/material.dart';

class StarRatingDisplay extends StatelessWidget {
  final int rating;
  final double size;
  final Color? color;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFFFB300);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: i < rating ? c : Colors.grey.shade300,
        );
      }),
    );
  }
}

class StarRatingPicker extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;

  const StarRatingPicker({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => onRatingChanged(star),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: star <= rating
                  ? const Color(0xFFFFB300)
                  : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }
}
