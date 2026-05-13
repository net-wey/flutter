import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';
import 'scanner_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final products = state.products;

    return Scaffold(
      appBar: AppBar(
        title: Text('Склад (${state.currentUser?.name ?? ''})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScannerScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AppState>().logout(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.inventory_2, size: 40, color: Colors.blueGrey),
              title: Text(product.name),
              subtitle: Text(product.description),
              trailing: Icon(
                product.isAvailable ? Icons.check_circle : Icons.cancel,
                color: product.isAvailable ? Colors.green : Colors.red,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: state.canCreateProducts
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddProductScreen()),
              ),
            )
          : null,
    );
  }
}
