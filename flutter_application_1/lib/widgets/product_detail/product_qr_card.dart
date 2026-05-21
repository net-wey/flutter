import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../common/section_card.dart';

class ProductQrCard extends StatelessWidget {
  final String productId;

  const ProductQrCard({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          const Text('QR-код товара', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          QrImageView(data: productId, version: QrVersions.auto, size: 220),
        ],
      ),
    );
  }
}
