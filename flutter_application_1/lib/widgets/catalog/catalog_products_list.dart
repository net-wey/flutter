import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../common/empty_state.dart';
import '../product/product_list_item.dart';

class CatalogProductsList extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onTapProduct;

  const CatalogProductsList({
    super.key,
    required this.products,
    required this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Пока нет товаров',
        subtitle: 'Добавь первый товар, чтобы начать учет на складе.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 90),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListItem(product: product, onTap: () => onTapProduct(product));
      },
    );
  }
}
