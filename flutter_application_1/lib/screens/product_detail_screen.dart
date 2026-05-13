import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/product.dart';
import 'dart:io';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Описание: ${product.description}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Статус: ${product.isAvailable ? "Свободен" : "Занят"}', 
                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (product.image.startsWith('/'))
              Image.file(
                File(product.image),
                height: 150,
                width: double.infinity,
                fit: BoxFit.contain, 
              )
            else 
              Image.asset(product.image),
            const SizedBox(height: 30),
            const Center(child: Text('QR-код товара:', style: TextStyle(fontSize: 16))),
            const SizedBox(height: 10),
            Center(
              child: QrImageView(
                data: product.id, // Вшиваем ID товара в QR
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}