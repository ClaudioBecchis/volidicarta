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
    return Semantics(
      label: '$rating stelle su 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          return Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < rating ? c : Colors.grey.shade300,
          );
        }),
      ),
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
    return Semantics(
      label: 'Seleziona valutazione: $rating stelle su 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final star = i + 1;
          return Semantics(
            label: '$star ${star == 1 ? 'stella' : 'stelle'}',
            button: true,
            selected: star == rating,
            child: GestureDetector(
              onTap: () => onRatingChanged(star),
              child: SizedBox(
                width: size.clamp(48, double.infinity),
                height: size.clamp(48, double.infinity),
                child: Center(
                  child: Icon(
                    star <= rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: size,
                    color: star <= rating
                        ? const Color(0xFFFFB300)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
