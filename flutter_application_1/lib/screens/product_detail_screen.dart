import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product_detail/product_info_card.dart';
import '../widgets/product_detail/product_qr_card.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProductInfoCard(product: product),
          const SizedBox(height: 14),
          ProductQrCard(productId: product.id),
        ],
      ),
    );
  }
}
