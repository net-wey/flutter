import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/cloud_repository.dart';
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
  AppState({CloudRepository? cloudRepository}) : _cloudRepository = cloudRepository;

  final CloudRepository? _cloudRepository;
  Database? _db;
  bool _isInitialized = false;
  bool _isOnline = false;
  UserModel? _currentUser;
  List<Product> _products = const [];

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;
  bool get isOnline => _isOnline;
  UserModel? get currentUser => _currentUser;
  bool get canCreateProducts => _currentUser?.canCreateProducts ?? false;
  List<Product> get products => _products;

  Future<void> init() async {
    _db = await LocalDatabase.instance.database;
    _isOnline = await _hasInternet();
    await _loadProducts();

    if (_isOnline && _cloudRepository != null) {
      await _syncProductsFromCloud();
    }

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

    final user = UserModel(
      id: id,
      email: email,
      password: password,
      name: name,
      role: role,
    );

    _currentUser = user;

    if (_cloudRepository != null && await _refreshOnlineStatus()) {
      await _cloudRepository.upsertUser(user);
    }

    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    final db = _db;
    if (db == null) return false;

    if (_cloudRepository != null && await _refreshOnlineStatus()) {
      await _syncUsersFromCloud();
    }

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

    final id = await db.insert('products', {
      'name': name,
      'description': description,
      'image': image,
      'is_available': 1,
    });

    await _loadProducts();

    if (_cloudRepository != null && await _refreshOnlineStatus()) {
      final product = getProductById(id.toString());
      if (product != null) {
        await _cloudRepository.upsertProduct(product);
      }
    }

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

    final now = DateTime.now().toIso8601String();

    if (product.isAvailable) {
      await db.update(
        'products',
        {
          'is_available': 0,
          'taken_by_user_id': user.id,
          'taken_at': now,
        },
        where: 'id = ?',
        whereArgs: [int.parse(product.id)],
      );

      await db.insert('product_actions', {
        'product_id': int.parse(product.id),
        'user_id': user.id,
        'action': 'take',
        'action_at': now,
      });

      await _loadProducts();
      final updated = getProductById(product.id);
      await _syncProductIfOnline(updated);
      notifyListeners();
      return ScanResult(success: true, message: 'Товар выдан: ${product.name}', product: updated);
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
      'action_at': now,
    });

    await _loadProducts();
    final updated = getProductById(product.id);
    await _syncProductIfOnline(updated);
    notifyListeners();

    return ScanResult(success: true, message: 'Товар возвращен: ${product.name}', product: updated);
  }

  Future<void> _syncProductIfOnline(Product? product) async {
    if (product == null || _cloudRepository == null) return;
    if (await _refreshOnlineStatus()) {
      await _cloudRepository.upsertProduct(product);
    }
  }

  Future<void> _syncUsersFromCloud() async {
    final db = _db;
    if (_cloudRepository == null || db == null) return;

    final cloudUsers = await _cloudRepository.getUsers();
    for (final user in cloudUsers) {
      final existing = await db.query('users', where: 'email = ?', whereArgs: [user.email], limit: 1);
      if (existing.isEmpty) {
        await db.insert('users', user.toMap()..remove('id'));
      }
    }
  }

  Future<void> _syncProductsFromCloud() async {
    final db = _db;
    if (_cloudRepository == null || db == null) return;

    final cloudProducts = await _cloudRepository.getProducts();
    for (final product in cloudProducts) {
      await db.insert(
        'products',
        {
          'id': int.parse(product.id),
          'name': product.name,
          'description': product.description,
          'image': product.image,
          'is_available': product.isAvailable ? 1 : 0,
          'taken_by_user_id': product.takenByUserId,
          'taken_at': product.takenAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await _loadProducts();
  }

  Future<bool> _hasInternet() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Future<bool> _refreshOnlineStatus() async {
    _isOnline = await _hasInternet();
    return _isOnline;
  }

  Future<void> _loadProducts() async {
    final db = _db;
    if (db == null) return;

    final rows = await db.query('products', orderBy: 'id DESC');
    _products = rows.map(Product.fromMap).toList();
  }
}
