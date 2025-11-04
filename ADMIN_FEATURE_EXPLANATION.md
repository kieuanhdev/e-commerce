# 👨‍💼 GIẢI THÍCH CHI TIẾT FEATURE ADMIN

## 🏗️ KIẾN TRÚC TỔNG QUAN

Feature Admin được xây dựng để quản lý toàn bộ hệ thống với các chức năng dành cho administrator. Feature này tận dụng repositories từ Auth và Orders features:

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (UI)             │
│  ┌──────────┬──────────┬──────────────┐  │
│  │ Overview │ Customers│ Orders Pages │  │
│  │ Page     │ Page     │              │  │
│  │          │          │              │  │
│  └──────────┴──────────┴──────────────┘  │
│  ┌──────────┬──────────┬──────────────┐  │
│  │Customers │AdminOrders│ Overview    │  │
│  │Bloc      │Bloc      │ Bloc         │  │
│  └──────────┴──────────┴──────────────┘  │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│     DOMAIN LAYER (Business Logic)       │
│  ┌──────────┬─────────────────────────┐  │
│  │ UseCases │ Repository Interfaces   │  │
│  │          │ (IAuthRepository,        │  │
│  │          │  IOrderRepository)       │  │
│  └──────────┴─────────────────────────┘  │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│     DATA LAYER (External Data)          │
│  ┌──────────┬──────────┬─────────────┐  │
│  │ Models   │ Data-    │ Repository  │  │
│  │          │ sources  │ Impl        │  │
│  │          │ (shared)  │ (shared)    │  │
│  └──────────┴──────────┴─────────────┘  │
└─────────────────────────────────────────┘
```

**Đặc điểm:**
- **No Data Layer riêng**: Tận dụng repositories từ Auth và Orders
- **Real-time Updates**: Stream-based cho users và orders
- **Multi-BLoC**: 3 BLoCs riêng biệt cho từng module
- **Dashboard Stats**: Complex stream combination

---

## 📁 CẤU TRÚC THƯ MỤC

```
lib/features/admin/
├── domain/                         # DOMAIN LAYER
│   └── usecase/                   # Business logic operations
│       ├── get_all_users.dart      # Real-time stream users
│       ├── update_user_status.dart # Lock/unlock users
│       ├── create_user_by_admin.dart # Create user với role
│       ├── get_all_orders.dart     # Real-time stream orders
│       ├── update_order_status.dart # Update order status
│       └── get_overview_stats.dart  # ⭐ Dashboard stats (complex)
│
└── presentation/                    # PRESENTATION LAYER
    ├── bloc/                        # Multiple BLoCs
    │   ├── customers_bloc.dart      # Users management
    │   ├── customers_event.dart
    │   ├── customers_state.dart
    │   ├── admin_orders_bloc.dart   # Orders management
    │   ├── admin_orders_event.dart
    │   ├── admin_orders_state.dart
    │   ├── overview_bloc.dart       # Dashboard stats
    │   ├── overview_event.dart
    │   └── overview_state.dart
    ├── admin_screen.dart            # Main admin screen (simple)
    └── pages/
        ├── overview_page.dart       # Dashboard với stats
        ├── customers_page.dart      # Users list + management
        ├── orders_page.dart          # Orders list + status update
        └── user_form_page.dart       # Create user form
```

---

## 🔄 LUỒNG HOẠT ĐỘNG CHI TIẾT

### 1. 🎯 DOMAIN LAYER - Business Logic

#### **Use Cases** - Business Operations

##### **1. GetAllUsersUseCase** (`domain/usecases/get_all_users.dart`)

```dart
class GetAllUsersUseCase {
  final IAuthRepository _repository;
  
  GetAllUsersUseCase(this._repository);
  
  Stream<List<AppUser>> call() {
    return _repository.getAllUsers();
  }
}
```

**Nhiệm vụ:**
- Lấy stream tất cả users (real-time)
- Trả về Stream để tự động update khi có thay đổi

**Luồng:**
```
GetAllUsersUseCase()
  → IAuthRepository.getAllUsers()
    → FirebaseAuthDatasource.getAllUsers()
      → Firestore: collection('users')
        → orderBy('createdAt', descending: true)
          → snapshots() (Stream)
            → Return Stream<List<AppUser>>
```

**Đặc biệt:**
- ✅ Real-time updates tự động
- ✅ Sorted by createdAt descending (mới nhất trước)

##### **2. UpdateUserStatusUseCase** (`domain/usecases/update_user_status.dart`)

```dart
class UpdateUserStatusUseCase {
  final IAuthRepository _repository;
  
  Future<Either<Failure, void>> call(String userId, bool isDisabled) {
    return _repository.updateUserStatus(userId, isDisabled);
  }
}
```

**Nhiệm vụ:**
- Lock/unlock user account
- Return Either để handle errors

**Luồng:**
```
UpdateUserStatusUseCase(userId, isDisabled)
  → IAuthRepository.updateUserStatus()
    → FirebaseAuthDatasource.updateUserStatus()
      → Firestore: update({'isDisabled': isDisabled})
        → Success/Error
```

**Security:**
- ✅ Chỉ admin mới được gọi use case này
- ✅ `isDisabled = true` → User không thể login

##### **3. CreateUserByAdminUseCase** (`domain/usecases/create_user_by_admin.dart`)

```dart
class CreateUserByAdminUseCase {
  final IAuthRepository _repository;
  
  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    String role = 'customer',  // Có thể set 'admin'
  }) {
    return _repository.createUserByAdmin(...);
  }
}
```

**Nhiệm vụ:**
- Tạo user mới bởi admin
- Có thể set role (customer hoặc admin)

**Luồng:**
```
CreateUserByAdminUseCase(...)
  → IAuthRepository.createUserByAdmin()
    → FirebaseAuthDatasource.createUserByAdmin()
      → Firebase Auth: createUserWithEmailAndPassword()
        → Firestore: set user profile (với role được chỉ định)
          → Return AppUser
```

**Đặc biệt:**
- ✅ Admin có thể tạo user với role 'admin'
- ✅ Khác với RegisterUseCase (user tự đăng ký → role mặc định 'customer')

##### **4. GetAllOrdersUseCase** (`domain/usecases/get_all_orders.dart`)

```dart
class GetAllOrdersUseCase {
  final IOrderRepository _repository;
  
  GetAllOrdersUseCase(this._repository);
  
  Stream<List<Order>> call() {
    return _repository.getAllOrders();
  }
}
```

**Nhiệm vụ:**
- Lấy stream tất cả orders (real-time)
- Cho admin xem và quản lý tất cả orders

**Luồng:**
```
GetAllOrdersUseCase()
  → IOrderRepository.getAllOrders()
    → OrderRemoteDataSource.getAllOrders()
      → Firestore: collection('orders')
        → orderBy('createdAt', descending: true)
          → snapshots() (Stream)
            → Return Stream<List<Order>>
```

**Đặc biệt:**
- ✅ Real-time updates
- ✅ Sorted by createdAt descending

##### **5. UpdateOrderStatusUseCase** (`domain/usecases/update_order_status.dart`)

```dart
class UpdateOrderStatusUseCase {
  final IOrderRepository _repository;
  
  Future<Either<Failure, void>> call(String orderId, String status) async {
    try {
      await _repository.updateOrderStatus(orderId, status);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
```

**Nhiệm vụ:**
- Cập nhật trạng thái order
- Handle errors với Either pattern

**Luồng:**
```
UpdateOrderStatusUseCase(orderId, status)
  → IOrderRepository.updateOrderStatus()
    → OrderRemoteDataSource.updateOrderStatus()
      → Firestore: update({'status': status})
        → Success/Error
```

##### **6. GetOverviewStatsUseCase** ⭐ (`domain/usecases/get_overview_stats.dart`)

**Use case phức tạp nhất** - Combine multiple streams để tính stats:

```dart
class OverviewStats {
  final int totalOrders;
  final double totalRevenue;
  final int totalCustomers;
  final int totalProducts;
}

class GetOverviewStatsUseCase {
  final IOrderRepository _orderRepository;
  final IAuthRepository _authRepository;
  final ProductRepository _productRepository;
  
  Stream<OverviewStats> call() async* {
    // Listen orders stream
    await for (final orders in _orderRepository.getAllOrders()) {
      // Calculate từ orders
      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(
        0,
        (sum, order) => sum + order.totalAmount,
      );
      
      // Fetch users (one-time)
      final users = await _authRepository.getAllUsers().first;
      final totalCustomers = users
          .where((u) => u.role == 'customer')
          .length;
      
      // Fetch products (one-time)
      final products = await _productRepository.getProducts();
      final totalProducts = products.length;
      
      // Yield stats
      yield OverviewStats(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        totalCustomers: totalCustomers,
        totalProducts: totalProducts,
      );
    }
  }
}
```

**Đặc điểm quan trọng:**

1. **Stream Composition:**
   - ✅ Listen orders stream (real-time)
   - ✅ Fetch users và products khi orders thay đổi
   - ✅ Yield stats mới mỗi khi có update

2. **Calculations:**
   - **totalOrders**: Số lượng orders
   - **totalRevenue**: Tổng doanh thu (sum của order.totalAmount)
   - **totalCustomers**: Số users có role = 'customer'
   - **totalProducts**: Tổng số products

3. **Performance:**
   - ⚠️ Fetch users và products mỗi khi orders thay đổi (có thể optimize)
   - ⚠️ Có thể tốn tài nguyên nếu orders thay đổi nhiều

**Luồng hoạt động:**
```
GetOverviewStatsUseCase()
  ↓
1. Listen getAllOrders() stream
  → await for (orders in stream)
    ↓
2. Calculate từ orders:
   → totalOrders = orders.length
   → totalRevenue = sum(order.totalAmount)
    ↓
3. Fetch users (one-time snapshot)
   → _authRepository.getAllUsers().first
   → totalCustomers = users.where(role == 'customer').length
    ↓
4. Fetch products (one-time snapshot)
   → _productRepository.getProducts()
   → totalProducts = products.length
    ↓
5. Yield OverviewStats
    ↓
Loop: Quay lại bước 1 khi có orders mới
```

**Lưu ý:**
- ⚠️ Mỗi khi orders stream emit → Fetch users và products lại (không cache)
- ✅ Stats tự động update khi có order mới

---

### 2. 🎨 PRESENTATION LAYER - Multiple BLoCs

#### **A. CustomersBloc** - Users Management

##### **CustomersEvent** (`presentation/bloc/customers_event.dart`)

```dart
abstract class CustomersEvent extends Equatable {}

class LoadUsers extends CustomersEvent {}
// Load và listen users stream

class UsersUpdated extends CustomersEvent {
  final List<AppUser> users;
}
// Users stream emit new data

class ToggleUserStatus extends CustomersEvent {
  final String userId;
}
// Lock/unlock user

class CreateUser extends CustomersEvent {
  final String email;
  final String password;
  final String displayName;
  final String? phoneNumber;
  final String role;  // 'customer' hoặc 'admin'
}
// Create user bởi admin
```

##### **CustomersState** (`presentation/bloc/customers_state.dart`)

```dart
abstract class CustomersState extends Equatable {}

class CustomersInitial extends CustomersState {}
// Initial state

class CustomersLoading extends CustomersState {
  final List<AppUser> currentUsers;  // Giữ UI hiển thị trong khi loading
}
// Đang process operation

class CustomersLoaded extends CustomersState {
  final List<AppUser> users;
}
// Đã load thành công

class CustomersError extends CustomersState {
  final String message;
}
// Có lỗi xảy ra
```

**State machine:**
```
CustomersInitial
  ↓
LoadUsers event
  ↓
Listen getAllUsers stream
  ↓
UsersUpdated event → CustomersLoaded
  ↓
ToggleUserStatus event
  ↓
CustomersLoading (keep current users)
  ↓
Update success → Stream auto-update → CustomersLoaded
  ↓
CreateUser event
  ↓
CustomersLoading
  ↓
Create success → Stream auto-update → CustomersLoaded
```

##### **CustomersBloc** (`presentation/bloc/customers_bloc.dart`)

**Constructor:**
```dart
CustomersBloc({...}) : super(CustomersInitial()) {
  on<LoadUsers>(_onLoadUsers);
  on<UsersUpdated>(_onUsersUpdated);
  on<ToggleUserStatus>(_onToggleUserStatus);
  on<CreateUser>(_onCreateUser);
}
```

**1. LoadUsers Handler (Stream Setup):**
```dart
void _onLoadUsers(LoadUsers event, Emitter<CustomersState> emit) {
  _usersSubscription?.cancel();  // Cancel previous subscription
  
  // Listen users stream
  _usersSubscription = _getAllUsersUseCase().listen(
    (users) {
      add(UsersUpdated(users));  // Emit event khi stream update
    },
    onError: (error) {
      emit(CustomersError(error.toString()));
    },
  );
}
```

**Đặc biệt:**
- ✅ Setup stream listener
- ✅ Auto-update khi có users mới hoặc thay đổi
- ✅ Cancel subscription khi dispose

**2. UsersUpdated Handler:**
```dart
void _onUsersUpdated(UsersUpdated event, Emitter<CustomersState> emit) {
  emit(CustomersLoaded(event.users));
}
```

**3. ToggleUserStatus Handler:**
```dart
Future<void> _onToggleUserStatus(
  ToggleUserStatus event,
  Emitter<CustomersState> emit,
) async {
  if (state is CustomersLoaded) {
    final currentState = state as CustomersLoaded;
    final user = currentState.users.firstWhere((u) => u.id == event.userId);
    
    // Show loading nhưng giữ UI
    emit(CustomersLoading(currentState.users));
    
    // Toggle status
    final result = await _updateUserStatusUseCase(
      event.userId,
      !user.isDisabled,  // Toggle
    );
    
    result.fold(
      (failure) => emit(CustomersError(failure.message)),
      (_) {
        // State sẽ được cập nhật tự động qua stream
        // Không cần emit CustomersLoaded manually
      },
    );
  }
}
```

**Đặc biệt:**
- ✅ Optimistic UI: Giữ users hiển thị trong khi loading
- ✅ Stream auto-update: Không cần reload manually
- ✅ Better UX: UI không bị empty trong khi update

**4. CreateUser Handler:**
```dart
Future<void> _onCreateUser(
  CreateUser event,
  Emitter<CustomersState> emit,
) async {
  // Show loading
  if (state is CustomersLoaded) {
    emit(CustomersLoading((state as CustomersLoaded).users));
  } else {
    emit(CustomersLoading([]));
  }
  
  // Create user
  final result = await _createUserByAdminUseCase(...);
  
  result.fold(
    (failure) {
      emit(CustomersError(failure.message));
      add(const LoadUsers());  // Reload
    },
    (_) {
      // User sẽ được thêm vào list tự động qua stream
    },
  );
}
```

**Cleanup:**
```dart
@override
Future<void> close() {
  _usersSubscription?.cancel();  // Cancel stream subscription
  return super.close();
}
```

#### **B. AdminOrdersBloc** - Orders Management

##### **AdminOrdersEvent** (`presentation/bloc/admin_orders_event.dart`)

```dart
abstract class AdminOrdersEvent extends Equatable {}

class LoadAllOrders extends AdminOrdersEvent {}
// Load và listen orders stream

class OrdersUpdated extends AdminOrdersEvent {
  final List<Order> orders;
}
// Orders stream emit new data

class UpdateOrderStatus extends AdminOrdersEvent {
  final String orderId;
  final OrderStatus newStatus;
}
// Update order status
```

##### **AdminOrdersState** (`presentation/bloc/admin_orders_state.dart`)

```dart
abstract class AdminOrdersState extends Equatable {}

class AdminOrdersInitial extends AdminOrdersState {}
class AdminOrdersLoading extends AdminOrdersState {
  final List<Order> currentOrders;  // Giữ UI
}
class AdminOrdersLoaded extends AdminOrdersState {
  final List<Order> orders;
}
class AdminOrdersError extends AdminOrdersState {
  final String message;
}
```

##### **AdminOrdersBloc** (`presentation/bloc/admin_orders_bloc.dart`)

**Similar pattern với CustomersBloc:**

```dart
void _onLoadAllOrders(LoadAllOrders event, Emitter<AdminOrdersState> emit) {
  _ordersSubscription?.cancel();
  _ordersSubscription = _getAllOrdersUseCase().listen(
    (orders) {
      add(OrdersUpdated(orders));
    },
    onError: (error) {
      emit(AdminOrdersError(error.toString()));
    },
  );
}

void _onUpdateOrderStatus(
  UpdateOrderStatus event,
  Emitter<AdminOrdersState> emit,
) async {
  if (state is AdminOrdersLoaded) {
    final currentState = state as AdminOrdersLoaded;
    
    emit(AdminOrdersLoading(currentState.orders));  // Keep UI
    
    final result = await _updateOrderStatusUseCase(
      event.orderId,
      event.newStatus.displayName,
    );
    
    result.fold(
      (failure) => emit(AdminOrdersError(failure.message)),
      (_) {
        // Stream auto-update
      },
    );
  }
}
```

#### **C. OverviewBloc** - Dashboard Stats

##### **OverviewEvent** (`presentation/bloc/overview_event.dart`)

```dart
abstract class OverviewEvent extends Equatable {}

class LoadOverviewStats extends OverviewEvent {}
// Load và listen stats stream

class OverviewStatsUpdated extends OverviewEvent {
  final OverviewStats stats;
}
// Stats stream emit new data
```

##### **OverviewState** (`presentation/bloc/overview_state.dart`)

```dart
abstract class OverviewState extends Equatable {}

class OverviewInitial extends OverviewState {}
class OverviewLoading extends OverviewState {}
class OverviewLoaded extends OverviewState {
  final OverviewStats stats;
}
class OverviewError extends OverviewState {
  final String message;
}
```

##### **OverviewBloc** (`presentation/bloc/overview_bloc.dart`)

```dart
void _onLoadOverviewStats(
  LoadOverviewStats event,
  Emitter<OverviewState> emit,
) {
  _statsSubscription?.cancel();
  
  // Listen stats stream
  _statsSubscription = _getOverviewStatsUseCase().listen(
    (stats) {
      add(OverviewStatsUpdated(stats));
    },
    onError: (error) {
      emit(OverviewError(error.toString()));
    },
  );
}

void _onOverviewStatsUpdated(
  OverviewStatsUpdated event,
  Emitter<OverviewState> emit,
) {
  emit(OverviewLoaded(event.stats));
}
```

**Đặc biệt:**
- ✅ Listen stats stream
- ✅ Auto-update khi có order mới hoặc thay đổi

---

### 3. 🎨 PRESENTATION LAYER - UI Screens

#### **A. OverviewPage** (`presentation/pages/overview_page.dart`)

**Chức năng:**
- Hiển thị dashboard với 4 stats cards
- Real-time updates

**UI Structure:**
```
Scaffold
  ├── AppBar: "Tổng quan"
  └── Body:
      └── GridView (2x2):
          ├── _StatCard: Đơn hàng (totalOrders)
          ├── _StatCard: Doanh thu (totalRevenue) ₫
          ├── _StatCard: Khách hàng (totalCustomers)
          └── _StatCard: Sản phẩm (totalProducts)
```

**Stat Cards:**
- Icon với màu sắc khác nhau
- Value lớn (bold)
- Title nhỏ
- Format số với NumberFormat.compact

**State Management:**
```dart
BlocProvider(
  create: (context) => sl<OverviewBloc>()..add(const LoadOverviewStats()),
  child: BlocBuilder<OverviewBloc, OverviewState>(
    builder: (context, state) {
      if (state is OverviewLoaded) {
        return GridView với 4 stat cards;
      }
      // Loading/Error states
    },
  ),
)
```

#### **B. CustomersPage** (`presentation/pages/customers_page.dart`)

**Chức năng:**
- Hiển thị danh sách users
- Search users
- Toggle user status (lock/unlock)
- Create new user

**UI Structure:**
```
Scaffold
  ├── AppBar: "Quản lý Khách hàng"
  ├── FloatingActionButton: "Thêm người dùng"
  └── Body:
      ├── SearchBar
      ├── Stats Bar (Tổng số, Hoạt động, Đã khóa)
      ├── Search Results Info (nếu có search)
      └── Users List
          └── _UserCard (cho mỗi user)
```

**UserCard:**
- Avatar (network hoặc initial)
- Display name (strikethrough nếu disabled)
- Email
- Phone number (nếu có)
- Role badge (Admin/Khách hàng)
- Status badge (Đã khóa)
- Created date
- Lock/Unlock button

**Search Functionality:**
```dart
List<AppUser> _filterUsers(List<AppUser> users, String query) {
  if (query.isEmpty) return users;
  final lowerQuery = query.toLowerCase();
  return users.where((user) {
    final displayName = (user.displayName ?? '').toLowerCase();
    final email = user.email.toLowerCase();
    return displayName.contains(lowerQuery) || email.contains(lowerQuery);
  }).toList();
}
```

**Toggle Status Flow:**
```
User click lock/unlock button
  → Show confirmation dialog
    → User confirm
      → CustomersBloc.add(ToggleUserStatus(userId))
        → Show loading snackbar
          → UpdateUserStatusUseCase()
            → Firestore update
              → Stream auto-update
                → UI refresh automatically
```

**Create User Flow:**
```
User click "Thêm người dùng"
  → Navigate to UserFormPage
    → User fill form + select role
      → CustomersBloc.add(CreateUser(...))
        → CreateUserByAdminUseCase()
          → Success: Stream auto-add user to list
          → Error: Show error snackbar
```

**State Management:**
```dart
BlocProvider(
  create: (context) => sl<CustomersBloc>()..add(const LoadUsers()),
  child: BlocConsumer<CustomersBloc, CustomersState>(
    listener: (context, state) {
      if (state is CustomersError) {
        // Show error snackbar
      }
    },
    builder: (context, state) {
      if (state is CustomersLoaded) {
        // Display users
      }
      // Loading/Error states
    },
  ),
)
```

**Đặc biệt:**
- ✅ Real-time updates qua stream
- ✅ Search by name hoặc email
- ✅ Stats bar hiển thị tổng số, active, disabled
- ✅ Confirmation dialog cho lock/unlock

#### **C. OrdersPage** (`presentation/pages/orders_page.dart`)

**Chức năng:**
- Hiển thị danh sách tất cả orders
- Update order status

**UI Structure:**
```
Scaffold
  ├── AppBar: "Quản lý Đơn hàng"
  └── Body:
      └── ListView
          └── _OrderCard (cho mỗi order)
```

**OrderCard:**
- Order ID (tracking number)
- Created date
- Customer name + email
- Total amount
- Status dropdown (với color indicator)
  - Processing (Orange)
  - Delivery (Green)
  - Cancelled (Red)

**Update Status Flow:**
```
Admin select new status từ dropdown
  → Show confirmation dialog
    → Admin confirm
      → AdminOrdersBloc.add(UpdateOrderStatus(orderId, newStatus))
        → Show success snackbar
          → UpdateOrderStatusUseCase()
            → Firestore update
              → Stream auto-update
                → UI refresh automatically
```

**Status Dropdown:**
- Color indicator (dot) cho mỗi status
- Vietnamese text
- Confirmation dialog trước khi update

**State Management:**
```dart
BlocProvider(
  create: (context) => sl<AdminOrdersBloc>()..add(const LoadAllOrders()),
  child: BlocConsumer<AdminOrdersBloc, AdminOrdersState>(
    listener: (context, state) {
      if (state is AdminOrdersError) {
        // Show error snackbar
      }
    },
    builder: (context, state) {
      if (state is AdminOrdersLoaded) {
        // Display orders
      }
      // Loading/Error states
    },
  ),
)
```

**Đặc biệt:**
- ✅ Real-time updates qua stream
- ✅ Status change với confirmation
- ✅ Color-coded status

#### **D. UserFormPage** (`presentation/pages/user_form_page.dart`)

**Chức năng:**
- Form để admin tạo user mới
- Set role (customer hoặc admin)

**Form Fields:**
- Tên hiển thị (required)
- Email (required, validated)
- Mật khẩu (required, ≥ 6 ký tự)
- Số điện thoại (optional)
- Vai trò dropdown (customer/admin)

**Validation:**
- Email format check
- Password length check
- Required fields check

**Submit Flow:**
```
User fill form + click "Thêm Người dùng"
  → Validate form
    → CustomersBloc.add(CreateUser(...))
      → CreateUserByAdminUseCase()
        → Success: Show success snackbar → Close page
        → Error: Show error snackbar
```

**State Management:**
```dart
BlocListener<CustomersBloc, CustomersState>(
  listener: (context, state) {
    if (state is CustomersError) {
      // Show error snackbar
    } else if (state is CustomersLoaded) {
      // Success - close page
      Navigator.pop(context, true);
    }
  },
  child: ...,
)
```

---

## 🔑 ĐIỂM CẦN LƯU Ý QUAN TRỌNG

### 1. ⚠️ Real-time Stream Pattern

**Vấn đề:**
- Cần real-time updates cho users và orders
- Multiple subscriptions có thể gây memory leak

**Solution:**
- ✅ Cancel previous subscription trước khi tạo mới
- ✅ Cleanup subscription trong `close()` method
- ✅ Stream tự động emit khi có thay đổi

**Implementation:**
```dart
void _onLoadUsers(LoadUsers event, Emitter<CustomersState> emit) {
  _usersSubscription?.cancel();  // Cancel previous
  _usersSubscription = _getAllUsersUseCase().listen(...);
}

@override
Future<void> close() {
  _usersSubscription?.cancel();  // Cleanup
  return super.close();
}
```

### 2. 📊 Overview Stats Complexity

**Vấn đề:**
- Cần combine multiple data sources
- Performance có thể không tốt nếu orders thay đổi nhiều

**Current Implementation:**
- ✅ Listen orders stream (real-time)
- ⚠️ Fetch users và products mỗi khi orders thay đổi (không cache)

**Có thể cải thiện:**
- Cache users và products
- Chỉ fetch khi cần thiết
- Debounce stats updates

### 3. 🔄 Stream Auto-update Pattern

**Pattern:**
- Update data trong Firestore
- Stream tự động emit new data
- BLoC nhận `UsersUpdated`/`OrdersUpdated` event
- UI tự động refresh

**Lợi ích:**
- ✅ Không cần reload manually
- ✅ Real-time sync
- ✅ Consistent data

**Example:**
```dart
// Update status
await updateUserStatusUseCase(userId, true);

// Stream tự động emit → UsersUpdated event → UI refresh
// Không cần emit CustomersLoaded manually
```

### 4. 🎯 Role-based Management

**User Roles:**
- `'customer'`: Khách hàng (default)
- `'admin'`: Quản trị viên

**CreateUserByAdmin:**
- ✅ Admin có thể set role khi tạo user
- ✅ Có thể tạo admin mới

**Lưu ý:**
- ⚠️ Chỉ admin mới được access Admin feature
- ⚠️ Route guards cần check role

### 5. 🔒 Security Considerations

**Firestore Security Rules:**
- ⚠️ Phải setup rules để:
  - Admin mới được read/write all users
  - Admin mới được read/write all orders
  - Regular users không thể access admin functions

**Example rules:**
```javascript
// Users collection
match /users/{userId} {
  // Admin có thể read/write all
  allow read, write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
  
  // User chỉ được read/write chính mình
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

// Orders collection
match /orders/{orderId} {
  // Admin có thể read/write all
  allow read, write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

### 6. 📈 Dashboard Stats Calculation

**Current Logic:**
- totalOrders: `orders.length`
- totalRevenue: `orders.fold(0, (sum, order) => sum + order.totalAmount)`
- totalCustomers: `users.where((u) => u.role == 'customer').length`
- totalProducts: `products.length`

**Lưu ý:**
- ⚠️ Revenue tính từ tất cả orders (bao gồm cả cancelled)
- ⚠️ Có thể filter theo status nếu cần

### 7. 🔄 Multi-BLoC Pattern

**3 BLoCs riêng biệt:**
- CustomersBloc: Manage users
- AdminOrdersBloc: Manage orders
- OverviewBloc: Dashboard stats

**Lợi ích:**
- ✅ Separation of concerns
- ✅ Independent state management
- ✅ Easier to test và maintain

**Lưu ý:**
- ⚠️ Mỗi page có BLoC riêng
- ⚠️ Lifecycle được quản lý bởi BlocProvider

### 8. 🎨 UI/UX Features

**Search:**
- ✅ Real-time search trong CustomersPage
- ✅ Filter by name hoặc email
- ✅ Search results counter

**Stats:**
- ✅ Visual stats cards với icons
- ✅ Color-coded
- ✅ Compact number formatting

**Status Management:**
- ✅ Confirmation dialogs
- ✅ Color-coded status indicators
- ✅ Vietnamese labels

---

## 💡 ĐIỂM HAY CỦA KIẾN TRÚC

### 1. 🏗️ Clean Architecture Benefits

- **Separation of Concerns**: Admin logic tách biệt
- **Reuse Repositories**: Tận dụng Auth và Orders repositories
- **Testability**: Dễ test từng use case độc lập

### 2. 🔄 Real-time Streams

**Auto-updates:**
- ✅ Users và orders tự động update
- ✅ No manual refresh needed
- ✅ Consistent data

### 3. 🎯 Multi-BLoC Pattern

**Independent State:**
- ✅ Mỗi module có BLoC riêng
- ✅ No state conflicts
- ✅ Better organization

### 4. 📊 Dashboard Stats

**Complex Stream Composition:**
- ✅ Combine multiple data sources
- ✅ Real-time updates
- ✅ Clear separation với use case

### 5. 🔄 Stream Auto-update Pattern

**No Manual Reload:**
- ✅ Update → Stream emit → UI refresh
- ✅ Better UX
- ✅ Less code

---

## 🚀 CÁC ĐIỂM CÓ THỂ CẢI THIỆN

### 1. 📊 Dashboard Stats Optimization

**Hiện tại:**
- Fetch users và products mỗi khi orders thay đổi

**Có thể cải thiện:**
- Cache users và products
- Debounce stats updates
- Separate streams cho users và products
- Use stream combinators (RxDart)

### 2. 🔍 Advanced Filtering

**Có thể thêm:**
- Filter users by role
- Filter orders by status
- Filter orders by date range
- Sort options

### 3. 📈 Enhanced Analytics

**Có thể thêm:**
- Revenue chart (daily/weekly/monthly)
- Orders trend
- Top customers
- Top products
- Conversion rate

### 4. 📄 Pagination

**Hiện tại:**
- Load tất cả users/orders một lần

**Có thể cải thiện:**
- Pagination với limit/offset
- Infinite scroll
- Better performance với large datasets

### 5. 📊 Bulk Operations

**Có thể thêm:**
- Bulk lock/unlock users
- Bulk update order status
- Export data (CSV, Excel)

### 6. 🔔 Notifications

**Có thể thêm:**
- New order notifications
- Low stock alerts
- User activity alerts

### 7. 📧 Email Integration

**Có thể thêm:**
- Send email khi lock/unlock user
- Send order status update email
- Send reports

### 8. 🔐 Audit Log

**Có thể thêm:**
- Track admin actions
- Log status changes
- Security audit trail

### 9. 🎨 Dashboard Enhancements

**Có thể thêm:**
- Charts và graphs
- Recent activities
- Quick actions
- Shortcuts

### 10. ⚡ Performance

**Có thể cải thiện:**
- Virtual scrolling cho large lists
- Image lazy loading
- Data pagination
- Query optimization

---

## 📊 TÓM TẮT LUỒNG HOẠT ĐỘNG

### **Admin xem dashboard:**
```
1. Navigate to OverviewPage
2. BlocProvider create OverviewBloc
3. OverviewBloc.add(LoadOverviewStats())
4. GetOverviewStatsUseCase()
   → Listen getAllOrders() stream
   → await for (orders in stream)
     → Calculate totalOrders, totalRevenue
     → Fetch users (snapshot)
       → Calculate totalCustomers
     → Fetch products (snapshot)
       → Calculate totalProducts
     → Yield OverviewStats
5. OverviewBloc emit OverviewLoaded(stats)
6. UI display stats cards
7. Auto-update khi có order mới
```

### **Admin quản lý users:**
```
1. Navigate to CustomersPage
2. BlocProvider create CustomersBloc
3. CustomersBloc.add(LoadUsers())
4. Listen getAllUsers() stream
5. Stream emit → UsersUpdated event
6. CustomersBloc emit CustomersLoaded(users)
7. UI display users list

Admin toggle status:
  → ToggleUserStatus event
    → UpdateUserStatusUseCase()
      → Firestore update
        → Stream auto-emit → UI refresh

Admin create user:
  → Navigate to UserFormPage
    → CreateUser event
      → CreateUserByAdminUseCase()
        → Firestore create
          → Stream auto-emit → UI refresh
```

### **Admin quản lý orders:**
```
1. Navigate to OrdersPage
2. BlocProvider create AdminOrdersBloc
3. AdminOrdersBloc.add(LoadAllOrders())
4. Listen getAllOrders() stream
5. Stream emit → OrdersUpdated event
6. AdminOrdersBloc emit AdminOrdersLoaded(orders)
7. UI display orders list

Admin update status:
  → UpdateOrderStatus event
    → UpdateOrderStatusUseCase()
      → Firestore update
        → Stream auto-emit → UI refresh
```

---

## ✅ CHECKLIST ĐỂ VẬN HÀNH TỐT

- [ ] Firestore security rules setup đúng (admin only)
- [ ] Role check trong route guards
- [ ] Stream subscriptions được cleanup đúng
- [ ] Overview stats tính toán đúng
- [ ] Real-time updates hoạt động
- [ ] Error handling đầy đủ
- [ ] Confirmation dialogs cho sensitive operations
- [ ] Search functionality hoạt động
- [ ] Status colors hiển thị đúng
- [ ] User form validation đúng

---

## 🎓 KẾT LUẬN

Feature Admin được thiết kế tốt với:
- ✅ Clean Architecture (domain layer riêng)
- ✅ Reuse repositories từ Auth và Orders
- ✅ Real-time streams cho auto-updates
- ✅ Multi-BLoC pattern (separation)
- ✅ Complex stream composition cho dashboard

**Điểm mạnh:**
- Real-time updates (no manual refresh)
- Stream auto-update pattern
- Multi-BLoC separation
- Reuse existing repositories
- Dashboard stats với stream composition

**Có thể cải thiện:**
- Dashboard stats optimization (cache)
- Advanced filtering và sorting
- Pagination cho large datasets
- Enhanced analytics và charts
- Audit logging
- Bulk operations

---

**Tác giả:** AI Assistant  
**Ngày:** 2024

