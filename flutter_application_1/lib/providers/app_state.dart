import 'package:flutter/material.dart';
import '../models/product.dart';

class User {
  final String email;
  final String password;
  final String name;
  
  User({
    required this.email,
    required this.password,
    required this.name,
  });
}

class AppState with ChangeNotifier {
  User? _currentUser;
  bool get isAuthenticated => _currentUser != null;
  
  // База пользователей (в реальном приложении это была бы БД)
  final List<User> _registeredUsers = [];
  
  final List<Product> _products = [
    Product(id: '1', name: 'Коробка A1', description: 'Детали для станка', image: "assets/image.png"),
  ];
  List<Product> get products => _products;

  // Регистрация
  bool register(String email, String password, String name) {
    // Проверяем, не существует ли уже такой email
    if (_registeredUsers.any((user) => user.email == email)) {
      return false; // Пользователь уже существует
    }
    
    // Создаем нового пользователя
    final newUser = User(
      email: email,
      password: password,
      name: name,
    );
    
    _registeredUsers.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  // Вход
  bool login(String email, String password) {
    // Ищем пользователя с таким email и паролем
    final user = _registeredUsers.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => null as User,
    );
    
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void addProduct(String name, String description, String image) {
    _products.add(Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      image: image
    ));
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}