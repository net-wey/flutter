import 'package:flutter/material.dart';

class CameraPermissionBlock extends StatelessWidget {
  final VoidCallback onRequest;

  const CameraPermissionBlock({super.key, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Для сканирования нужен доступ к камере', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRequest, child: const Text('Запросить доступ')),
          ],
        ),
      ),
    );
  }
}
