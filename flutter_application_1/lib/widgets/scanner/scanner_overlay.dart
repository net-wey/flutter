import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  final String? lastCode;

  const ScannerOverlay({super.key, this.lastCode});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
        if (lastCode != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: Text('Последний код: $lastCode', style: const TextStyle(color: Colors.white)),
            ),
          ),
      ],
    );
  }
}
