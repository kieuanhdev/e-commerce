import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.quantity,
    super.isVisible = true,
    super.lowStockThreshold = 10,
    super.imageUrl,
    super.shortDescription = '',
    super.longDescription = '',
    super.categoryId,
    required super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      isVisible: (data['isVisible'] as bool?) ?? true,
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 10,
      imageUrl: data['imageUrl'] as String?,
      shortDescription: data['shortDescription'] as String? ?? '',
      longDescription: data['longDescription'] as String? ?? '',
      categoryId: data['categoryId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'quantity': quantity,
    'isVisible': isVisible,
    'lowStockThreshold': lowStockThreshold,
    'imageUrl': imageUrl,
    'shortDescription': shortDescription,
    'longDescription': longDescription,
    'categoryId': categoryId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
  };

  factory ProductModel.fromEntity(Product e) => ProductModel(
    id: e.id,
    name: e.name,
    price: e.price,
    quantity: e.quantity,
    isVisible: e.isVisible,
    lowStockThreshold: e.lowStockThreshold,
    imageUrl: e.imageUrl,
    shortDescription: e.shortDescription,
    longDescription: e.longDescription,
    categoryId: e.categoryId,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );

  Product toEntity() => Product(
    id: id,
    name: name,
    price: price,
    quantity: quantity,
    isVisible: isVisible,
    lowStockThreshold: lowStockThreshold,
    imageUrl: imageUrl,
    shortDescription: shortDescription,
    longDescription: longDescription,
    categoryId: categoryId,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
