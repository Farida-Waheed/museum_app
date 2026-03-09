import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating; // 0-5
  final void Function(int value)? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final value = i + 1;
        final filled = value <= rating;

        return IconButton(
          onPressed: onChanged == null ? null : () => onChanged!(value),
          icon: Icon(filled ? Icons.star : Icons.star_border),
          iconSize: size,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: '$value stars',
        );
      }),
    );
  }
}
