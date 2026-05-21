import 'package:flutter/material.dart';

class CatalogAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double _height = 72;
  final String userName;
  final VoidCallback onScan;
  final VoidCallback onLogout;

  const CatalogAppBar({
    super.key,
    required this.userName,
    required this.onScan,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Склад • $userName'),
      actions: [
        IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: onScan),
        IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_height);
}
