# 📦 GIẢI THÍCH CHI TIẾT FEATURE ORDERS

## 🏗️ KIẾN TRÚC TỔNG QUAN

Feature Orders được xây dựng theo **Clean Architecture** với các operations để quản lý đơn hàng:

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (UI)             │
│  ┌──────────┬────────────────────────┐  │
│  │ MyOrder  │ OrderDetail            │  │
│  │ Screen   │ Screen                 │  │
│  └──────────┴────────────────────────┘  │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│     DOMAIN LAYER (Business Logic)       │
│  ┌──────────┬──────────┬─────────────┐  │
│  │ Entities │ UseCases │ Repository │  │
│  │          │          │ Interface  │  │
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

---

## 📁 CẤU TRÚC THƯ MỤC

```
lib/features/orders/
├── data/                           # DATA LAYER
│   ├── datasources/
│   │   └── order_datasource.dart   # Firestore operations
│   ├── models/
│   │   └── order_model.dart        # OrderModel extends Order
│   └── repository/
│       └── order_repository_impl.dart  # Repository implementation
│
├── domain/                         # DOMAIN LAYER
│   ├── entities/
│   │   ├── order.dart              # Order entity
│   │   └── order_item.dart         # OrderItem entity
│   ├── repository/
│   │   └── order_repository.dart   # IOrderRepository interface
│   └── usecases/                   # Business logic operations
│       ├── create_order.dart
│       ├── create_order_with_reduce_stock.dart  # ⭐ Atomic transaction
│       ├── get_orders_by_user_id.dart
│       └── get_order_by_id.dart
│
└── presentation/                    # PRESENTATION LAYER
    ├── my_order_screen.dart         # List orders by status
    └── order_detail_screen.dart     # Order details view
```

---

## 🔄 LUỒNG HOẠT ĐỘNG CHI TIẾT

### 1. 🎯 DOMAIN LAYER - Business Logic

#### **Order Entity** (`domain/entities/order.dart`)

```dart
class Order {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final OrderStatus status;  // processing, delivery, cancelled
  
  // Computed properties
  String get trackingNumber => 'ORD${id.substring(0, 8).toUpperCase()}';
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}
```

**Đặc điểm:**
- ✅ **Immutable**: Tất cả fields đều `final`
- ✅ **Computed properties**: `trackingNumber`, `totalQuantity`
- ✅ **Status enum**: Type-safe order status

**OrderStatus Enum:**
```dart
enum OrderStatus {
  processing,  // Đang xử lý
  delivery,    // Đang giao hàng
  cancelled;   // Đã hủy
  
  String get displayName {
    switch (this) {
      case OrderStatus.processing: return 'PROCESSING';
      case OrderStatus.delivery: return 'DELIVERY';
      case OrderStatus.cancelled: return 'CANCELLED';
    }
  }
  
  static OrderStatus fromString(String? status) {
    // Parse từ Firestore string
  }
}
```

#### **OrderItem Entity** (`domain/entities/order_item.dart`)

```dart
class OrderItem {
  final String productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double price;  // Giá TẠI THỜI ĐIỂM MUA (snapshot)
  final String? color;
  final String? size;
  
  double get totalPrice => price * quantity;
}
```

**Đặc điểm quan trọng:**
- ✅ **Price snapshot**: Lưu giá tại thời điểm mua (không thay đổi nếu product price thay đổi sau)
- ✅ **Product info snapshot**: Lưu name, imageUrl tại thời điểm mua
- ✅ **Optional attributes**: color, size (cho future use)

#### **IOrderRepository Interface** (`domain/repository/order_repository.dart`)

```dart
abstract class IOrderRepository {
  Future<String> createOrder(Order order);
  Future<List<Order>> getOrdersByUserId(String userId);
  Future<Order?> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, String status);
  Stream<List<Order>> getAllOrders();  // Cho admin
}
```

**Operations:**
- `createOrder`: Tạo order mới, trả về order ID
- `getOrdersByUserId`: Lấy tất cả orders của user (sắp xếp mới nhất trước)
- `getOrderById`: Lấy order theo ID
- `updateOrderStatus`: Cập nhật trạng thái order (cho admin)
- `getAllOrders`: Stream tất cả orders (real-time cho admin)

#### **Use Cases** - Business Operations

##### **1. CreateOrderUseCase** (`domain/usecases/create_order.dart`)

```dart
class CreateOrderUseCase {
  final IOrderRepository _repository;
  
  CreateOrderUseCase(this._repository);
  
  Future<String> call(Order order) {
    return _repository.createOrder(order);
  }
}
```

**Nhiệm vụ:**
- Tạo order mới
- Không giảm stock (dùng cho testing hoặc special cases)

##### **2. CreateOrderWithReduceStockUseCase** ⭐ (`domain/usecases/create_order_with_reduce_stock.dart`)

**Use case quan trọng nhất** - Tạo order và giảm stock trong một transaction atomic:

```dart
class CreateOrderWithReduceStockUseCase {
  final ProductRepository _productRepository;
  
  CreateOrderWithReduceStockUseCase(this._productRepository);
  
  Future<String> call(Order order) async {
    // Firestore batch write để đảm bảo atomicity
    final batch = FirebaseFirestore.instance.batch();
    
    // 1. Group items by productId
    final productQuantityMap = <String, int>{};
    for (var item in order.items) {
      productQuantityMap[item.productId] = 
        (productQuantityMap[item.productId] ?? 0) + item.quantity;
    }
    
    // 2. Fetch products và check stock
    for (var entry in productQuantityMap.entries) {
      final product = await _productRepository.getProduct(entry.key);
      final totalQuantityToReduce = entry.value;
      
      // Stock validation
      if (product.quantity < totalQuantityToReduce) {
        throw Exception('Sản phẩm "${product.name}" không đủ số lượng...');
      }
      
      // Add to batch update
      batch.update(
        FirebaseFirestore.instance.collection('products').doc(product.id),
        {
          'quantity': product.quantity - totalQuantityToReduce,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }
    
    // 3. Create order document
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    batch.set(orderRef, orderModel);
    
    // 4. Commit batch - ALL or NOTHING
    await batch.commit();
    
    return orderRef.id;
  }
}
```

**Đặc điểm quan trọng:**

1. **Atomic Transaction:**
   - ✅ Dùng Firestore batch write
   - ✅ Tất cả operations thành công HOẶC tất cả fail
   - ✅ Không có race condition

2. **Stock Validation:**
   - ✅ Check stock trước khi update
   - ✅ Group items by productId (nếu cùng product xuất hiện nhiều lần)
   - ✅ Throw exception nếu không đủ stock

3. **Stock Reduction:**
   - ✅ Giảm quantity của từng product
   - ✅ Update `updatedAt` timestamp

4. **Order Creation:**
   - ✅ Tạo order document trong cùng batch
   - ✅ Trả về order ID

**Luồng hoạt động:**
```
CreateOrderWithReduceStockUseCase(order)
  ↓
1. Group items by productId
   → {productId1: totalQty1, productId2: totalQty2, ...}
  ↓
2. For each product:
   → Fetch product từ repository
   → Validate: product.quantity >= totalQty
   → Calculate: newQuantity = product.quantity - totalQty
   → Add batch.update(product, {quantity: newQuantity})
  ↓
3. Create order document
   → Add batch.set(order)
  ↓
4. Commit batch
   → ALL operations succeed OR ALL fail
  ↓
Return orderId
```

**Lợi ích:**
- ✅ **Data consistency**: Không có order mà không giảm stock
- ✅ **No race condition**: Batch write là atomic
- ✅ **Stock validation**: Check trước khi commit

##### **3. GetOrdersByUserIdUseCase** (`domain/usecases/get_orders_by_user_id.dart`)

```dart
class GetOrdersByUserIdUseCase {
  final IOrderRepository _repository;
  
  Future<List<Order>> call(String userId) {
    return _repository.getOrdersByUserId(userId);
  }
}
```

**Nhiệm vụ:**
- Lấy tất cả orders của user
- Sắp xếp mới nhất trước (trong datasource)

##### **4. GetOrderByIdUseCase** (`domain/usecases/get_order_by_id.dart`)

```dart
class GetOrderByIdUseCase {
  final IOrderRepository _repository;
  
  Future<Order?> call(String orderId) {
    return _repository.getOrderById(orderId);
  }
}
```

**Nhiệm vụ:**
- Lấy order theo ID
- Trả về null nếu không tìm thấy

---

### 2. 💾 DATA LAYER - Firebase Integration

#### **OrderModel** (`data/models/order_model.dart`)

```dart
class OrderModel extends Order {
  // Extends Order entity, thêm serialization methods
}
```

**Nhiệm vụ:**
- ✅ **fromFirestore()**: Convert Firestore DocumentSnapshot → OrderModel
- ✅ **toFirestore()**: Convert OrderModel → Map<String, dynamic>
- ✅ **fromEntity()**: Convert Order entity → OrderModel
- ✅ **toEntity()**: Convert OrderModel → Order entity

**Firestore structure:**
```json
{
  "id": "order123",
  "userId": "user456",
  "customerName": "Nguyễn Văn A",
  "customerEmail": "a@example.com",
  "items": [
    {
      "productId": "prod1",
      "productName": "Áo sơ mi",
      "productImageUrl": "https://...",
      "quantity": 2,
      "price": 199000,
      "color": "Đỏ",
      "size": "M"
    }
  ],
  "totalAmount": 398000,
  "createdAt": Timestamp,
  "status": "PROCESSING"
}
```

**Đặc biệt:**
- Items được lưu như array of maps
- Status lưu dạng string, parse về enum khi đọc
- Timestamp conversion cho createdAt

#### **OrderRemoteDataSource** (`data/datasources/order_datasource.dart`)

Sử dụng **generic FirebaseRemoteDS** pattern:

```dart
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseRemoteDS<OrderModel> _remoteSource;
  final CollectionReference _ordersCollection = 
      FirebaseFirestore.instance.collection('orders');
  
  OrderRemoteDataSourceImpl()
      : _remoteSource = FirebaseRemoteDS<OrderModel>(
          collectionName: 'orders',
          fromFirestore: (doc) => OrderModel.fromFirestore(doc),
          toFirestore: (model) => model.toFirestore(),
        );
}
```

**Các operations:**

1. **createOrder:**
```dart
Future<String> createOrder(OrderModel order) async {
  return await _remoteSource.add(order);
}
```

2. **getOrdersByUserId:**
```dart
Future<List<OrderModel>> getOrdersByUserId(String userId) async {
  final snapshot = await _ordersCollection
      .where('userId', isEqualTo: userId)
      .get();
  
  final orders = snapshot.docs
      .map((doc) => OrderModel.fromFirestore(doc))
      .toList();
  
  // Sort by createdAt descending locally
  orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  return orders;
}
```

**Đặc biệt:**
- ✅ Filter by userId trong Firestore
- ✅ Sort locally (Firestore doesn't support sort + filter together without index)

3. **getOrderById:**
```dart
Future<OrderModel?> getOrderById(String orderId) async {
  return await _remoteSource.getById(orderId);
}
```

4. **updateOrderStatus:**
```dart
Future<void> updateOrderStatus(String orderId, String status) async {
  await _ordersCollection.doc(orderId).update({'status': status});
}
```

5. **getAllOrders (Stream):**
```dart
Stream<List<OrderModel>> getAllOrders() {
  return _ordersCollection
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList());
}
```

**Đặc biệt:**
- ✅ Real-time stream cho admin
- ✅ Auto-update khi có order mới hoặc status thay đổi

#### **OrderRepositoryImpl** (`data/repository/order_repository_impl.dart`)

**Adapter pattern** - Kết nối Domain và Data layer:

```dart
class OrderRepositoryImpl implements IOrderRepository {
  final OrderRemoteDataSource _dataSource;
  
  @override
  Future<String> createOrder(Order order) async {
    final orderModel = OrderModel.fromEntity(order);
    return await _dataSource.createOrder(orderModel);
  }
  
  @override
  Future<List<Order>> getOrdersByUserId(String userId) async {
    final models = await _dataSource.getOrdersByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }
  
  // ... other methods
}
```

**Nhiệm vụ:**
- ✅ Convert Order entity → OrderModel
- ✅ Convert OrderModel → Order entity
- ✅ Abstract domain layer khỏi data layer details

---

### 3. 🎨 PRESENTATION LAYER - UI Screens

#### **A. MyOrderScreen** (`presentation/my_order_screen.dart`)

**Chức năng:**
- Hiển thị danh sách orders của user
- Tab bar để filter theo status (Delivery, Processing, Cancelled)
- Refresh button
- Navigate to order detail

**State Management:**
```dart
class _MyOrderScreenState extends State<MyOrderScreen> {
  late final TabController _tabController;
  List<Order> _allOrders = [];
  bool _isLoading = true;
  
  // Computed getters
  List<Order> get deliveryOrders =>
      _allOrders.where((o) => o.status == OrderStatus.delivery).toList();
  
  List<Order> get processingOrders =>
      _allOrders.where((o) => o.status == OrderStatus.processing).toList();
  
  List<Order> get cancelledOrders =>
      _allOrders.where((o) => o.status == OrderStatus.cancelled).toList();
}
```

**Luồng load orders:**
```
initState()
  → _loadOrders()
    → Get AuthBloc state
      → If AuthAuthenticated:
        → GetOrdersByUserIdUseCase(user.id)
          → IOrderRepository.getOrdersByUserId()
            → OrderRemoteDataSource.getOrdersByUserId()
              → Firestore query: where('userId', isEqualTo: userId)
                → Sort by createdAt descending
                  → Return List<Order>
                    → setState(_allOrders = orders)
```

**UI Structure:**
```
Scaffold
  ├── AppBar
  │   ├── Title: "Đơn hàng của tôi"
  │   └── Refresh button
  ├── TabBar (Segmented style)
  │   ├── "Đang giao" (Delivery)
  │   ├── "Đang xử lý" (Processing)
  │   └── "Đã hủy" (Cancelled)
  └── TabBarView
      ├── _OrderList(deliveryOrders)
      ├── _OrderList(processingOrders)
      └── _OrderList(cancelledOrders)
```

**OrderCard Widget:**
- Order ID (8 chars)
- Tracking number (ORD + 8 chars)
- Total quantity
- Total amount
- Created date
- Status badge (colored)
- "CHI TIẾT" button → Navigate to OrderDetailScreen

**Status Colors:**
- Processing: Orange (AppColors.saleHot)
- Delivery: Green (AppColors.success)
- Cancelled: Red (AppColors.error)

#### **B. OrderDetailScreen** (`presentation/order_detail_screen.dart`)

**Chức năng:**
- Hiển thị chi tiết order
- Order items với images
- Summary (total quantity, total amount)

**State Management:**
```dart
class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _error;
}
```

**Luồng load order:**
```
initState()
  → _loadOrder()
    → GetOrderByIdUseCase(orderId)
      → IOrderRepository.getOrderById()
        → OrderRemoteDataSource.getOrderById()
          → Firestore: get document by ID
            → Return Order
              → setState(_order = order)
```

**UI Structure:**
```
SingleChildScrollView
  ├── Order Status Card
  │   ├── Order ID
  │   ├── Status badge
  │   └── Created date
  ├── Order Items Section
  │   └── For each item:
  │       ├── Product image
  │       ├── Product name
  │       ├── Color/Size (if available)
  │       ├── Quantity
  │       └── Total price
  └── Summary Card
      ├── Total quantity
      └── Total amount
```

**OrderItem Display:**
- Product image (70x70, rounded corners)
- Product name
- Color/Size badges (if available)
- Quantity: "x2"
- Total price (item.price * item.quantity)

---

## 🔑 ĐIỂM CẦN LƯU Ý QUAN TRỌNG

### 1. ⚠️ Atomic Transaction Pattern

**Vấn đề:**
- Cần đảm bảo: Tạo order VÀ giảm stock phải cùng lúc
- Không được có order mà không giảm stock
- Không được giảm stock mà không tạo order

**Solution:**
- ✅ Dùng Firestore batch write
- ✅ Tất cả operations trong một batch
- ✅ Commit: ALL or NOTHING

**Implementation:**
```dart
final batch = FirebaseFirestore.instance.batch();

// Add all updates to batch
batch.update(productRef, {...});
batch.set(orderRef, orderData);

// Commit - atomic
await batch.commit();
```

**Lợi ích:**
- ✅ Data consistency
- ✅ No partial updates
- ✅ Handle failures gracefully

### 2. 📦 Stock Management

**Cơ chế:**
1. **Group by productId:**
   - Nếu cùng product xuất hiện nhiều lần trong order
   - Tính tổng quantity cần giảm

2. **Stock Validation:**
   - Check stock trước khi update
   - Throw exception nếu không đủ

3. **Stock Reduction:**
   - Giảm quantity trong batch update
   - Update `updatedAt` timestamp

**Example:**
```dart
Order items:
  - Product A x 2
  - Product B x 1
  - Product A x 1  // Same product again

Group by productId:
  - Product A: 2 + 1 = 3
  - Product B: 1

Check stock:
  - Product A: 5 >= 3 ✅
  - Product B: 2 >= 1 ✅

Reduce:
  - Product A: 5 - 3 = 2
  - Product B: 2 - 1 = 1
```

### 3. 💰 Price Snapshot

**Vấn đề:**
- Product price có thể thay đổi sau khi user order
- Cần lưu giá tại thời điểm mua

**Solution:**
- ✅ OrderItem lưu `price` (double)
- ✅ Snapshot tại thời điểm tạo order
- ✅ Không update khi product price thay đổi

**Implementation:**
```dart
// Tạo OrderItem từ cart
final orderItems = cartItems.map((item) {
  return OrderItem(
    productId: item.product.id,
    productName: item.product.name,
    price: item.product.price,  // Snapshot giá hiện tại
    quantity: item.quantity,
    // ...
  );
}).toList();
```

**Lợi ích:**
- ✅ Historical accuracy
- ✅ Fair pricing
- ✅ No disputes

### 4. 📊 Order Status Management

**Status flow:**
```
processing → delivery → (completed - not implemented yet)
     ↓
cancelled
```

**Current statuses:**
- `processing`: Đang xử lý (mới tạo)
- `delivery`: Đang giao hàng
- `cancelled`: Đã hủy

**Future enhancements:**
- `completed`: Đã hoàn thành
- `refunded`: Đã hoàn tiền
- `returned`: Đã trả hàng

### 5. 🔍 Query Performance

**getOrdersByUserId:**
- Filter by userId trong Firestore
- Sort locally (vì Firestore không support sort + filter without composite index)

**Optimization:**
- ✅ Index trên `userId` field
- ✅ Limit results (có thể thêm pagination sau)

**getAllOrders (Admin):**
- ✅ Stream real-time
- ✅ Sort by createdAt descending
- ⚠️ Có thể tốn bandwidth nếu nhiều orders

### 6. 🔄 Integration với Bag Feature

**Luồng checkout:**
```
PaymentScreen
  ↓
1. Create Order from cart items
   → Map cart items → order items
   → Snapshot product info (name, price, image)
  ↓
2. CreateOrderWithReduceStockUseCase
   → Atomic: Create order + Reduce stock
  ↓
3. Clear product cache
   → ProductCacheService.instance.clearCache()
  ↓
4. Clear cart
   → bagDataSource.clearCart(userId)
  ↓
5. Navigate to success screen
```

**Code:**
```dart
// In PaymentScreen
final orderItems = widget.cartItems.map((item) {
  return OrderItem(
    productId: item.cartItem.productId,
    productName: item.product.name,
    productImageUrl: item.product.imageUrl,
    quantity: item.cartItem.quantity,
    price: item.product.price,  // Snapshot
    color: item.cartItem.color,
    size: item.cartItem.size,
  );
}).toList();

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

// Create order + reduce stock
final createOrderUseCase = sl<CreateOrderWithReduceStockUseCase>();
final orderId = await createOrderUseCase(order);

// Clear cache
ProductCacheService.instance.clearCache();

// Clear cart
await bagDataSource.clearCart(authState.user.id);
```

### 7. 🎨 UI/UX Features

**Tab-based filtering:**
- ✅ Segmented tab bar style
- ✅ Filter orders by status
- ✅ Smooth transitions

**Order card:**
- ✅ Tracking number (easy to remember)
- ✅ Status badge với color coding
- ✅ Quick actions (view details)

**Order detail:**
- ✅ Full order information
- ✅ Item images
- ✅ Price breakdown
- ✅ Status tracking

### 8. 🔐 Security Considerations

**Firestore Security Rules:**
- ⚠️ Phải setup rules để:
  - Users chỉ đọc orders của chính họ
  - Users không thể modify orders
  - Admin có thể read/write all orders

**Example rules:**
```javascript
match /orders/{orderId} {
  // User chỉ đọc orders của chính họ
  allow read: if request.auth != null && 
              resource.data.userId == request.auth.uid;
  
  // Chỉ admin hoặc system (batch) mới được write
  allow write: if false;  // Hoặc check admin role
}
```

**Validation:**
- ✅ Stock check trước khi create order
- ✅ User ID validation (từ AuthBloc)

---

## 💡 ĐIỂM HAY CỦA KIẾN TRÚC

### 1. 🏗️ Clean Architecture Benefits

- **Separation of Concerns**: Business logic tách biệt hoàn toàn
- **Testability**: Dễ test từng layer độc lập
- **Flexibility**: Dễ thay đổi implementation

### 2. ⚡ Atomic Transaction Pattern

**Firestore batch write:**
- ✅ Guaranteed consistency
- ✅ No race conditions
- ✅ Simplified error handling

### 3. 📸 Data Snapshot Pattern

**Price & Product Info:**
- ✅ Historical accuracy
- ✅ Fair pricing
- ✅ No dependencies on current product data

### 4. 🎯 Type-Safe Status

**Enum instead of string:**
- ✅ Compile-time safety
- ✅ Better IDE support
- ✅ Easy refactoring

### 5. 🔄 Integration Patterns

**Use case reuse:**
- ✅ CreateOrderWithReduceStockUseCase được dùng trong Payment
- ✅ Single source of truth
- ✅ Consistent behavior

---

## 🚀 CÁC ĐIỂM CÓ THỂ CẢI THIỆN

### 1. 📄 Pagination

**Hiện tại:**
- Load tất cả orders một lần

**Có thể cải thiện:**
- Pagination với limit/offset
- Infinite scroll
- Better performance với nhiều orders

### 2. 🔍 Search & Filter

**Có thể thêm:**
- Search by order ID
- Filter by date range
- Filter by amount range

### 3. 📊 Order Analytics

**Có thể thêm:**
- Order history chart
- Total spent
- Most ordered products
- Average order value

### 4. 🔄 Status Updates

**Hiện tại:**
- Manual status update (admin)

**Có thể cải thiện:**
- Auto status transitions
- Status change notifications
- Status timeline/history

### 5. 💰 Payment Integration

**Hiện tại:**
- No payment gateway

**Có thể thêm:**
- Payment processing
- Payment status tracking
- Refund handling

### 6. 📧 Notifications

**Có thể thêm:**
- Order confirmation email
- Status change notifications
- Delivery updates

### 7. 🚚 Shipping Integration

**Có thể thêm:**
- Shipping address management
- Shipping cost calculation
- Tracking number integration

### 8. 🔄 Order Cancellation

**Hiện tại:**
- Status có cancelled nhưng chưa có flow

**Có thể thêm:**
- Cancel order by user (within timeframe)
- Restock when cancelled
- Refund processing

### 9. ⚡ Real-time Updates

**Có thể thêm:**
- Stream orders for user (real-time status updates)
- Push notifications on status change

### 10. 🧪 Testing

**Nên có:**
- Unit tests cho use cases
- Integration tests cho batch operations
- UI tests cho screens

---

## 📊 TÓM TẮT LUỒNG HOẠT ĐỘNG

### **User tạo order (từ Bag/Payment):**
```
1. User click "Thanh toán" trong PaymentScreen
2. Create Order object từ cart items
   → Map cart items → order items
   → Snapshot product info (name, price, image)
3. CreateOrderWithReduceStockUseCase(order)
   → Group items by productId
   → For each product:
     → Fetch product
     → Validate stock
     → Add batch.update(product, reduce quantity)
   → Create order document
   → batch.commit() (atomic)
4. Clear product cache
5. Clear cart
6. Navigate to success screen
```

### **User xem danh sách orders:**
```
1. Navigate to MyOrderScreen
2. initState() → _loadOrders()
3. Get AuthBloc state → user.id
4. GetOrdersByUserIdUseCase(user.id)
   → IOrderRepository.getOrdersByUserId()
     → Firestore: where('userId', isEqualTo: userId)
       → Sort by createdAt descending
         → Return List<Order>
5. Filter by status (tabs):
   → deliveryOrders
   → processingOrders
   → cancelledOrders
6. Display orders in TabBarView
```

### **User xem order detail:**
```
1. User click "CHI TIẾT" trên order card
2. Navigate to OrderDetailScreen(orderId)
3. initState() → _loadOrder()
4. GetOrderByIdUseCase(orderId)
   → IOrderRepository.getOrderById()
     → Firestore: get document by ID
       → Return Order
5. Display order details:
   → Order status card
   → Order items list
   → Summary card
```

### **Admin quản lý orders:**
```
1. Admin screen (không trong feature này, nhưng có use case)
2. getAllOrders() stream
   → Real-time updates
   → Sort by createdAt descending
3. updateOrderStatus(orderId, status)
   → Update status in Firestore
     → Stream auto-update
```

---

## ✅ CHECKLIST ĐỂ VẬN HÀNH TỐT

- [ ] Firestore security rules setup đúng
- [ ] Firestore index trên `userId` field (cho getOrdersByUserId)
- [ ] Stock validation hoạt động đúng
- [ ] Batch write hoạt động atomic
- [ ] Price snapshot đúng tại thời điểm order
- [ ] Product cache được clear sau khi tạo order
- [ ] Cart được clear sau khi tạo order
- [ ] Error handling đầy đủ
- [ ] Status enum conversion đúng
- [ ] UI hiển thị đúng format (date, amount)

---

## 🎓 KẾT LUẬN

Feature Orders được thiết kế tốt với:
- ✅ Clean Architecture rõ ràng
- ✅ Atomic transaction pattern (CreateOrderWithReduceStockUseCase)
- ✅ Price snapshot pattern
- ✅ Type-safe status enum
- ✅ Good integration với Bag feature

**Điểm mạnh:**
- Atomic transaction đảm bảo data consistency
- Price snapshot đảm bảo fairness
- Type-safe status management
- Good separation of concerns

**Có thể cải thiện:**
- Pagination
- Search & filter
- Real-time updates cho user
- Payment integration
- Shipping integration
- Order cancellation flow
- Analytics

---

**Tác giả:** AI Assistant  
**Ngày:** 2024

