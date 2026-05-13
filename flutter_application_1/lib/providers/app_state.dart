import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/local_database.dart';
import '../models/product.dart';
import '../models/user.dart';

class ScanResult {
  final bool success;
  final String message;
  final Product? product;

  const ScanResult({required this.success, required this.message, this.product});
}

class AppState with ChangeNotifier {
  Database? _db;
  bool _isInitialized = false;
  UserModel? _currentUser;
  List<Product> _products = const [];

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;
  UserModel? get currentUser => _currentUser;
  bool get canCreateProducts => _currentUser?.canCreateProducts ?? false;
  List<Product> get products => _products;

  Future<void> init() async {
    _db = await LocalDatabase.instance.database;
    await _loadProducts();
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> register(
    String email,
    String password,
    String name, {
    UserRole role = UserRole.user,
  }) async {
    final db = _db;
    if (db == null) return false;

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (existing.isNotEmpty) return false;

    final id = await db.insert('users', {
      'email': email,
      'password': password,
      'name': name,
      'role': role.name,
    });

    _currentUser = UserModel(
      id: id,
      email: email,
      password: password,
      name: name,
      role: role,
    );
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    final db = _db;
    if (db == null) return false;

    final data = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (data.isEmpty) return false;

    _currentUser = UserModel.fromMap(data.first);
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> addProduct(String name, String description, String image) async {
    final db = _db;
    if (db == null || !canCreateProducts) return;

    await db.insert('products', {
      'name': name,
      'description': description,
      'image': image,
      'is_available': 1,
    });

    await _loadProducts();
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ScanResult> processQrScan(String productId) async {
    final db = _db;
    final user = _currentUser;
    if (db == null || user == null || user.id == null) {
      return const ScanResult(success: false, message: 'Пользователь не авторизован');
    }

    final product = getProductById(productId);
    if (product == null) {
      return ScanResult(success: false, message: 'Товар с кодом "$productId" не найден');
    }

    if (product.isAvailable) {
      await db.update(
        'products',
        {
          'is_available': 0,
          'taken_by_user_id': user.id,
          'taken_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [int.parse(product.id)],
      );

      await db.insert('product_actions', {
        'product_id': int.parse(product.id),
        'user_id': user.id,
        'action': 'take',
        'action_at': DateTime.now().toIso8601String(),
      });

      await _loadProducts();
      notifyListeners();
      return ScanResult(success: true, message: 'Товар выдан: ${product.name}', product: getProductById(product.id));
    }

    if (product.takenByUserId != user.id && user.role != UserRole.admin) {
      return const ScanResult(
        success: false,
        message: 'Возврат доступен только тому, кто взял товар, или администратору',
      );
    }

    await db.update(
      'products',
      {
        'is_available': 1,
        'taken_by_user_id': null,
        'taken_at': null,
      },
      where: 'id = ?',
      whereArgs: [int.parse(product.id)],
    );

    await db.insert('product_actions', {
      'product_id': int.parse(product.id),
      'user_id': user.id,
      'action': 'return',
      'action_at': DateTime.now().toIso8601String(),
    });

    await _loadProducts();
    notifyListeners();
    return ScanResult(success: true, message: 'Товар возвращен: ${product.name}', product: getProductById(product.id));
  }

  Future<void> _loadProducts() async {
    final db = _db;
    if (db == null) return;

    final rows = await db.query('products', orderBy: 'id DESC');
    _products = rows.map(Product.fromMap).toList();
  }
}
