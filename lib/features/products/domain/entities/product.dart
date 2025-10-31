class Product {
  final String id;
  String name;
  double price;
  bool isVisible;
  int quantity;
  int lowStockThreshold;
  String? imageUrl;
  String shortDescription;
  String longDescription;
  String? categoryId;
  DateTime createdAt;
  DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.isVisible = true,
    this.lowStockThreshold = 10,
    this.imageUrl,
    this.shortDescription = '',
    this.longDescription = '',
    this.categoryId,
    required this.createdAt,
    this.updatedAt,
  });
}
