import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../common/section_card.dart';
import '../product/product_status_chip.dart';

class ProductInfoCard extends StatelessWidget {
  final Product product;

  const ProductInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(product.name, style: Theme.of(context).textTheme.titleLarge)),
              ProductStatusChip(isAvailable: product.isAvailable),
            ],
          ),
          const SizedBox(height: 10),
          Text(product.description),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.image.startsWith('/')
                ? Image.file(File(product.image), height: 180, width: double.infinity, fit: BoxFit.cover)
                : Image.asset(product.image, height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}
