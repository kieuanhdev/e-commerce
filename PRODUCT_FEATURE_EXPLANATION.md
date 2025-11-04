# 📦 GIẢI THÍCH CHI TIẾT FEATURE PRODUCT

## 🏗️ KIẾN TRÚC TỔNG QUAN

Feature Product được xây dựng theo **Clean Architecture** với 3 lớp chính:

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (UI)             │
│  ┌──────────────┬────────────────────┐  │
│  │ Admin Pages  │ Customer Pages     │  │
│  │ Widgets      │ Widgets            │  │
│  └──────────────┴────────────────────┘  │
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

---

## 📁 CẤU TRÚC THƯ MỤC

```
lib/features/products/
├── data/                          # DATA LAYER
│   ├── datasources/
│   │   └── product_remote_datasource.dart  # Firestore operations
│   ├── models/
│   │   └── product_model.dart              # ProductModel extends Product
│   └── repositories/
│       └── product_repository_impl.dart     # Implementation của repository
│
├── domain/                        # DOMAIN LAYER
│   ├── entities/
│   │   └── product.dart                    # Product entity (business object)
│   ├── repositories/
│   │   └── product_repository.dart        # Repository interface (abstraction)
│   ├── usecases/                          # Business logic operations
│   │   ├── get_products.dart
│   │   ├── add_product.dart
│   │   ├── update_product.dart
│   │   ├── delete_product.dart
│   │   └── upload_product_image.dart
│   └── services/
│       └── product_cache_service.dart      # Cache service (Singleton)
│
└── presentation/                  # PRESENTATION LAYER
    ├── admin/                             # Admin UI
    │   └── pages/
    │       ├── product_list_page.dart
    │       └── product_form_page.dart
    └── customer/                          # Customer UI
        ├── pages/
        │   ├── product_list.dart
        │   └── product_detail_page.dart
        └── widgets/
            ├── product_card.dart
            ├── product_grid_sliver.dart
            ├── product_image_carousel.dart
            ├── product_pagination.dart
            ├── product_popular_section.dart
            └── buy_now_sheet.dart
```

---

## 🔄 LUỒNG HOẠT ĐỘNG CHI TIẾT

### 1. 🎯 DOMAIN LAYER - Trái tim của hệ thống

#### **Product Entity** (`domain/entities/product.dart`)
```dart
class Product {
  final String id;
  String name;
  double price;
  bool isVisible;          // Quyết định sản phẩm có hiển thị với customer không
  int quantity;
  int lowStockThreshold;   // Ngưỡng cảnh báo tồn kho thấp
  String? imageUrl;
  String shortDescription;
  String longDescription;
  String? categoryId;
  DateTime createdAt;
  DateTime? updatedAt;
}
```

**Đặc điểm:**
- ✅ Pure Dart class, không phụ thuộc vào framework hay database
- ✅ Chứa business rules và validation logic
- ✅ Có thể mutate (thay đổi giá trị) để phù hợp với business logic

#### **ProductRepository Interface** (`domain/repositories/product_repository.dart`)
```dart
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(String id);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<String> uploadProductImage(XFile imageFile);
}
```

**Đặc điểm:**
- ✅ Abstract class - định nghĩa contract, không có implementation
- ✅ Domain layer chỉ biết về interface này, không biết về Firebase/Cloudinary
- ✅ Dễ dàng thay đổi implementation (có thể switch sang MongoDB, API REST, etc.)

#### **Use Cases** - Business Operations

Mỗi use case đại diện cho một hành động business cụ thể:

1. **GetProducts**: Lấy danh sách tất cả sản phẩm
2. **AddProduct**: Thêm sản phẩm mới
3. **UpdateProduct**: Cập nhật thông tin sản phẩm
4. **DeleteProduct**: Xóa sản phẩm
5. **UploadProductImage**: Upload ảnh lên Cloudinary

**Pattern:** Mỗi use case chỉ làm MỘT việc duy nhất (Single Responsibility)

#### **ProductCacheService** (`domain/services/product_cache_service.dart`)

**Singleton pattern** - Quản lý cache toàn cục:

```dart
class ProductCacheService {
  static ProductCacheService? _instance;
  static ProductCacheService get instance => _instance ??= ProductCacheService._();
  
  List<Product>? _cachedProducts;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  bool _isLoading = false;
}
```

**Cơ chế hoạt động:**
1. ✅ **Cache 5 phút**: Data được cache trong 5 phút, tránh load lại nhiều lần
2. ✅ **Prevent race condition**: Nếu đang loading, các request khác sẽ đợi
3. ✅ **Force refresh**: Có option để force refresh bỏ qua cache
4. ✅ **Background refresh**: Tự động refresh nếu cache > 2 phút (trong `product_list.dart`)

**Lợi ích:**
- Giảm số lượng request tới Firebase
- Cải thiện performance
- Tiết kiệm chi phí Firebase
- Trải nghiệm người dùng mượt mà hơn

---

### 2. 💾 DATA LAYER - Kết nối với thế giới bên ngoài

#### **ProductModel** (`data/models/product_model.dart`)

```dart
class ProductModel extends Product {
  // Extends Product entity, thêm serialization methods
}
```

**Nhiệm vụ:**
- ✅ **fromFirestore()**: Convert Firestore DocumentSnapshot → ProductModel
- ✅ **toJson()**: Convert ProductModel → Map<String, dynamic> (để lưu vào Firestore)
- ✅ **fromEntity()**: Convert Product entity → ProductModel
- ✅ **toEntity()**: Convert ProductModel → Product entity

**Đặc biệt:**
- Xử lý type safety khi parse từ Firestore (Timestamp, null safety)
- Có error handling khi parse data không hợp lệ
- Xử lý default values khi data thiếu

#### **ProductRemoteDataSource** (`data/datasources/product_remote_datasource.dart`)

Sử dụng **generic FirebaseRemoteDS** pattern:

```dart
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseRemoteDS<ProductModel> _remoteSource;
  
  ProductRemoteDataSourceImpl()
    : _remoteSource = FirebaseRemoteDS<ProductModel>(
        collectionName: 'products',
        fromFirestore: (doc) => ProductModel.fromFirestore(doc),
        toFirestore: (model) => model.toJson(),
      );
}
```

**Cơ chế FirebaseRemoteDS:**
1. ✅ **Timeout handling**: 15 giây timeout, fallback về cache nếu timeout
2. ✅ **Cache-first strategy**: Ưu tiên dùng cache, sau đó mới server
3. ✅ **Error handling**: Xử lý TimeoutException, FirebaseException
4. ✅ **Generic pattern**: Có thể tái sử dụng cho các collection khác (users, orders, etc.)

**Các operations:**
- `getAll()`: Lấy tất cả documents từ collection 'products'
- `getProduct(id)`: Lấy một document theo ID
- `add(product)`: Thêm document mới (Firebase tự generate ID)
- `update(id, product)`: Update document theo ID
- `delete(id)`: Xóa document theo ID

#### **ProductRepositoryImpl** (`data/repositories/product_repository_impl.dart`)

**Adapter pattern** - Kết nối Domain và Data layer:

```dart
class ProductRepositoryImpl extends ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final CloudinaryService cloudinaryService;
  
  @override
  Future<List<Product>> getProducts() async {
    List<ProductModel> productModels = await remoteDataSource.getAll();
    return productModels.map((model) => model.toEntity()).toList();
  }
}
```

**Nhiệm vụ:**
- ✅ Convert ProductModel → Product entity (vì Domain không biết về Model)
- ✅ Xử lý upload image qua CloudinaryService
- ✅ Xử lý exceptions và convert sang domain exceptions

---

### 3. 🎨 PRESENTATION LAYER - Giao diện người dùng

#### **A. ADMIN UI** - Quản lý sản phẩm

##### **ProductListPage** (`presentation/admin/pages/product_list_page.dart`)

**Chức năng:**
1. ✅ Hiển thị danh sách tất cả sản phẩm (cả visible và hidden)
2. ✅ Search sản phẩm theo tên
3. ✅ Filter theo category
4. ✅ Toggle visibility (ẩn/hiện sản phẩm)
5. ✅ Edit sản phẩm
6. ✅ Delete sản phẩm
7. ✅ Thêm sản phẩm mới

**Luồng hoạt động:**
```
initState() 
  → _loadProducts()
    → GetProducts useCase
      → ProductRepository.getProducts()
        → ProductRemoteDataSource.getAll()
          → FirebaseRemoteDS.getAll()
            → Firestore collection('products').get()
```

**State management:**
- Dùng StatefulWidget với local state
- Không dùng BLoC/Provider (có thể cải thiện sau)

##### **ProductFormPage** (`presentation/admin/pages/product_form_page.dart`)

**Chức năng:**
- Form để thêm/sửa sản phẩm
- Upload ảnh từ Camera hoặc Gallery
- Validation form
- Preview ảnh trước khi upload

**Luồng upload ảnh:**
```
Chọn ảnh (Camera/Gallery)
  → ImagePicker.pickImage()
    → XFile (local file)
      → UploadProductImage useCase
        → ProductRepository.uploadProductImage()
          → CloudinaryService.uploadProductImage()
            → HTTP POST to Cloudinary API
              → Signed Upload với signature
                → Trả về secure URL
                  → Lưu URL vào Firestore
```

**Đặc biệt:**
- Image compression: quality 85%, maxWidth/Height 1200px
- Preview ảnh bằng Uint8List (memory) trước khi upload
- Loading state khi đang upload

#### **B. CUSTOMER UI** - Xem và mua sản phẩm

##### **ProductList** (`presentation/customer/pages/product_list.dart`)

**Chức năng:**
- Hiển thị danh sách sản phẩm với pagination (12 items/page)
- Search sản phẩm
- Chỉ hiển thị sản phẩm có `isVisible == true`
- Background refresh khi cache > 2 phút

**Luồng load products:**
```
initState()
  → _loadProducts()
    → Check cache (ProductCacheService.isCacheValid())
      → Nếu cache valid:
        → Dùng cached data ngay
        → Background refresh nếu cache > 2 phút
      → Nếu cache invalid:
        → ProductCacheService.getProducts()
          → GetProducts useCase
            → ... (như trên)
              → Cache lại data
```

**Pagination:**
- Client-side pagination (12 items/page)
- Scroll to top khi chuyển trang
- CustomScrollView với Slivers để performance tốt

##### **ProductDetailPage** (`presentation/customer/pages/product_detail_page.dart`)

**Chức năng:**
- Hiển thị chi tiết sản phẩm
- Image carousel (nếu có nhiều ảnh)
- Thông tin: giá, mô tả, số lượng tồn kho, ngày tạo/cập nhật
- Button "Mua ngay" → mở BuyNowSheet

**Đặc biệt:**
- Nhận data qua constructor (stateless-friendly)
- Có thể cải thiện bằng cách fetch real-time từ Firestore

##### **BuyNowSheet** (`presentation/customer/widgets/buy_now_sheet.dart`)

**Chức năng:**
- Modal bottom sheet để chọn số lượng và thêm vào giỏ hàng
- Quantity control (+/-)
- Tính tổng tiền real-time
- Tích hợp với BagBloc để thêm vào giỏ hàng

**Luồng thêm vào giỏ:**
```
User chọn quantity → Click "Thêm vào giỏ"
  → Check AuthBloc (đã đăng nhập?)
    → Nếu chưa: Show error "Vui lòng đăng nhập"
    → Nếu rồi:
      → BagBloc.add(AddToCart(
          userId: authState.user.id,
          productId: widget.productId,
          quantity: quantity
        ))
      → BagBloc xử lý → BagItemAdded state
      → Close sheet + Show success snackbar
```

##### **ProductCard** (`presentation/customer/widgets/product_card.dart`)

**Reusable widget** để hiển thị card sản phẩm:
- Image với error handling
- Title, description, price
- Tap để navigate tới ProductDetailPage

---

## 🔑 ĐIỂM CẦN LƯU Ý QUAN TRỌNG

### 1. ⚠️ Visibility Management

**Vấn đề:**
- Admin có thể ẩn/hiện sản phẩm bằng `isVisible`
- Customer UI phải filter `isVisible == true` khi hiển thị

**Implementation:**
```dart
// Trong ProductList (_loadProducts)
final visible = items.where((p) => p.isVisible == true).toList();
```

**Lưu ý:**
- ❌ Không được để customer thấy sản phẩm ẩn
- ✅ Admin có thể thấy cả visible và hidden (để quản lý)

### 2. 🗄️ Cache Strategy

**Cơ chế cache 2 tầng:**

1. **ProductCacheService** (in-memory, 5 phút)
2. **Firestore offline cache** (tự động bởi Firebase SDK)

**Luồng cache:**
```
Request → ProductCacheService (memory)
  → Valid? → Return cached
  → Invalid? → GetProducts useCase
    → FirebaseRemoteDS.getAll()
      → Firestore cache (nếu có) → Return
      → Firestore server → Return + Cache
```

**Khi nào clear cache?**
- Sau khi admin thêm/sửa/xóa sản phẩm → Nên clear cache
- Hiện tại chưa có clear cache sau CRUD operations (CÓ THỂ CẢI THIỆN)

### 3. 📸 Image Upload với Cloudinary

**Quy trình:**
1. User chọn ảnh → ImagePicker
2. Preview ảnh (local, chưa upload)
3. Click save → Upload lên Cloudinary
4. Nhận secure URL
5. Lưu URL vào Firestore

**Đặc biệt:**
- **Signed Upload**: Dùng API key + secret + signature (an toàn)
- **Image optimization**: Compress trước khi upload (quality 85%)
- **Timeout**: 60 giây timeout cho upload
- **Error handling**: Hiển thị message rõ ràng nếu upload fail

**Lưu ý:**
- Ảnh được lưu trong folder `products/` trên Cloudinary
- Public ID format: `product_{timestamp}`

### 4. 🔄 Error Handling

**Các layer xử lý error:**

1. **FirebaseRemoteDS**: 
   - TimeoutException → Fallback về cache
   - FirebaseException → Print và rethrow

2. **ProductModel**:
   - FormatException khi parse Firestore data
   - Default values nếu data thiếu

3. **Presentation**:
   - Try-catch trong async operations
   - SnackBar để hiển thị lỗi cho user

**Có thể cải thiện:**
- Tạo custom exceptions trong Domain layer
- Error handling pattern nhất quán hơn

### 5. 🎯 Separation of Concerns

**Đúng:**
- ✅ Domain không biết về Firebase/Cloudinary
- ✅ Presentation không biết về implementation details
- ✅ Use cases đơn giản, chỉ gọi repository

**Có thể cải thiện:**
- ❌ Admin pages tự tạo dependencies (nên dùng DI)
- ❌ Customer pages cũng tự tạo dependencies
- → Nên inject qua constructor hoặc DI container

### 6. ⚡ Performance Optimizations

**Đã có:**
- ✅ ProductCacheService (tránh redundant requests)
- ✅ Firestore offline cache
- ✅ Pagination (12 items/page)
- ✅ CustomScrollView với Slivers
- ✅ Image compression trước upload

**Có thể thêm:**
- Image caching với cached_network_image
- Lazy loading images
- Debounce search input

### 7. 🔐 Security Considerations

**Hiện tại:**
- ✅ Cloudinary signed upload (an toàn)
- ✅ Firestore security rules (cần check trong Firebase console)

**Cần lưu ý:**
- Firestore security rules phải đảm bảo:
  - Admin mới được write products
  - Customer chỉ được read products (isVisible == true)
- Cloudinary credentials trong .env (không commit vào git)

---

## 💡 ĐIỂM HAY CỦA KIẾN TRÚC

### 1. 🏗️ Clean Architecture Benefits

- **Testability**: Dễ test từng layer độc lập
- **Maintainability**: Dễ maintain, code rõ ràng
- **Flexibility**: Dễ thay đổi implementation (ví dụ: switch từ Firebase sang REST API)

### 2. 🎯 Generic Patterns

**FirebaseRemoteDS Generic:**
- Có thể reuse cho users, orders, categories, etc.
- Chỉ cần cung cấp fromFirestore/toFirestore functions

### 3. 💾 Cache Strategy

**ProductCacheService Singleton:**
- Share cache across toàn app
- Tránh duplicate requests
- Smart background refresh

### 4. 🔄 Repository Pattern

**Abstraction:**
- Domain không phụ thuộc vào implementation
- Dễ mock để test
- Dễ switch data source

---

## 🚀 CÁC ĐIỂM CÓ THỂ CẢI THIỆN

### 1. Dependency Injection

**Vấn đề:**
```dart
// Hiện tại: Tự tạo dependencies
late final ProductRemoteDataSource _remote = ProductRemoteDataSourceImpl();
late final CloudinaryService _cloudinary = CloudinaryService();
late final ProductRepositoryImpl _repo = ProductRepositoryImpl(_remote, _cloudinary);
```

**Nên:**
```dart
// Inject qua constructor
class ProductListPage extends StatefulWidget {
  final ProductRepository repository;
  final GetProducts getProducts;
  // ...
}
```

### 2. State Management

**Hiện tại:** StatefulWidget với local state

**Có thể dùng:**
- BLoC pattern (như BagBloc)
- Riverpod
- GetX

**Lợi ích:**
- Separation of UI và business logic
- Easier testing
- Better state management

### 3. Error Handling

**Tạo custom exceptions:**
```dart
// domain/utils/exceptions.dart
class ProductNotFoundException implements Exception {}
class ProductUploadFailedException implements Exception {}
```

### 4. Clear Cache sau CRUD

**Thêm:**
```dart
// Sau khi add/update/delete
_cacheService.clearCache();
```

### 5. Real-time Updates

**Có thể dùng Firestore snapshots:**
```dart
FirebaseRemoteDS.watchAll() // Stream<List<Product>>
```

Để tự động update UI khi có thay đổi từ server.

---

## 📊 TÓM TẮT LUỒNG HOẠT ĐỘNG

### **Admin thêm sản phẩm:**
```
1. ProductFormPage
2. User điền form + chọn ảnh
3. Click Save
4. UploadProductImage → Cloudinary → URL
5. AddProduct useCase → ProductRepository.createProduct()
6. ProductRemoteDataSource.add() → Firestore
7. Success → Navigate back → ProductListPage reload
```

### **Customer xem danh sách:**
```
1. ProductList.initState()
2. Check cache (5 phút valid?)
   → Valid: Dùng cache + background refresh nếu > 2 phút
   → Invalid: Load từ Firebase
3. Filter isVisible == true
4. Apply search/filter
5. Pagination (12 items/page)
6. User tap ProductCard → Navigate to ProductDetailPage
```

### **Customer mua sản phẩm:**
```
1. ProductDetailPage → Click "Mua ngay"
2. Show BuyNowSheet (modal bottom sheet)
3. User chọn quantity
4. Click "Thêm vào giỏ"
5. Check AuthBloc (đăng nhập?)
6. BagBloc.add(AddToCart(...))
7. Success → Close sheet + SnackBar
```

---

## ✅ CHECKLIST ĐỂ VẬN HÀNH TỐT

- [ ] Firestore security rules đã setup đúng
- [ ] Cloudinary credentials trong .env
- [ ] Cache được clear sau CRUD operations (optional)
- [ ] Error messages user-friendly
- [ ] Images có fallback khi load fail
- [ ] Pagination hoạt động đúng
- [ ] Search/filter hoạt động đúng
- [ ] Visibility filter đúng (customer không thấy hidden products)

---

## 🎓 KẾT LUẬN

Feature Product được thiết kế theo Clean Architecture với:
- ✅ Separation of concerns rõ ràng
- ✅ Dễ test và maintain
- ✅ Cache strategy thông minh
- ✅ Error handling cơ bản
- ✅ Reusable patterns

**Điểm mạnh:**
- Kiến trúc sạch, dễ hiểu
- Generic patterns có thể reuse
- Cache strategy tốt

**Có thể cải thiện:**
- Dependency Injection
- State management pattern nhất quán
- Real-time updates
- Better error handling

---

**Tác giả:** AI Assistant  
**Ngày:** 2024

