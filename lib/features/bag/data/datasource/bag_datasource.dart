import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/core/data/firebase_remote_data_source.dart';
import 'package:e_commerce/features/bag/data/models/cart_item_model.dart';

/// Abstract interface cho Bag Remote DataSource
abstract class BagRemoteDataSource {
  // === CRUD Operations cơ bản (internal use, được dùng bởi custom methods) ===
  /// Lấy cart item theo ID (internal use)
  Future<CartItemModel?> getById(String id);
  
  /// Thêm cart item mới, trả về ID của document đã tạo (internal use)
  Future<String> add(CartItemModel item);
  
  /// Xóa cart item (internal use)
  Future<void> delete(String id);

  // === Custom Operations đặc biệt cho Cart ===
  /// Lấy tất cả cart items của user (với query và sort)
  Future<List<CartItemModel>> getCartItems(String userId);

  /// Thêm sản phẩm vào giỏ hàng (với logic merge nếu đã tồn tại)
  /// Nếu đã có sản phẩm (cùng productId, color, size), tăng quantity
  Future<CartItemModel> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    String? color,
    String? size,
  });

  /// Xóa cart item (alias cho delete, giữ để nhất quán với domain)
  Future<void> removeFromCart(String cartItemId);

  /// Cập nhật số lượng (custom validation)
  Future<void> updateQuantity(String cartItemId, int newQuantity);

  /// Xóa tất cả cart items của user (batch delete)
  Future<void> clearCart(String userId);
}

/// Implementation của BagRemoteDataSource
/// Sử dụng FirebaseRemoteDS cho các operations cơ bản, và implement logic đặc biệt cho cart
class BagRemoteDataSourceImpl implements BagRemoteDataSource {
  final FirebaseRemoteDS<CartItemModel> _remoteSource;

  BagRemoteDataSourceImpl()
      : _remoteSource = FirebaseRemoteDS<CartItemModel>(
          collectionName: 'cartItems',
          fromFirestore: (doc) => CartItemModel.fromFirestore(doc),
          toFirestore: (model) => model.toMap(),
        );

  // Collection reference: cartItems (dùng trực tiếp từ FirebaseFirestore cho các queries phức tạp)
  CollectionReference get _cartItemsCollection =>
      FirebaseFirestore.instance.collection('cartItems');

  // === CRUD Operations cơ bản (internal use, được dùng bởi custom methods) ===
  
  @override
  Future<CartItemModel?> getById(String id) async {
    return await _remoteSource.getById(id);
  }

  @override
  Future<String> add(CartItemModel item) async {
    return await _remoteSource.add(item);
  }

  @override
  Future<void> delete(String id) async {
    await _remoteSource.delete(id);
  }
  
  /// Helper method: Tạo CartItemModel mới với ID đã cập nhật
  CartItemModel _createCartItemWithId({
    required String id,
    required String productId,
    required String userId,
    required int quantity,
    String? color,
    String? size,
    required DateTime addedAt,
  }) {
    return CartItemModel(
      id: id,
      productId: productId,
      userId: userId,
      quantity: quantity,
      color: color,
      size: size,
      addedAt: addedAt,
    );
  }

  // === Custom Operations đặc biệt cho Cart ===
  
  @override
  /// Lấy tất cả cart items của user
  /// Sử dụng composite index: userId (Ascending) + addedAt (Ascending)
  Future<List<CartItemModel>> getCartItems(String userId) async {
    final snapshot = await _cartItemsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: false)
        .get();
    
    return snapshot.docs
        .map((doc) => CartItemModel.fromFirestore(doc))
        .toList();
  }

  @override
  /// Thêm sản phẩm vào giỏ hàng
  /// Nếu đã có sản phẩm (cùng productId, color, size), tăng quantity
  Future<CartItemModel> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    String? color,
    String? size,
  }) async {
    // Tìm xem đã có cart item với cùng productId, color, size chưa
    // Firestore không hỗ trợ query phức tạp với null, nên lấy tất cả rồi filter trong code
    final existingSnapshot = await _cartItemsCollection
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .get();
    
    // Filter trong code: match color và size
    final matchingDocs = existingSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final docColor = data['color'] as String?;
      final docSize = data['size'] as String?;
      return docColor == color && docSize == size;
    }).toList();
    
    if (matchingDocs.isNotEmpty) {
      // Đã có sản phẩm này trong giỏ, tăng quantity
      final existingDoc = matchingDocs.first;
      final existingItem = CartItemModel.fromFirestore(existingDoc);
      final newQuantity = existingItem.quantity + quantity;
      
      // Update chỉ quantity field để tối ưu (không cần update toàn bộ document)
      await _cartItemsCollection.doc(existingDoc.id).update({'quantity': newQuantity});
      
      // Return item đã cập nhật
      return _createCartItemWithId(
        id: existingItem.id,
        productId: existingItem.productId,
        userId: existingItem.userId,
        quantity: newQuantity,
        color: existingItem.color,
        size: existingItem.size,
        addedAt: existingItem.addedAt,
      );
    } else {
      // Chưa có, tạo mới
      final newItem = CartItemModel(
        id: '', // Firestore sẽ tự generate
        productId: productId,
        userId: userId,
        quantity: quantity,
        color: color,
        size: size,
        addedAt: DateTime.now(),
      );
      
      // Dùng method add cơ bản (tái sử dụng code)
      final newId = await add(newItem);
      
      // Return item với ID mới
      return _createCartItemWithId(
        id: newId,
        productId: productId,
        userId: userId,
        quantity: quantity,
        color: color,
        size: size,
        addedAt: newItem.addedAt,
      );
    }
  }

  @override
  /// Xóa cart item (alias cho delete, giữ để nhất quán với domain)
  Future<void> removeFromCart(String cartItemId) async {
    await delete(cartItemId);
  }

  @override
  /// Cập nhật số lượng (custom validation và logic)
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      throw Exception('Quantity phải lớn hơn 0');
    }
    
    // Kiểm tra item có tồn tại không
    final existingItem = await getById(cartItemId);
    if (existingItem == null) {
      throw Exception('Cart item không tồn tại');
    }
    
    // Update chỉ quantity field để tối ưu (không cần update toàn bộ document)
    await _cartItemsCollection.doc(cartItemId).update({'quantity': newQuantity});
  }

  @override
  /// Xóa tất cả cart items của user
  Future<void> clearCart(String userId) async {
    final snapshot = await _cartItemsCollection
        .where('userId', isEqualTo: userId)
        .get();
    
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

