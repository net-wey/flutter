import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/catalog/catalog_app_bar.dart';
import '../widgets/catalog/catalog_products_list.dart';
import '../widgets/common/loading_spinner_view.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';
import 'scanner_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().refreshProductsWithDelay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: CatalogAppBar(
        userName: state.currentUser?.name ?? '',
        onScan: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
        onLogout: () => context.read<AppState>().logout(),
      ),
      body: state.isProductsLoading
          ? const LoadingSpinnerView(caption: 'Загружаем товары...')
          : CatalogProductsList(
              products: state.products,
              onTapProduct: (product) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              ),
            ),
      floatingActionButton: state.canCreateProducts
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Товар'),
            )
          : null,
    );
  }
}
