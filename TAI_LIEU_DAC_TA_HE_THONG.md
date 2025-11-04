# 📋 TÀI LIỆU ĐẶC TẢ HỆ THỐNG
## HỆ THỐNG E-COMMERCE - SHOPPING CLOTHES

---

## 📑 MỤC LỤC

1. [Tổng quan hệ thống](#1-tổng-quan-hệ-thống)
2. [Kiến trúc hệ thống](#2-kiến-trúc-hệ-thống)
3. [Công nghệ sử dụng](#3-công-nghệ-sử-dụng)
4. [Các module chức năng](#4-các-module-chức-năng)
5. [Luồng hoạt động chính](#5-luồng-hoạt-động-chính)
6. [Dữ liệu và cơ sở dữ liệu](#6-dữ-liệu-và-cơ-sở-dữ-liệu)
7. [Bảo mật](#7-bảo-mật)
8. [Giao diện người dùng](#8-giao-diện-người-dùng)
9. [Triển khai và vận hành](#9-triển-khai-và-vận-hành)

---

## 1. TỔNG QUAN HỆ THỐNG

### 1.1. Mô tả hệ thống

**Hệ thống E-Commerce - Shopping Clothes** là một ứng dụng thương mại điện tử được xây dựng trên nền tảng Flutter, cho phép:

- **Khách hàng (Customer)**: Duyệt sản phẩm, thêm vào giỏ hàng, đặt hàng, quản lý đơn hàng
- **Quản trị viên (Admin)**: Quản lý sản phẩm, quản lý đơn hàng, quản lý khách hàng, xem thống kê

### 1.2. Mục tiêu hệ thống

- Cung cấp nền tảng mua sắm trực tuyến cho ngành thời trang
- Hỗ trợ quản lý hiệu quả cho admin
- Trải nghiệm người dùng mượt mà và hiện đại
- Đảm bảo tính bảo mật và an toàn dữ liệu

### 1.3. Phạm vi hệ thống

**Bao gồm:**
- ✅ Đăng ký/Đăng nhập (Email/Password, Google Sign In)
- ✅ Quản lý sản phẩm (CRUD)
- ✅ Giỏ hàng và thanh toán
- ✅ Quản lý đơn hàng
- ✅ Quản lý người dùng (Admin)
- ✅ Thống kê và báo cáo (Admin)

**Chưa bao gồm:**
- ⚠️ Thanh toán trực tuyến (Payment Gateway)
- ⚠️ Giao hàng và vận chuyển
- ⚠️ Đánh giá và review sản phẩm
- ⚠️ Mã giảm giá và khuyến mãi

---

## 2. KIẾN TRÚC HỆ THỐNG

### 2.1. Kiến trúc tổng thể

Hệ thống được xây dựng theo **Clean Architecture** với 3 lớp chính:

```
┌─────────────────────────────────────────────────┐
│         PRESENTATION LAYER (UI)                  │
│  ┌──────────┬──────────┬──────────┬──────────┐ │
│  │  Screens │ Widgets  │   BLoC   │ Routing  │ │
│  └──────────┴──────────┴──────────┴──────────┘ │
└─────────────────────────────────────────────────┘
                    ↓ ↑
┌─────────────────────────────────────────────────┐
│         DOMAIN LAYER (Business Logic)            │
│  ┌──────────┬──────────┬──────────┬─────────┐ │
│  │ Entities │ UseCases  │ Repository│ Services│ │
│  │          │           │ Interface│         │ │
│  └──────────┴──────────┴──────────┴─────────┘ │
└─────────────────────────────────────────────────┘
                    ↓ ↑
┌─────────────────────────────────────────────────┐
│         DATA LAYER (External Data)              │
│  ┌──────────┬──────────┬──────────┬─────────┐ │
│  │  Models  │ Data-    │ Repository│ Cloudinary│ │
│  │          │ sources  │ Impl     │ Service │ │
│  └──────────┴──────────┴──────────┴─────────┘ │
└─────────────────────────────────────────────────┘
```

### 2.2. Các lớp kiến trúc

#### **2.2.1. Presentation Layer (Lớp Giao diện)**

**Chức năng:**
- Hiển thị UI cho người dùng
- Xử lý tương tác người dùng
- Quản lý state với BLoC pattern
- Điều hướng (Routing) với GoRouter

**Thành phần:**
- **Screens**: Các màn hình chính của ứng dụng
- **Widgets**: Các component có thể tái sử dụng
- **BLoC**: Quản lý state (AuthBloc, BagBloc, SettingsBloc, etc.)
- **Routing**: GoRouter với role-based navigation

#### **2.2.2. Domain Layer (Lớp Nghiệp vụ)**

**Chức năng:**
- Chứa business logic thuần túy
- Không phụ thuộc vào framework hay database
- Định nghĩa entities và use cases

**Thành phần:**
- **Entities**: Các đối tượng nghiệp vụ (AppUser, Product, Order, CartItem)
- **Use Cases**: Các thao tác nghiệp vụ (LoginUseCase, AddToCartUseCase, etc.)
- **Repository Interfaces**: Định nghĩa contract cho data layer
- **Services**: Các dịch vụ nghiệp vụ (ProductCacheService)

#### **2.2.3. Data Layer (Lớp Dữ liệu)**

**Chức năng:**
- Kết nối với external data sources (Firebase, Cloudinary)
- Chuyển đổi giữa Models và Entities
- Xử lý serialization/deserialization

**Thành phần:**
- **Models**: Data models (UserModel, ProductModel, OrderModel)
- **Data Sources**: Firebase operations (FirebaseAuthDatasource, ProductRemoteDataSource)
- **Repository Implementations**: Triển khai repository interfaces
- **External Services**: CloudinaryService cho upload ảnh

### 2.3. State Management Pattern

**BLoC (Business Logic Component) Pattern:**

- **Events**: Các hành động từ UI
- **States**: Trạng thái của ứng dụng
- **BLoC**: Xử lý logic và chuyển đổi Events → States

**Các BLoC chính:**
- `AuthBloc`: Quản lý authentication state
- `BagBloc`: Quản lý shopping cart
- `SettingsBloc`: Quản lý cài đặt người dùng
- `CustomersBloc`: Quản lý danh sách khách hàng (Admin)
- `AdminOrdersBloc`: Quản lý đơn hàng (Admin)
- `OverviewBloc`: Quản lý thống kê (Admin)

### 2.4. Dependency Injection

**GetIt (Service Locator):**
- Đăng ký dependencies trong `di.dart`
- Singleton pattern cho repositories và services
- Factory pattern cho BLoCs và use cases

---

## 3. CÔNG NGHỆ SỬ DỤNG

### 3.1. Frontend Framework

- **Flutter SDK**: ^3.9.2
- **Dart**: Ngôn ngữ lập trình

### 3.2. State Management

- **flutter_bloc**: ^9.1.1 - BLoC pattern
- **bloc**: ^9.1.0 - Core BLoC library

### 3.3. Routing

- **go_router**: ^16.2.4 - Navigation và routing

### 3.4. Backend Services

- **Firebase Core**: ^4.1.1
- **Firebase Auth**: ^6.1.0 - Authentication
- **Cloud Firestore**: ^6.0.2 - NoSQL Database
- **Google Sign In**: ^6.2.1 - Social authentication

### 3.5. Image Storage

- **Cloudinary**: Upload và quản lý hình ảnh
- **image_picker**: ^1.1.2 - Chọn ảnh từ device

### 3.6. Utilities

- **get_it**: ^8.2.0 - Dependency Injection
- **dartz**: ^0.10.1 - Functional programming (Either pattern)
- **equatable**: ^2.0.7 - Value equality
- **intl**: ^0.19.0 - Internationalization
- **flutter_dotenv**: ^6.0.0 - Environment variables
- **http**: ^1.2.2 - HTTP requests
- **crypto**: ^3.0.5 - Cryptography
- **google_fonts**: ^6.2.1 - Custom fonts
- **lottie**: ^3.1.0 - Animations

---

## 4. CÁC MODULE CHỨC NĂNG

### 4.1. Module Authentication (Xác thực)

#### **4.1.1. Chức năng**

- Đăng ký tài khoản mới (Email/Password)
- Đăng nhập (Email/Password, Google Sign In)
- Đăng xuất
- Quên mật khẩu (Reset password)
- Quản lý session (Real-time auth state)

#### **4.1.2. Entities**

```dart
AppUser {
  String id
  String email
  String? displayName
  String? phoneNumber
  String? avatarUrl
  String role              // 'customer' hoặc 'admin'
  String? defaultAddressId
  bool isDisabled          // Khóa tài khoản bởi admin
  DateTime createdAt
}
```

#### **4.1.3. Use Cases**

- `LoginUseCase`: Đăng nhập với email/password
- `RegisterUseCase`: Đăng ký tài khoản mới
- `LogoutUseCase`: Đăng xuất
- `GoogleSignInUseCase`: Đăng nhập bằng Google
- `ForgotPasswordUseCase`: Gửi email reset password
- `GetAuthStateChangesUseCase`: Lấy stream auth state changes

#### **4.1.4. Luồng hoạt động**

**Đăng ký:**
```
1. User điền form (email, password, displayName)
2. Validate form
3. RegisterUseCase → AuthRepository.register()
4. Firebase Auth: createUserWithEmailAndPassword()
5. Firestore: Tạo user profile (role: 'customer')
6. Success → Auto login → Navigate to home
```

**Đăng nhập:**
```
1. User nhập email/password
2. LoginUseCase → AuthRepository.login()
3. Firebase Auth: signInWithEmailAndPassword()
4. Firestore: Lấy user profile
5. Success → Navigate based on role (admin/customer)
```

### 4.2. Module Products (Sản phẩm)

#### **4.2.1. Chức năng**

**Customer:**
- Xem danh sách sản phẩm (pagination, search)
- Xem chi tiết sản phẩm
- Thêm vào giỏ hàng

**Admin:**
- CRUD sản phẩm (Create, Read, Update, Delete)
- Upload ảnh sản phẩm
- Ẩn/hiện sản phẩm (isVisible)
- Quản lý tồn kho (quantity)

#### **4.2.2. Entities**

```dart
Product {
  String id
  String name
  double price
  bool isVisible           // Customer có thấy không
  int quantity             // Tồn kho
  int lowStockThreshold    // Ngưỡng cảnh báo
  String? imageUrl
  String shortDescription
  String longDescription
  String? categoryId
  DateTime createdAt
  DateTime? updatedAt
}
```

#### **4.2.3. Use Cases**

- `GetProducts`: Lấy danh sách sản phẩm
- `AddProduct`: Thêm sản phẩm mới
- `UpdateProduct`: Cập nhật sản phẩm
- `DeleteProduct`: Xóa sản phẩm
- `UploadProductImage`: Upload ảnh lên Cloudinary

#### **4.2.4. Cache Strategy**

- **ProductCacheService**: Singleton pattern
- Cache 5 phút trong memory
- Background refresh nếu cache > 2 phút
- Clear cache sau khi admin CRUD

### 4.3. Module Bag (Giỏ hàng)

#### **4.3.1. Chức năng**

- Thêm sản phẩm vào giỏ hàng
- Xem giỏ hàng
- Cập nhật số lượng
- Xóa sản phẩm khỏi giỏ hàng
- Tìm kiếm trong giỏ hàng
- Thanh toán (Navigate to Payment)

#### **4.3.2. Entities**

```dart
CartItem {
  String id
  String productId
  String userId
  int quantity
  String? color
  String? size
  DateTime addedAt
}

CartItemWithProduct {
  CartItem cartItem
  Product product
  double totalPrice  // Computed: product.price * quantity
}
```

#### **4.3.3. Use Cases**

- `AddToCartUseCase`: Thêm vào giỏ (smart merge)
- `GetCartItemsWithProductsUseCase`: Lấy cart items + product info
- `RemoveFromCartUseCase`: Xóa khỏi giỏ
- `UpdateCartItemQuantityUseCase`: Cập nhật số lượng

#### **4.3.4. Smart Merge Logic**

- **Same productId + color + size** → Merge (tăng quantity)
- **Different attributes** → Create new cart item

#### **4.3.5. Optimistic Updates**

- Update UI ngay lập tức
- Sync với server sau
- Rollback nếu có lỗi

### 4.4. Module Orders (Đơn hàng)

#### **4.4.1. Chức năng**

**Customer:**
- Xem danh sách đơn hàng (filter theo status)
- Xem chi tiết đơn hàng
- Tạo đơn hàng từ giỏ hàng

**Admin:**
- Xem tất cả đơn hàng (real-time)
- Cập nhật trạng thái đơn hàng

#### **4.4.2. Entities**

```dart
Order {
  String id
  String userId
  String customerName
  String customerEmail
  List<OrderItem> items
  double totalAmount
  DateTime createdAt
  OrderStatus status  // processing, delivery, cancelled
  
  // Computed
  String trackingNumber
  int totalQuantity
}

OrderItem {
  String productId
  String productName        // Snapshot
  String? productImageUrl   // Snapshot
  int quantity
  double price              // Snapshot tại thời điểm mua
  String? color
  String? size
  double totalPrice         // Computed
}
```

#### **4.4.3. Use Cases**

- `CreateOrderUseCase`: Tạo order (không giảm stock)
- `CreateOrderWithReduceStockUseCase`: ⭐ Tạo order + giảm stock (atomic)
- `GetOrdersByUserIdUseCase`: Lấy orders của user
- `GetOrderByIdUseCase`: Lấy order theo ID

#### **4.4.4. Atomic Transaction Pattern**

**CreateOrderWithReduceStockUseCase:**
- Dùng Firestore batch write
- Tất cả operations: ALL or NOTHING
- Group items by productId
- Validate stock trước khi commit
- Giảm stock và tạo order trong cùng batch

### 4.5. Module Admin (Quản trị)

#### **4.5.1. Chức năng**

- **Dashboard (Overview)**: Thống kê tổng quan
- **Quản lý Khách hàng**: Xem, tìm kiếm, khóa/mở khóa tài khoản, tạo user mới
- **Quản lý Đơn hàng**: Xem tất cả orders, cập nhật trạng thái
- **Quản lý Sản phẩm**: CRUD sản phẩm (dùng chung Products module)

#### **4.5.2. Dashboard Stats**

- **Total Orders**: Tổng số đơn hàng
- **Total Revenue**: Tổng doanh thu
- **Total Customers**: Tổng số khách hàng
- **Total Products**: Tổng số sản phẩm

**Real-time updates** qua stream composition

#### **4.5.3. Use Cases**

- `GetAllUsersUseCase`: Stream tất cả users
- `UpdateUserStatusUseCase`: Khóa/mở khóa user
- `CreateUserByAdminUseCase`: Tạo user với role
- `GetAllOrdersUseCase`: Stream tất cả orders
- `UpdateOrderStatusUseCase`: Cập nhật trạng thái order
- `GetOverviewStatsUseCase`: Tính toán stats (complex stream)

#### **4.5.4. Multi-BLoC Pattern**

- `CustomersBloc`: Quản lý users
- `AdminOrdersBloc`: Quản lý orders
- `OverviewBloc`: Dashboard stats

### 4.6. Module Profile & Settings

#### **4.6.1. Profile Screen**

**Chức năng:**
- Hiển thị thông tin user (avatar, tên, email)
- Navigation đến Orders, Settings
- Logout

**Đặc điểm:**
- Stateless widget
- Đọc từ AuthBloc (reactive)
- Auto-update khi profile thay đổi

#### **4.6.2. Settings Screen**

**Chức năng:**
- Cập nhật thông tin profile (displayName, phoneNumber)
- Upload/đổi avatar
- Đổi mật khẩu

**Use Cases:**
- `GetCurrentUserUseCase`: Lấy user hiện tại
- `UpdateUserSettingsUseCase`: Cập nhật profile
- `ChangePasswordUseCase`: Đổi mật khẩu (re-authentication)
- `UploadAvatarImageUseCase`: Upload avatar lên Cloudinary

**Image Preview Pattern:**
- Chọn ảnh → Preview ngay (local)
- Upload khi user click "Lưu"

---

## 5. LUỒNG HOẠT ĐỘNG CHÍNH

### 5.1. Luồng đăng ký và đăng nhập

```
1. User mở app → LoginScreen
2. User chọn đăng ký hoặc đăng nhập
3. Đăng ký:
   - Điền form → Validate
   - RegisterUseCase → Firebase Auth + Firestore
   - Success → Auto login → Navigate to home
4. Đăng nhập:
   - Nhập email/password → LoginUseCase
   - Success → Check role → Navigate:
     - Admin → /admin/overview
     - Customer → /home
```

### 5.2. Luồng mua hàng

```
1. Customer xem sản phẩm (ProductList)
2. Tap vào sản phẩm → ProductDetailPage
3. Click "Mua ngay" → BuyNowSheet
4. Chọn quantity → Click "Thêm vào giỏ"
   - BagBloc.add(AddToCart(...))
   - Smart merge nếu đã có
5. Navigate to BagScreen
6. Xem giỏ hàng → Click "Thanh toán"
7. PaymentScreen → Review order
8. Click "Xác nhận thanh toán"
   - CreateOrderWithReduceStockUseCase
     - Atomic: Create order + Reduce stock
   - Clear cart
   - Clear product cache
9. Navigate to PaymentSuccessScreen
10. Navigate to OrderDetailScreen (optional)
```

### 5.3. Luồng quản lý đơn hàng (Admin)

```
1. Admin navigate to AdminOrdersPage
2. AdminOrdersBloc.add(LoadAllOrders())
3. Listen getAllOrders() stream (real-time)
4. Admin xem danh sách orders
5. Admin chọn status mới từ dropdown
6. Confirmation dialog → Confirm
7. AdminOrdersBloc.add(UpdateOrderStatus(...))
8. UpdateOrderStatusUseCase → Firestore update
9. Stream auto-update → UI refresh
```

### 5.4. Luồng quản lý sản phẩm (Admin)

```
1. Admin navigate to ProductListPage
2. Load products → GetProductsUseCase
3. Admin có thể:
   - Thêm sản phẩm mới:
     - ProductFormPage → Điền form + chọn ảnh
     - UploadProductImageUseCase → Cloudinary
     - AddProductUseCase → Firestore
   - Sửa sản phẩm:
     - Tap vào sản phẩm → ProductFormPage (edit mode)
     - UpdateProductUseCase → Firestore
   - Xóa sản phẩm:
     - DeleteProductUseCase → Firestore
   - Toggle visibility:
     - UpdateProductUseCase (isVisible field)
```

---

## 6. DỮ LIỆU VÀ CƠ SỞ DỮ LIỆU

### 6.1. Firebase Firestore Collections

#### **6.1.1. Collection: `users`**

```json
{
  "id": "user123",
  "email": "user@example.com",
  "displayName": "Nguyễn Văn A",
  "phoneNumber": "+84123456789",
  "avatarUrl": "https://cloudinary.com/...",
  "role": "customer",  // hoặc "admin"
  "defaultAddressId": null,
  "isDisabled": false,
  "createdAt": Timestamp
}
```

**Indexes:**
- `createdAt` (Descending) - Cho getAllUsers

#### **6.1.2. Collection: `products`**

```json
{
  "id": "prod123",
  "name": "Áo sơ mi trắng",
  "price": 199000,
  "isVisible": true,
  "quantity": 50,
  "lowStockThreshold": 10,
  "imageUrl": "https://cloudinary.com/...",
  "shortDescription": "Áo sơ mi chất liệu cotton",
  "longDescription": "...",
  "categoryId": null,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

#### **6.1.3. Collection: `cartItems`**

```json
{
  "id": "cartItem123",
  "productId": "prod123",
  "userId": "user456",
  "quantity": 2,
  "color": "Đỏ",
  "size": "M",
  "addedAt": Timestamp
}
```

**Indexes:**
- Composite: `userId` (Ascending) + `addedAt` (Ascending)

#### **6.1.4. Collection: `orders`**

```json
{
  "id": "order123",
  "userId": "user456",
  "customerName": "Nguyễn Văn A",
  "customerEmail": "user@example.com",
  "items": [
    {
      "productId": "prod123",
      "productName": "Áo sơ mi trắng",
      "productImageUrl": "https://...",
      "quantity": 2,
      "price": 199000,
      "color": "Đỏ",
      "size": "M"
    }
  ],
  "totalAmount": 398000,
  "createdAt": Timestamp,
  "status": "PROCESSING"  // hoặc "DELIVERY", "CANCELLED"
}
```

**Indexes:**
- `userId` (Ascending) - Cho getOrdersByUserId
- `createdAt` (Descending) - Cho getAllOrders

### 6.2. Cloudinary Storage

**Folders:**
- `avatars/`: Avatar của users
- `products/`: Ảnh sản phẩm

**Upload Pattern:**
- Signed upload với API key + secret + signature
- Image optimization: Max 800x800, quality 85%
- Format: Auto (JPEG/WebP)

### 6.3. Cache Strategy

**ProductCacheService:**
- In-memory cache (5 phút)
- Background refresh (nếu cache > 2 phút)
- Singleton pattern

**Firestore Offline Cache:**
- Tự động bởi Firebase SDK
- Persist trên device

---

## 7. BẢO MẬT

### 7.1. Authentication & Authorization

**Firebase Authentication:**
- Email/Password authentication
- Google Sign In (OAuth)
- Session management tự động
- Token refresh tự động

**Role-based Access Control:**
- `role` field trong user document
- Route guards trong GoRouter
- Admin-only features check role

### 7.2. Firestore Security Rules

**Users Collection:**
```javascript
match /users/{userId} {
  // User chỉ được read/write profile của chính mình
  allow read, write: if request.auth != null && 
                      request.auth.uid == userId;
  
  // Admin có thể read/write all
  allow read, write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

**Products Collection:**
```javascript
match /products/{productId} {
  // Customer chỉ được read visible products
  allow read: if resource.data.isVisible == true;
  
  // Admin có thể read/write all
  allow read, write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

**CartItems Collection:**
```javascript
match /cartItems/{cartItemId} {
  // User chỉ được read/write cart items của chính họ
  allow read, write: if request.auth != null && 
                      resource.data.userId == request.auth.uid;
}
```

**Orders Collection:**
```javascript
match /orders/{orderId} {
  // User chỉ được read orders của chính họ
  allow read: if request.auth != null && 
               resource.data.userId == request.auth.uid;
  
  // Admin có thể read/write all
  allow read, write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

### 7.3. Password Security

- Firebase tự động hash passwords
- Minimum length: 6 characters
- Re-authentication required cho đổi password
- Password reset via email

### 7.4. Cloudinary Security

- Signed upload với API secret
- Upload preset với unsigned mode (optional)
- Environment variables trong `.env` (không commit)

### 7.5. Input Validation

- Email format validation
- Password strength check
- Required fields validation
- Type safety với Dart

---

## 8. GIAO DIỆN NGƯỜI DÙNG

### 8.1. Theme và Styling

**Theme System:**
- Light theme và Dark theme
- Custom colors (AppColors)
- Custom text styles (AppTextStyles)
- Custom shadows (AppShadows)
- Custom sizes (AppSizes)

**Google Fonts:**
- Custom font families

### 8.2. Navigation

**GoRouter với Shell Routes:**
- **Customer Shell**: Bottom navigation bar (Home, Shop, Bag, Profile)
- **Admin Shell**: Bottom navigation bar (Overview, Products, Customers, Orders, Profile)

**Routes:**
- `/login`, `/register`, `/forgot-password`
- `/home`, `/shop`, `/bag`, `/profile`, `/settings`
- `/orders`, `/orders/:orderId`
- `/payment`, `/payment-success`
- `/admin/overview`, `/admin/products`, `/admin/customers`, `/admin/orders`, `/admin/profile`

**Role-based Redirect:**
- Auto redirect dựa trên role
- Protected routes với auth check

### 8.3. UI Components

**Reusable Widgets:**
- `ProductCard`: Hiển thị sản phẩm
- `AuthTextField`: Text field với validation
- `AuthButton`: Primary button
- Custom navigation bars

**Animations:**
- Lottie animations (shopping, digital designer)

### 8.4. Responsive Design

- Mobile-first approach
- Adaptive layouts
- Screen size considerations

---

## 9. TRIỂN KHAI VÀ VẬN HÀNH

### 9.1. Yêu cầu môi trường

**Development:**
- Flutter SDK ^3.9.2
- Dart SDK
- Android Studio / VS Code
- Firebase CLI (optional)

**Production:**
- Firebase project với:
  - Authentication enabled
  - Firestore database
  - Security rules configured
- Cloudinary account
- `.env` file với credentials

### 9.2. Cài đặt và cấu hình

**1. Clone repository:**
```bash
git clone <repository-url>
cd e_commerce
```

**2. Install dependencies:**
```bash
flutter pub get
```

**3. Cấu hình Firebase:**
- Tạo Firebase project
- Download `google-services.json` (Android)
- Download `GoogleService-Info.plist` (iOS)
- Copy vào `android/app/` và `ios/Runner/`

**4. Cấu hình Cloudinary:**
- Tạo `.env` file ở root project:
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=ml_default
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

**5. Setup Firestore:**
- Tạo collections: `users`, `products`, `cartItems`, `orders`
- Tạo indexes:
  - `users`: `createdAt` (Descending)
  - `cartItems`: `userId` (Ascending) + `addedAt` (Ascending)
  - `orders`: `userId` (Ascending), `createdAt` (Descending)
- Cấu hình security rules

**6. Run app:**
```bash
flutter run
```

### 9.3. Build và Deploy

**Android:**
```bash
flutter build apk --release
# hoặc
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### 9.4. Monitoring và Maintenance

**Firebase Console:**
- Monitor authentication usage
- Monitor Firestore reads/writes
- View error logs

**Cloudinary Dashboard:**
- Monitor storage usage
- View uploaded images

**Performance:**
- Monitor app performance với Flutter DevTools
- Optimize images và cache

### 9.5. Backup và Recovery

**Firestore:**
- Automatic backups (nếu enabled)
- Export data manually từ Firebase Console

**Cloudinary:**
- Automatic backups
- Versioning support

---

## 10. TÀI LIỆU THAM KHẢO

### 10.1. Tài liệu kỹ thuật

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### 10.2. Tài liệu features

- `AUTH_FEATURE_EXPLANATION.md`: Chi tiết Authentication
- `PRODUCT_FEATURE_EXPLANATION.md`: Chi tiết Products
- `BAG_FEATURE_EXPLANATION.md`: Chi tiết Shopping Cart
- `ORDERS_FEATURE_EXPLANATION.md`: Chi tiết Orders
- `ADMIN_FEATURE_EXPLANATION.md`: Chi tiết Admin
- `PROFILE_SETTINGS_FEATURE_EXPLANATION.md`: Chi tiết Profile & Settings
- `CLOUDINARY_SETUP.md`: Hướng dẫn setup Cloudinary

---

## 11. PHỤ LỤC

### 11.1. Cấu trúc thư mục

```
lib/
├── core/                    # Core utilities
│   ├── data/               # Cloudinary service
│   ├── routing/            # GoRouter configuration
│   ├── theme/              # Theme, colors, styles
│   └── widgets/            # Reusable widgets
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── products/          # Products management
│   ├── bag/               # Shopping cart
│   ├── orders/            # Orders management
│   ├── admin/             # Admin panel
│   ├── profile/           # Profile display
│   └── settings/          # Settings management
├── di.dart                 # Dependency Injection
├── main.dart              # Entry point
└── my_app.dart            # App configuration
```

### 11.2. Dependency Injection Setup

**GetIt Service Locator:**
- Singletons: Repositories, DataSources, Services
- Factories: BLoCs, UseCases

**Registration Order:**
1. External services (Firebase, Cloudinary)
2. DataSources
3. Repositories
4. UseCases
5. BLoCs

### 11.3. Error Handling Pattern

**Either Pattern (dartz):**
- `Left(Failure)`: Error
- `Right(T)`: Success

**Usage trong UseCases:**
```dart
Future<Either<Failure, AppUser>> login(...) {
  try {
    // Success
    return Right(user);
  } catch (e) {
    // Error
    return Left(Failure(message));
  }
}
```

**Usage trong BLoC:**
```dart
final result = await loginUseCase(...);
result.fold(
  (failure) => emit(AuthFailure(failure.message)),
  (user) => emit(AuthAuthenticated(user)),
);
```

---

**Tài liệu được tạo bởi:** AI Assistant  
**Ngày:** 2024  
**Phiên bản:** 1.0

