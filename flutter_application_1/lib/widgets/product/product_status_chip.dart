import 'package:flutter/material.dart';

class ProductStatusChip extends StatelessWidget {
  final bool isAvailable;

  const ProductStatusChip({super.key, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final text = isAvailable ? 'Доступен' : 'Занят';
    final icon = isAvailable ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
