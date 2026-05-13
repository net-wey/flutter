import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/user.dart';

class CloudRepository {
  final FirebaseFirestore _firestore;

  CloudRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _products => _firestore.collection('products');

  Future<void> upsertUser(UserModel user) async {
    await _users.doc(user.email).set({
      'email': user.email,
      'password': user.password,
      'name': user.name,
      'role': user.roleValue,
      'updated_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<List<UserModel>> getUsers() async {
    final snapshot = await _users.get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          return UserModel(
            email: data['email'] as String,
            password: data['password'] as String,
            name: data['name'] as String,
            role: UserRole.values.firstWhere(
              (role) => role.name == data['role'],
              orElse: () => UserRole.user,
            ),
          );
        })
        .toList();
  }

  Future<void> upsertProduct(Product product) async {
    await _products.doc(product.id).set({
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'image': product.image,
      'is_available': product.isAvailable,
      'taken_by_user_id': product.takenByUserId,
      'taken_at': product.takenAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _products.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String,
        image: data['image'] as String,
        isAvailable: (data['is_available'] as bool?) ?? true,
        takenByUserId: data['taken_by_user_id'] as int?,
        takenAt: data['taken_at'] == null ? null : DateTime.tryParse(data['taken_at'] as String),
      );
    }).toList();
  }
}
