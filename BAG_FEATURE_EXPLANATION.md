# 🛒 GIẢI THÍCH CHI TIẾT FEATURE BAG (SHOPPING CART)

## 🏗️ KIẾN TRÚC TỔNG QUAN

Feature Bag được xây dựng theo **Clean Architecture** với BLoC pattern để quản lý shopping cart:

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (UI)             │
│  ┌──────────┬──────────┬──────────────┐  │
│  │ Bag      │ Payment  │ BLoC         │  │
│  │ Screen   │ Screens  │ (State Mgmt) │  │
│  └──────────┴──────────┴──────────────┘  │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│     DOMAIN LAYER (Business Logic)       │
│  ┌──────────┬──────────┬─────────────┐  │
│  │ Entities │ UseCases │ Repository  │  │
│  │          │          │ Interface   │  │
│  └──────────┴──────────┴─────────────┘  │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│     DATA LAYER (External Data)          │
│  ┌──────────┬──────────┬─────────────┐  │
│  │ Models   │ Data-    │ Repository  │  │
│  │          │ sources  │ Impl        │  │
│  └──────────┴──────────┴─────────────┘  │
└─────────────────────────────────────────┘
```

**Đặc điểm:**
- **Optimistic Updates**: Update UI ngay lập tức, sync với server sau
- **Smart Merge**: Tự động merge items giống nhau (cùng productId, color, size)
- **Product Integration**: Fetch product info để hiển thị đầy đủ

---

## 📁 CẤU TRÚC THƯ MỤC

```
lib/features/bag/
├── data/                           # DATA LAYER
│   ├── datasource/
│   │   └── bag_datasource.dart    # Firestore operations
│   ├── models/
│   │   └── cart_item_model.dart   # CartItemModel extends CartItem
│   └── repository/
│       └── bag_repository_impl.dart # Repository implementation
│
├── domain/                         # DOMAIN LAYER
│   ├── entities/
│   │   ├── cart_item.dart         # CartItem entity
│   │   └── cart_item_with_product.dart  # Combined entity
│   ├── repository/
│   │   └── bag_repository.dart    # IBagRepository interface
│   └── usecase/                   # Business logic operations
│       ├── add_to_cart.dart
│       ├── get_cart_items.dart
│       ├── get_cart_items_with_products.dart  # ⭐ Fetch + merge product info
│       ├── remove_from_cart.dart
│       └── update_cart_item_quantity.dart
│
└── presentation/                   # PRESENTATION LAYER
    ├── bloc/                       # BLoC State Management
    │   ├── bag_bloc.dart
    │   ├── bag_event.dart
    │   └── bag_state.dart
    ├── bag_screen.dart             # Cart UI
    ├── payment_screen.dart         # Checkout UI
    └── payment_success_screen.dart # Success screen
```

---

## 🔄 LUỒNG HOẠT ĐỘNG CHI TIẾT

### 1. 🎯 DOMAIN LAYER - Business Logic

#### **CartItem Entity** (`domain/entities/cart_item.dart`)

```dart
class CartItem {
  final String id;              // ID của cart item trong Firestore
  final String productId;       // ID của sản phẩm
  final String userId;          // ID của user sở hữu
  final int quantity;           // Số lượng
  final String? color;          // Màu sắc (optional)
  final String? size;           // Kích thước (optional)
  final DateTime addedAt;       // Thời gian thêm vào giỏ
}
```

**Đặc điểm:**
- ✅ **Immutable**: Tất cả fields đều `final`
- ✅ **User-specific**: Mỗi user có cart riêng
- ✅ **Product attributes**: color, size để phân biệt variants

#### **CartItemWithProduct Entity** (`domain/entities/cart_item_with_product.dart`)

```dart
class CartItemWithProduct {
  final CartItem cartItem;
  final Product product;        // Product info từ Products feature
  
  double get totalPrice => product.price * cartItem.quantity;
}
```

**Nhiệm vụ:**
- Kết hợp CartItem với Product info để hiển thị trong UI
- Tính totalPrice dựa trên product price hiện tại

**Lưu ý:**
- ⚠️ Product price có thể thay đổi sau khi user thêm vào cart
- ⚠️ Price snapshot chỉ xảy ra khi tạo Order (trong PaymentScreen)

#### **IBagRepository Interface** (`domain/repository/bag_repository.dart`)

```dart
abstract class IBagRepository {
  /// Lấy tất cả cart items của user
  Future<List<CartItem>> getCartItems(String userId);
  
  /// Thêm sản phẩm vào giỏ hàng
  /// Nếu đã có (cùng productId, color, size), tăng quantity
  Future<CartItem> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    String? color,
    String? size,
  });
  
  /// Xóa một cart item
  Future<void> removeFromCart(String cartItemId);
  
  /// Cập nhật số lượng
  Future<void> updateQuantity(String cartItemId, int newQuantity);
  
  /// Xóa tất cả cart items của user (sau khi checkout)
  Future<void> clearCart(String userId);
}
```

**Operations:**
- `getCartItems`: Lấy cart items của user
- `addToCart`: Smart merge nếu đã có item giống nhau
- `removeFromCart`: Xóa item
- `updateQuantity`: Cập nhật số lượng
- `clearCart`: Xóa toàn bộ cart (sau khi checkout thành công)

#### **Use Cases** - Business Operations

##### **1. AddToCartUseCase** (`domain/usecases/add_to_cart.dart`)

```dart
class AddToCartUseCase {
  final IBagRepository _repository;
  
  Future<CartItem> call({
    required String userId,
    required String productId,
    required int quantity,
    String? color,
    String? size,
  }) {
    return _repository.addToCart(...);
  }
}
```

**Nhiệm vụ:**
- Thêm product vào cart
- Tự động merge nếu đã có (trong datasource)

##### **2. GetCartItemsUseCase** (`domain/usecases/get_cart_items.dart`)

```dart
class GetCartItemsUseCase {
  final IBagRepository _repository;
  
  Future<List<CartItem>> call(String userId) {
    return _repository.getCartItems(userId);
  }
}
```

**Nhiệm vụ:**
- Lấy cart items (chỉ CartItem, không có Product info)

##### **3. GetCartItemsWithProductsUseCase** ⭐ (`domain/usecases/get_cart_items_with_products.dart`)

**Use case quan trọng nhất** - Fetch cart items + product info:

```dart
class GetCartItemsWithProductsUseCase {
  final IBagRepository _bagRepository;
  final ProductRepository _productRepository;
  
  Future<List<CartItemWithProduct>> call(String userId) async {
    // 1. Lấy cart items
    final cartItems = await _bagRepository.getCartItems(userId);
    
    // 2. Fetch product info song song (parallel) để tối ưu tốc độ
    final futures = cartItems.map((cartItem) async {
      try {
        final product = await _productRepository.getProduct(cartItem.productId);
        return CartItemWithProduct(
          cartItem: cartItem,
          product: product,
        );
      } catch (e) {
        // Nếu product không tồn tại, bỏ qua cart item này
        print('[GetCartItemsWithProducts] Product ${cartItem.productId} not found: $e');
        return null;
      }
    });
    
    // 3. Chờ tất cả futures hoàn thành song song
    final results = await Future.wait(futures);
    
    // 4. Lọc bỏ các null values (products không tìm thấy)
    return results.whereType<CartItemWithProduct>().toList();
  }
}
```

**Đặc điểm quan trọng:**

1. **Parallel Fetching:**
   - ✅ Fetch tất cả products song song (không tuần tự)
   - ✅ Tối ưu performance với nhiều items

2. **Error Handling:**
   - ✅ Nếu product không tồn tại → bỏ qua cart item đó
   - ✅ Không throw exception, chỉ log warning

3. **Data Integrity:**
   - ✅ Tự động cleanup cart items của products đã bị xóa

**Luồng hoạt động:**
```
GetCartItemsWithProductsUseCase(userId)
  ↓
1. GetCartItemsUseCase(userId)
   → Return List<CartItem>
  ↓
2. For each CartItem:
   → ProductRepository.getProduct(productId) (parallel)
     → Success: Create CartItemWithProduct
     → Error: Return null
  ↓
3. Future.wait(all futures) (parallel execution)
  ↓
4. Filter null values
  ↓
Return List<CartItemWithProduct>
```

##### **4. RemoveFromCartUseCase** (`domain/usecases/remove_from_cart.dart`)

```dart
class RemoveFromCartUseCase {
  final IBagRepository _repository;
  
  Future<void> call(String cartItemId) {
    return _repository.removeFromCart(cartItemId);
  }
}
```

##### **5. UpdateCartItemQuantityUseCase** (`domain/usecases/update_cart_item_quantity.dart`)

```dart
class UpdateCartItemQuantityUseCase {
  final IBagRepository _repository;
  
  Future<void> call(String cartItemId, int newQuantity) {
    return _repository.updateQuantity(cartItemId, newQuantity);
  }
}
```

---

### 2. 💾 DATA LAYER - Firebase Integration

#### **CartItemModel** (`data/models/cart_item_model.dart`)

```dart
class CartItemModel extends CartItem {
  // Extends CartItem entity, thêm serialization methods
}
```

**Nhiệm vụ:**
- ✅ **fromFirestore()**: Convert Firestore DocumentSnapshot → CartItemModel
- ✅ **toMap()**: Convert CartItemModel → Map<String, dynamic>
- ✅ **fromEntity()**: Convert CartItem entity → CartItemModel

**Firestore structure:**
```json
{
  "productId": "prod123",
  "userId": "user456",
  "quantity": 2,
  "color": "Đỏ",
  "size": "M",
  "addedAt": Timestamp
}
```

#### **BagRemoteDataSource** (`data/datasources/bag_datasource.dart`)

Sử dụng **generic FirebaseRemoteDS** pattern + custom logic:

```dart
class BagRemoteDataSourceImpl implements BagRemoteDataSource {
  final FirebaseRemoteDS<CartItemModel> _remoteSource;
  final CollectionReference _cartItemsCollection = 
      FirebaseFirestore.instance.collection('cartItems');
}
```

**Các operations:**

##### **1. getCartItems:**
```dart
Future<List<CartItemModel>> getCartItems(String userId) async {
  final snapshot = await _cartItemsCollection
      .where('userId', isEqualTo: userId)
      .orderBy('addedAt', descending: false)  // Cũ nhất trước
      .get();
  
  return snapshot.docs
      .map((doc) => CartItemModel.fromFirestore(doc))
      .toList();
}
```

**Đặc biệt:**
- ✅ Filter by userId
- ✅ Sort by addedAt (cũ nhất trước)
- ⚠️ Cần composite index: `userId (Ascending) + addedAt (Ascending)`

##### **2. addToCart (Smart Merge Logic):**
```dart
Future<CartItemModel> addToCart({
  required String userId,
  required String productId,
  required int quantity,
  String? color,
  String? size,
}) async {
  // 1. Tìm cart items với cùng productId
  final existingSnapshot = await _cartItemsCollection
      .where('userId', isEqualTo: userId)
      .where('productId', isEqualTo: productId)
      .get();
  
  // 2. Filter trong code: match color và size
  // (Firestore không hỗ trợ query với null values)
  final matchingDocs = existingSnapshot.docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>;
    final docColor = data['color'] as String?;
    final docSize = data['size'] as String?;
    return docColor == color && docSize == size;
  }).toList();
  
  if (matchingDocs.isNotEmpty) {
    // 3. Đã có → Tăng quantity
    final existingDoc = matchingDocs.first;
    final existingItem = CartItemModel.fromFirestore(existingDoc);
    final newQuantity = existingItem.quantity + quantity;
    
    // Update chỉ quantity field
    await _cartItemsCollection.doc(existingDoc.id).update({
      'quantity': newQuantity
    });
    
    // Return updated item
    return CartItemModel(...);
  } else {
    // 4. Chưa có → Tạo mới
    final newItem = CartItemModel(...);
    final newId = await add(newItem);
    return CartItemModel(...);
  }
}
```

**Smart Merge Logic:**
- ✅ **Same productId + same color + same size** → Merge (tăng quantity)
- ✅ **Different attributes** → Create new cart item
- ✅ **Optimization**: Update chỉ quantity field (không update toàn bộ document)

**Example:**
```
Cart hiện tại:
  - Product A, Red, M, qty: 2
  
User thêm: Product A, Red, M, qty: 1
  → Merge: Product A, Red, M, qty: 3

User thêm: Product A, Blue, M, qty: 1
  → Create new: Product A, Blue, M, qty: 1
```

##### **3. updateQuantity:**
```dart
Future<void> updateQuantity(String cartItemId, int newQuantity) async {
  // Validation
  if (newQuantity <= 0) {
    throw Exception('Quantity phải lớn hơn 0');
  }
  
  // Check exists
  final existingItem = await getById(cartItemId);
  if (existingItem == null) {
    throw Exception('Cart item không tồn tại');
  }
  
  // Update chỉ quantity field
  await _cartItemsCollection.doc(cartItemId).update({
    'quantity': newQuantity
  });
}
```

**Validation:**
- ✅ Quantity > 0
- ✅ Item exists check

##### **4. clearCart:**
```dart
Future<void> clearCart(String userId) async {
  final snapshot = await _cartItemsCollection
      .where('userId', isEqualTo: userId)
      .get();
  
  // Batch delete để tối ưu
  final batch = FirebaseFirestore.instance.batch();
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
}
```

**Đặc biệt:**
- ✅ Batch delete để atomic operation
- ✅ Xóa tất cả items của user trong một transaction

#### **BagRepositoryImpl** (`data/repository/bag_repository_impl.dart`)

**Adapter pattern** - Kết nối Domain và Data layer:

```dart
class BagRepositoryImpl implements IBagRepository {
  final BagRemoteDataSource _datasource;
  
  @override
  Future<CartItem> addToCart({...}) async {
    final model = await _datasource.addToCart(...);
    return model;  // CartItemModel extends CartItem
  }
  
  // ... other methods
}
```

**Nhiệm vụ:**
- ✅ Convert CartItemModel → CartItem entity (implicit vì extends)
- ✅ Abstract domain layer khỏi data layer details

---

### 3. 🎨 PRESENTATION LAYER - BLoC Pattern

#### **A. BLoC Pattern** - State Management

##### **BagEvent** (`presentation/bloc/bag_event.dart`)

```dart
abstract class BagEvent extends Equatable {}

class LoadCartItems extends BagEvent {
  final String userId;
  const LoadCartItems(this.userId);
}

class AddToCart extends BagEvent {
  final String userId;
  final String productId;
  final int quantity;
  final String? color;
  final String? size;
}

class RemoveFromCart extends BagEvent {
  final String cartItemId;
  const RemoveFromCart(this.cartItemId);
}

class UpdateQuantity extends BagEvent {
  final String cartItemId;
  final int newQuantity;
  const UpdateQuantity(this.cartItemId, this.newQuantity);
}
```

##### **BagState** (`presentation/bloc/bag_state.dart`)

```dart
abstract class BagState extends Equatable {}

class BagInitial extends BagState {}
// Initial state

class BagLoading extends BagState {}
// Đang load cart items

class BagLoaded extends BagState {
  final List<CartItemWithProduct> cartItems;
  final String userId;
  const BagLoaded(this.cartItems, this.userId);
  
  // Computed property
  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}
// Đã load thành công

class BagError extends BagState {
  final String message;
  const BagError(this.message);
}
// Có lỗi xảy ra

class BagItemAdded extends BagState {
  final String message;
  const BagItemAdded(this.message);
}
// Item đã được thêm (temporary state)
```

**State machine:**
```
BagInitial
  ↓
BagLoading → BagLoaded
  ↓          ↓
BagError   (user có thể edit cart)
            ↓
          AddToCart event
            ↓
          BagItemAdded → BagLoaded (reload)
            ↓
          RemoveFromCart event
            ↓
          Optimistic update → BagLoaded
            ↓
          UpdateQuantity event
            ↓
          Optimistic update → BagLoaded
```

##### **BagBloc** (`presentation/bloc/bag_bloc.dart`)

**1. LoadCartItems Handler:**
```dart
on<LoadCartItems>((event, emit) async {
  emit(BagLoading());
  try {
    final cartItems = await getCartItemsUseCase(event.userId);
    emit(BagLoaded(cartItems, event.userId));
  } catch (e) {
    emit(BagError(e.toString()));
  }
});
```

**2. AddToCart Handler:**
```dart
on<AddToCart>((event, emit) async {
  try {
    // Add to cart
    await addToCartUseCase(...);
    emit(const BagItemAdded('Đã thêm vào giỏ hàng!'));
    
    // Reload cart items với product info
    final cartItems = await getCartItemsUseCase(event.userId);
    emit(BagLoaded(cartItems, event.userId));
  } catch (e) {
    emit(BagError('Lỗi khi thêm vào giỏ hàng: $e'));
  }
});
```

**Đặc biệt:**
- ✅ Reload sau khi add để có product info đầy đủ
- ✅ Success message trước khi reload

**3. RemoveFromCart Handler (Optimistic Update):**
```dart
on<RemoveFromCart>((event, emit) async {
  final currentState = state;
  if (currentState is BagLoaded) {
    // Optimistic update: Xóa item khỏi UI ngay lập tức
    final updatedItems = currentState.cartItems
        .where((item) => item.cartItem.id != event.cartItemId)
        .toList();
    emit(BagLoaded(updatedItems, currentState.userId));
    
    try {
      // Sau đó xóa từ server
      await removeFromCartUseCase(event.cartItemId);
      // Không cần reload vì đã update optimistic
    } catch (e) {
      // Nếu lỗi, reload lại để sync với server
      try {
        final cartItems = await getCartItemsUseCase(currentState.userId);
        emit(BagLoaded(cartItems, currentState.userId));
      } catch (_) {
        emit(BagError('Lỗi khi xóa khỏi giỏ hàng: $e'));
      }
    }
  }
});
```

**Optimistic Update Pattern:**
1. ✅ Update UI ngay lập tức (better UX)
2. ✅ Sync với server sau
3. ✅ Rollback nếu có lỗi

**4. UpdateQuantity Handler (Optimistic Update):**
```dart
on<UpdateQuantity>((event, emit) async {
  final currentState = state;
  if (currentState is BagLoaded) {
    // Optimistic update: Cập nhật quantity ngay lập tức
    final updatedItems = currentState.cartItems.map((item) {
      if (item.cartItem.id == event.cartItemId) {
        // Tạo CartItem mới với quantity đã cập nhật
        final updatedCartItem = CartItem(...);
        return CartItemWithProduct(
          cartItem: updatedCartItem,
          product: item.product,
        );
      }
      return item;
    }).toList();
    emit(BagLoaded(updatedItems, currentState.userId));
    
    try {
      // Sau đó cập nhật trên server
      await updateQuantityUseCase(event.cartItemId, event.newQuantity);
      // Không cần reload vì đã update optimistic
    } catch (e) {
      // Rollback nếu lỗi
      try {
        final cartItems = await getCartItemsUseCase(currentState.userId);
        emit(BagLoaded(cartItems, currentState.userId));
      } catch (_) {
        emit(BagError('Lỗi khi cập nhật số lượng: $e'));
      }
    }
  }
});
```

**Đặc biệt:**
- ✅ Optimistic update cho instant feedback
- ✅ Rollback mechanism nếu server update fail

---

#### **B. UI Screens**

##### **1. BagScreen** (`presentation/bag_screen.dart`)

**Chức năng:**
- Hiển thị cart items với product info
- Search cart items
- Update quantity
- Remove items
- Navigate to payment

**State Management:**
```dart
BlocProvider<BagBloc>(
  create: (_) {
    final bloc = sl<BagBloc>();
    bloc.add(LoadCartItems(userId));  // Auto load
    return bloc;
  },
  child: ...,
)
```

**Search Functionality:**
```dart
List<CartItemWithProduct> _filterCartItems(
  List<CartItemWithProduct> items,
  String query,
) {
  if (query.isEmpty) return items;
  final lowerQuery = query.toLowerCase();
  return items.where((item) {
    return item.product.name.toLowerCase().contains(lowerQuery) ||
        item.product.shortDescription.toLowerCase().contains(lowerQuery);
  }).toList();
}
```

**Cart Item Card:**
- Product image
- Product name
- Color/Size badges
- Quantity control (+/-)
- Total price (item.totalPrice)
- Remove option (popup menu)

**Bottom Checkout Section:**
- Total price (computed từ filtered items)
- Item count
- "Thanh toán" button → Navigate to PaymentScreen

**UI States:**
- Empty cart: Show empty state với icon
- Loading: CircularProgressIndicator
- Error: Error message + Retry button
- Loaded: List of items + checkout section

##### **2. PaymentScreen** (`presentation/payment_screen.dart`)

**Chức năng:**
- Review order before payment
- Create order và reduce stock
- Clear cart sau khi thành công

**Luồng checkout:**
```
User click "Thanh toán"
  ↓
PaymentScreen(_processPayment)
  ↓
1. Create OrderItems từ cart items
   → Map CartItemWithProduct → OrderItem
   → Snapshot product info (name, price, image)
  ↓
2. Create Order
   → Order(orderItems, totalAmount, status: processing)
  ↓
3. CreateOrderWithReduceStockUseCase(order)
   → Atomic: Create order + Reduce stock
  ↓
4. Clear product cache
   → ProductCacheService.instance.clearCache()
  ↓
5. Clear cart
   → bagDataSource.clearCart(userId)
  ↓
6. Navigate to PaymentSuccessScreen
```

**Code:**
```dart
Future<void> _processPayment() async {
  setState(() => _isProcessing = true);
  
  try {
    // 1. Create order items
    final orderItems = widget.cartItems.map((item) {
      return OrderItem(
        productId: item.cartItem.productId,
        productName: item.product.name,        // Snapshot
        productImageUrl: item.product.imageUrl, // Snapshot
        quantity: item.cartItem.quantity,
        price: item.product.price,              // Snapshot
        color: item.cartItem.color,
        size: item.cartItem.size,
      );
    }).toList();
    
    // 2. Create order
    final order = Order(
      id: '',
      userId: authState.user.id,
      customerName: authState.user.displayName ?? '',
      customerEmail: authState.user.email,
      items: orderItems,
      totalAmount: widget.totalPrice,
      createdAt: DateTime.now(),
      status: OrderStatus.processing,
    );
    
    // 3. Create order + reduce stock
    final createOrderUseCase = sl<CreateOrderWithReduceStockUseCase>();
    final orderId = await createOrderUseCase(order);
    
    // 4. Clear cache
    ProductCacheService.instance.clearCache();
    
    // 5. Clear cart
    final bagDataSource = sl<BagRemoteDataSource>();
    await bagDataSource.clearCart(authState.user.id);
    
    // 6. Navigate to success
    context.push(AppRouters.paymentSuccess, extra: {'orderId': orderId});
  } catch (e) {
    // Show error
  }
}
```

**Đặc biệt:**
- ✅ Price snapshot tại thời điểm checkout
- ✅ Clear cache để refresh product data
- ✅ Clear cart sau khi checkout thành công
- ✅ Loading state khi processing

##### **3. PaymentSuccessScreen** (`presentation/payment_success_screen.dart`)

**Chức năng:**
- Hiển thị success message
- Navigate to home hoặc order detail

**UI:**
- Success icon (green circle với checkmark)
- Success message
- "Về trang chủ" button
- "Xem đơn hàng" button → Navigate to OrderDetailScreen

---

## 🔑 ĐIỂM CẦN LƯU Ý QUAN TRỌNG

### 1. ⚠️ Smart Merge Logic

**Vấn đề:**
- User có thể thêm cùng một product nhiều lần
- Cần merge nếu attributes giống nhau

**Solution:**
- ✅ Match by: `productId + color + size`
- ✅ Same → Merge (tăng quantity)
- ✅ Different → Create new cart item

**Implementation:**
```dart
// In addToCart
final matchingDocs = existingSnapshot.docs.where((doc) {
  final data = doc.data();
  final docColor = data['color'] as String?;
  final docSize = data['size'] as String?;
  return docColor == color && docSize == size;
}).toList();
```

**Lưu ý:**
- ⚠️ Firestore không hỗ trợ query với null values
- ⚠️ Phải filter trong code sau khi query

### 2. 📦 Product Info Fetching

**Strategy:**
- ✅ Parallel fetching cho performance
- ✅ Handle missing products gracefully
- ✅ Auto cleanup cart items của deleted products

**Implementation:**
```dart
final futures = cartItems.map((cartItem) async {
  try {
    final product = await _productRepository.getProduct(cartItem.productId);
    return CartItemWithProduct(cartItem: cartItem, product: product);
  } catch (e) {
    return null;  // Skip deleted products
  }
});

final results = await Future.wait(futures);
return results.whereType<CartItemWithProduct>().toList();
```

**Lợi ích:**
- ✅ Better performance với parallel execution
- ✅ Data integrity (auto cleanup)
- ✅ Better UX (không crash nếu product deleted)

### 3. ⚡ Optimistic Updates

**Pattern:**
- Update UI ngay lập tức
- Sync với server sau
- Rollback nếu có lỗi

**Benefits:**
- ✅ Instant feedback (better UX)
- ✅ Perceived performance
- ✅ Works offline (đến khi sync)

**Implementation:**
```dart
// RemoveFromCart handler
// 1. Update UI immediately
emit(BagLoaded(updatedItems, userId));

// 2. Sync with server
await removeFromCartUseCase(cartItemId);

// 3. Rollback if error
catch (e) {
  final cartItems = await getCartItemsUseCase(userId);
  emit(BagLoaded(cartItems, userId));  // Rollback
}
```

### 4. 💰 Price Handling

**Vấn đề:**
- Product price có thể thay đổi sau khi user thêm vào cart
- Cần snapshot price tại thời điểm checkout

**Solution:**
- ✅ Cart: Lưu productId, lấy price từ Product real-time
- ✅ Order: Snapshot price trong OrderItem

**Flow:**
```
Cart: CartItem (productId) → Fetch Product → Display current price
Order: OrderItem (price snapshot) → Never changes
```

**Lợi ích:**
- ✅ User thấy giá mới nhất trong cart
- ✅ Order có giá snapshot (fair pricing)

### 5. 🔄 Integration với Orders Feature

**Checkout Flow:**
```
BagScreen → PaymentScreen
  ↓
PaymentScreen → CreateOrderWithReduceStockUseCase
  ↓
CreateOrderWithReduceStockUseCase:
  → Create order
  → Reduce stock (atomic batch)
  ↓
Clear cache
  ↓
Clear cart
  ↓
Navigate to PaymentSuccessScreen
  ↓
PaymentSuccessScreen → OrderDetailScreen
```

**Dependencies:**
- ✅ Bag depends on Orders (CreateOrderWithReduceStockUseCase)
- ✅ Bag depends on Products (ProductRepository for fetching info)

### 6. 🎨 UI/UX Features

**Search:**
- ✅ Real-time search trong cart
- ✅ Filter by product name hoặc description
- ✅ Update total price dựa trên filtered items

**Quantity Control:**
- ✅ +/- buttons
- ✅ Min quantity = 1 (không cho xóa bằng cách giảm về 0)
- ✅ Optimistic update

**Remove:**
- ✅ Popup menu
- ✅ Optimistic update

**Empty State:**
- ✅ Friendly message
- ✅ Icon illustration

### 7. 🔐 Security Considerations

**Firestore Security Rules:**
- ⚠️ Users chỉ được read/write cart items của chính họ
- ⚠️ Phải setup rules đúng

**Example rules:**
```javascript
match /cartItems/{cartItemId} {
  // User chỉ được read/write cart items của chính họ
  allow read, write: if request.auth != null && 
                      resource.data.userId == request.auth.uid;
}
```

### 8. 📊 Query Performance

**getCartItems:**
- ✅ Filter by userId
- ✅ Sort by addedAt
- ⚠️ Cần composite index: `userId (Ascending) + addedAt (Ascending)`

**addToCart:**
- ✅ Query by userId + productId
- ✅ Filter color/size trong code (vì null values)

---

## 💡 ĐIỂM HAY CỦA KIẾN TRÚC

### 1. 🏗️ Clean Architecture Benefits

- **Separation of Concerns**: Business logic tách biệt hoàn toàn
- **Testability**: Dễ test từng layer độc lập
- **Flexibility**: Dễ thay đổi implementation

### 2. ⚡ Optimistic Updates

**Better UX:**
- ✅ Instant feedback
- ✅ Perceived performance
- ✅ Smooth interactions

### 3. 🔄 Smart Merge

**User-friendly:**
- ✅ Không duplicate items
- ✅ Auto-merge cùng product
- ✅ Clear logic

### 4. 📦 Parallel Fetching

**Performance:**
- ✅ Fetch products song song
- ✅ Tối ưu với nhiều items
- ✅ Better scalability

### 5. 🎯 Product Integration

**Reuse:**
- ✅ Dùng ProductRepository từ Products feature
- ✅ Consistent data
- ✅ Single source of truth

---

## 🚀 CÁC ĐIỂM CÓ THỂ CẢI THIỆN

### 1. 📄 Real-time Sync

**Hiện tại:**
- Manual reload

**Có thể cải thiện:**
- Stream cart items (real-time updates)
- Auto-sync khi có thay đổi từ device khác

### 2. 💾 Local Caching

**Có thể thêm:**
- Cache cart items locally
- Offline support
- Sync khi online

### 3. 🔍 Advanced Search

**Hiện tại:**
- Basic text search

**Có thể thêm:**
- Filter by category
- Sort by price, date
- Filter by in-stock

### 4. 📦 Stock Validation

**Hiện tại:**
- Check stock khi checkout (trong CreateOrderWithReduceStockUseCase)

**Có thể cải thiện:**
- Check stock khi add to cart
- Show warning nếu low stock
- Prevent add nếu out of stock

### 5. 🎯 Quantity Limits

**Có thể thêm:**
- Max quantity per item
- Stock-based quantity limit
- Validation messages

### 6. 💰 Price Updates

**Hiện tại:**
- Show current price in cart

**Có thể cải thiện:**
- Show price change notification
- Ask user confirm nếu price increased

### 7. 🔄 Cart Persistence

**Có thể thêm:**
- Save cart items khi logout
- Restore cart khi login
- Sync across devices

### 8. 📊 Analytics

**Có thể thêm:**
- Track cart abandonment
- Track add to cart events
- Track checkout completion rate

### 9. 🎁 Promotions

**Có thể thêm:**
- Discount codes
- Free shipping threshold
- Coupon application

### 10. 🔔 Notifications

**Có thể thêm:**
- Price drop alerts
- Back in stock notifications
- Abandoned cart reminders

---

## 📊 TÓM TẮT LUỒNG HOẠT ĐỘNG

### **User thêm sản phẩm vào cart:**
```
1. ProductDetailPage → BuyNowSheet
2. User chọn quantity
3. Click "Thêm vào giỏ"
   → BagBloc.add(AddToCart(...))
4. AddToCartUseCase
   → IBagRepository.addToCart()
     → BagRemoteDataSource.addToCart()
       → Check existing items
         → Merge if same (productId + color + size)
         → Create new if different
5. BagBloc emit BagItemAdded
6. Reload cart items
   → GetCartItemsWithProductsUseCase()
     → GetCartItems() + Fetch Products (parallel)
       → Return CartItemWithProduct list
7. BagBloc emit BagLoaded
8. UI update
```

### **User xem cart:**
```
1. Navigate to BagScreen
2. BlocProvider create BagBloc
3. BagBloc.add(LoadCartItems(userId))
4. LoadCartItems handler
   → GetCartItemsWithProductsUseCase(userId)
     → GetCartItems() → Fetch Products (parallel)
       → Return CartItemWithProduct list
5. BagBloc emit BagLoaded
6. UI display cart items
```

### **User update quantity:**
```
1. User click +/- button
   → BagBloc.add(UpdateQuantity(cartItemId, newQty))
2. UpdateQuantity handler
   → Optimistic update: Update UI immediately
     → emit(BagLoaded(updatedItems))
   → UpdateCartItemQuantityUseCase()
     → Sync with server
     → Rollback if error
3. UI update instantly
```

### **User remove item:**
```
1. User click remove option
   → BagBloc.add(RemoveFromCart(cartItemId))
2. RemoveFromCart handler
   → Optimistic update: Remove from UI immediately
     → emit(BagLoaded(updatedItems))
   → RemoveFromCartUseCase()
     → Sync with server
     → Rollback if error
3. UI update instantly
```

### **User checkout:**
```
1. BagScreen → Click "Thanh toán"
2. Navigate to PaymentScreen(cartItems, totalPrice)
3. User review order
4. Click "Xác nhận thanh toán"
   → _processPayment()
5. Create OrderItems (snapshot product info)
6. Create Order
7. CreateOrderWithReduceStockUseCase(order)
   → Atomic: Create order + Reduce stock
8. Clear product cache
9. Clear cart
10. Navigate to PaymentSuccessScreen
11. Navigate to OrderDetailScreen (optional)
```

---

## ✅ CHECKLIST ĐỂ VẬN HÀNH TỐT

- [ ] Firestore security rules setup đúng
- [ ] Firestore composite index: `userId + addedAt`
- [ ] Smart merge logic hoạt động đúng
- [ ] Optimistic updates hoạt động đúng
- [ ] Parallel fetching hoạt động
- [ ] Error handling đầy đủ
- [ ] Product info fetching đúng
- [ ] Price snapshot tại checkout đúng
- [ ] Cart clear sau checkout
- [ ] Cache clear sau checkout
- [ ] Empty state hiển thị đúng
- [ ] Search functionality hoạt động

---

## 🎓 KẾT LUẬN

Feature Bag được thiết kế tốt với:
- ✅ Clean Architecture rõ ràng
- ✅ Optimistic updates cho better UX
- ✅ Smart merge logic
- ✅ Parallel product fetching
- ✅ Good integration với Orders và Products

**Điểm mạnh:**
- Optimistic updates (instant feedback)
- Smart merge (no duplicates)
- Parallel fetching (performance)
- Good error handling
- Price snapshot pattern

**Có thể cải thiện:**
- Real-time sync
- Local caching
- Stock validation in cart
- Advanced search/filter
- Cart persistence
- Analytics tracking

---

**Tác giả:** AI Assistant  
**Ngày:** 2024

