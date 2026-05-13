class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.isAvailable = true,
  });
}