# 🔐 GIẢI THÍCH CHI TIẾT FEATURE AUTHENTICATION

## 🏗️ KIẾN TRÚC TỔNG QUAN

Feature Auth được xây dựng theo **Clean Architecture** với BLoC pattern cho state management:

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (UI)             │
│  ┌──────────┬──────────┬──────────────┐  │
│  │ Screens  │ Widgets  │ BLoC         │  │
│  │          │          │ (State Mgmt)│  │
│  └──────────┴──────────┴──────────────┘  │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│     DOMAIN LAYER (Business Logic)       │
│  ┌──────────┬──────────┬─────────────┐  │
│  │ Entities │ UseCases │ Repository   │  │
│  │          │          │ Interface   │  │
│  └──────────┴──────────┴─────────────┘  │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│     DATA LAYER (External Data)          │
│  ┌──────────┬──────────┬─────────────┐  │
│  │ Models   │ Data-     │ Repository  │  │
│  │          │ sources   │ Impl        │  │
│  └──────────┴──────────┴─────────────┘  │
└─────────────────────────────────────────┘
```

---

## 📁 CẤU TRÚC THƯ MỤC

```
lib/features/auth/
├── data/                           # DATA LAYER
│   ├── datasource/
│   │   └── firebase_auth_datasource.dart  # Firebase Auth + Firestore operations
│   ├── model/
│   │   └── user_model.dart                 # UserModel extends AppUser
│   └── repository/
│       └── auth_repository_impl.dart        # Repository implementation
│
├── domain/                         # DOMAIN LAYER
│   ├── entities/
│   │   └── app_user.dart                    # AppUser entity (immutable, Equatable)
│   ├── repository/
│   │   └── auth_repository.dart            # IAuthRepository interface
│   └── usecase/                           # Business logic operations
│       ├── login.dart
│       ├── register.dart
│       ├── logout.dart
│       ├── google_sign_in.dart
│       ├── forgot_password.dart
│       └── get_auth_state_changes.dart
│
└── presentation/                    # PRESENTATION LAYER
    ├── bloc/                             # BLoC State Management
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── screens/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   └── forgot_password_screen.dart
    └── widgets/
        ├── auth_button.dart
        ├── auth_text_field.dart
        └── social_button_row.dart
```

---

## 🔄 LUỒNG HOẠT ĐỘNG CHI TIẾT

### 1. 🎯 DOMAIN LAYER - Business Logic

#### **AppUser Entity** (`domain/entities/app_user.dart`)

```dart
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;              // 'customer' hoặc 'admin'
  final String? defaultAddressId;
  final bool isDisabled;          // Account disabled by admin
  final DateTime createdAt;
}
```

**Đặc điểm:**
- ✅ **Immutable**: Tất cả fields đều `final` (không thể thay đổi sau khi tạo)
- ✅ **Equatable**: Override `props` để so sánh objects dựa trên values
- ✅ **Pure Domain**: Không phụ thuộc vào Firebase hay bất kỳ framework nào
- ✅ **Role-based**: Có field `role` để phân quyền (`customer` vs `admin`)
- ✅ **Account Management**: Có `isDisabled` để admin có thể khóa tài khoản

#### **IAuthRepository Interface** (`domain/repository/auth_repository.dart`)

```dart
abstract class IAuthRepository {
  // Authentication
  Future<Either<Failure, AppUser>> login(String email, String password);
  Future<Either<Failure, AppUser>> register({...});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AppUser>> googleSignIn();
  
  // Password recovery
  Future<Either<Failure, void>> forgotPassword(String email);
  
  // User management
  Stream<AppUser?> get authStateChanges;  // Real-time auth state stream
  Future<AppUser?> getCurrentUser();
  Future<AppUser?> updateUser({...});
  Future<Either<Failure, void>> changePassword({...});
  Future<AppUser?> uploadAvatarImage(XFile imageFile);
  
  // Admin functions
  Stream<List<AppUser>> getAllUsers();
  Future<Either<Failure, void>> updateUserStatus(String userId, bool isDisabled);
  Future<Either<Failure, AppUser>> createUserByAdmin({...});
}
```

**Đặc điểm:**
- ✅ **Either<Failure, T> Pattern**: Dùng `dartz` package để handle errors functional way
  - `Left(Failure)` = Error
  - `Right(T)` = Success
- ✅ **Stream-based**: `authStateChanges` trả về Stream để listen real-time changes
- ✅ **Comprehensive**: Bao gồm cả user management và admin functions

#### **Use Cases** - Business Operations

Mỗi use case đại diện cho một hành động cụ thể:

1. **LoginUseCase**: Đăng nhập với email/password
2. **RegisterUseCase**: Đăng ký tài khoản mới
3. **LogoutUseCase**: Đăng xuất
4. **GoogleSignInUseCase**: Đăng nhập bằng Google
5. **ForgotPasswordUseCase**: Gửi email reset password
6. **GetAuthStateChangesUseCase**: Lấy stream auth state changes

**Pattern:**
```dart
class LoginUseCase {
  final IAuthRepository _repository;
  LoginUseCase(this._repository);
  
  Future<Either<Failure, AppUser>> call(String email, String password) {
    return _repository.login(email, password);
  }
}
```

- ✅ Mỗi use case chỉ làm MỘT việc (Single Responsibility)
- ✅ Dễ test vì chỉ phụ thuộc vào repository interface
- ✅ Có thể inject mock repository để test

---

### 2. 💾 DATA LAYER - Firebase Integration

#### **UserModel** (`data/model/user_model.dart`)

```dart
class UserModel extends AppUser {
  // Extends AppUser, thêm serialization methods
}
```

**Nhiệm vụ:**
- ✅ **fromSnapshot()**: Convert Firestore DocumentSnapshot → UserModel
- ✅ **toMap()**: Convert UserModel → Map<String, dynamic> (để lưu vào Firestore)

**Đặc biệt:**
- Xử lý Timestamp conversion (Firestore → DateTime)
- Default values khi data thiếu
- Type safety với null handling

#### **FirebaseAuthDatasource** (`data/datasource/firebase_auth_datasource.dart`)

**Kết hợp 2 Firebase services:**

1. **Firebase Authentication**: Quản lý authentication (login, register, logout)
2. **Firestore**: Lưu trữ user profile (email, displayName, role, etc.)

**Các operations chính:**

##### **1. Login Flow:**
```dart
Future<UserModel> login(String email, String password) async {
  // 1. Authenticate với Firebase Auth
  final userCredential = await _auth.signInWithEmailAndPassword(...);
  
  // 2. Lấy profile từ Firestore
  final userDoc = await _usersCollection.doc(userCredential.user!.uid).get();
  
  // 3. Convert sang UserModel
  return UserModel.fromSnapshot(userDoc);
}
```

**Luồng:**
- Firebase Auth xác thực email/password
- Nếu thành công → lấy UID
- Query Firestore collection `users` với UID
- Trả về UserModel đầy đủ (role, displayName, etc.)

##### **2. Register Flow:**
```dart
Future<UserModel> register(...) async {
  // 1. Tạo user trong Firebase Auth
  final userCredential = await _auth.createUserWithEmailAndPassword(...);
  final uid = userCredential.user!.uid;
  
  // 2. Tạo UserModel mới
  final newUser = UserModel(
    id: uid,
    email: email,
    displayName: displayName,
    role: 'customer',  // Mặc định
    isDisabled: false,
    createdAt: DateTime.now(),
    ...
  );
  
  // 3. Lưu vào Firestore
  await _usersCollection.doc(uid).set(newUser.toMap());
  
  // 4. Update displayName trong Firebase Auth profile
  await userCredential.user?.updateDisplayName(displayName);
  
  return newUser;
}
```

**Đặc biệt:**
- ✅ Tạo user trong cả Firebase Auth VÀ Firestore
- ✅ Default role là `'customer'`
- ✅ Sync displayName lên Firebase Auth profile

##### **3. Google Sign In Flow:**
```dart
Future<UserModel> signInWithGoogle() async {
  // 1. Google Sign In
  final googleUser = await GoogleSignIn().signIn();
  final credential = firebase.GoogleAuthProvider.credential(...);
  
  // 2. Authenticate với Firebase
  final userCredential = await _auth.signInWithCredential(credential);
  final uid = userCredential.user!.uid;
  
  // 3. Check xem đã có profile trong Firestore chưa
  final docRef = _usersCollection.doc(uid);
  final snap = await docRef.get();
  
  if (!snap.exists) {
    // Lần đầu đăng nhập → tạo profile mới
    final newUser = UserModel(...);
    await docRef.set(newUser.toMap());
    return newUser;
  }
  
  // Đã có profile → return existing
  return UserModel.fromSnapshot(snap);
}
```

**Đặc biệt:**
- ✅ Auto-create profile nếu lần đầu đăng nhập
- ✅ Lấy avatarUrl từ Google account
- ✅ Reuse existing profile nếu đã đăng nhập trước đó

##### **4. Auth State Changes Stream:**
```dart
Stream<UserModel?> get authStateChanges {
  final controller = StreamController<UserModel?>();
  
  StreamSubscription? userDocSub;
  StreamSubscription? authSub;
  
  // Listen Firebase Auth changes
  authSub = _auth.authStateChanges().listen((firebaseUser) {
    if (firebaseUser == null) {
      controller.add(null);  // Logged out
    } else {
      // Listen Firestore profile changes
      userDocSub = _usersCollection.doc(firebaseUser.uid)
        .snapshots()
        .listen((snap) {
          if (snap.exists) {
            controller.add(UserModel.fromSnapshot(snap));
          } else {
            controller.add(null);
          }
        });
    }
  });
  
  return controller.stream;
}
```

**Cơ chế hoạt động:**
1. Listen Firebase Auth state changes (login/logout)
2. Khi có user → listen Firestore profile changes
3. Combine cả 2 streams → trả về UserModel đầy đủ
4. Real-time updates khi profile thay đổi

**Lợi ích:**
- ✅ Real-time sync giữa Auth và Firestore
- ✅ Tự động update UI khi profile thay đổi
- ✅ Handle cả login/logout events

##### **5. Update User Profile:**
```dart
Future<void> updateUser({
  String? displayName,
  String? avatarUrl,
  String? phoneNumber,
  String? defaultAddressId,
}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('No logged-in user!');
  
  // Update Firestore
  await _usersCollection.doc(user.uid).update(data);
  
  // Sync displayName lên Firebase Auth
  if (displayName != null) {
    await user.updateDisplayName(displayName);
  }
}
```

**Đặc biệt:**
- ✅ Update Firestore profile
- ✅ Sync displayName lên Firebase Auth (để hiển thị trong app)

##### **6. Change Password:**
```dart
Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  final user = _auth.currentUser;
  final email = user.email;
  
  // Re-authenticate với password cũ
  final credential = firebase.EmailAuthProvider.credential(
    email: email,
    password: currentPassword,
  );
  await user.reauthenticateWithCredential(credential);
  
  // Update password
  await user.updatePassword(newPassword);
}
```

**Security:**
- ✅ Re-authentication bắt buộc trước khi đổi password
- ✅ Verify password cũ là đúng

##### **7. Admin Functions:**
```dart
// Lấy tất cả users (cho admin)
Stream<List<UserModel>> getAllUsers() {
  return _usersCollection
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .toList());
}

// Khóa/mở khóa tài khoản
Future<void> updateUserStatus(String userId, bool isDisabled) async {
  await _usersCollection.doc(userId).update({'isDisabled': isDisabled});
}
```

**Admin capabilities:**
- ✅ Xem tất cả users
- ✅ Khóa/mở khóa tài khoản (`isDisabled`)
- ✅ Tạo user mới bởi admin

#### **AuthRepositoryImpl** (`data/repository/auth_repository_impl.dart`)

**Adapter pattern** - Kết nối Domain và Data layer:

```dart
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthDatasource dataSource;
  final CloudinaryService cloudinaryService;
  
  @override
  Future<Either<Failure, AppUser>> login(String email, String password) async {
    try {
      final userModel = await dataSource.login(email, password);
      return Right(userModel);  // Success
    } on firebase.FirebaseAuthException catch (e) {
      final message = _mapFirebaseError(e, isRegister: false);
      return Left(Failure(message));  // Error
    }
  }
}
```

**Nhiệm vụ:**
- ✅ Convert UserModel → AppUser entity
- ✅ Convert Firebase exceptions → Domain Failure
- ✅ Map error codes sang messages thân thiện với user
- ✅ Upload avatar qua CloudinaryService

**Error Mapping:**
```dart
String _mapFirebaseError(firebase.FirebaseAuthException e, {required bool isRegister}) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Email đã được sử dụng. Hãy dùng email khác.';
    case 'weak-password':
      return 'Mật khẩu quá yếu. Vui lòng dùng mật khẩu ≥ 6 ký tự.';
    case 'user-not-found':
      return 'Không tìm thấy tài khoản. Vui lòng kiểm tra lại.';
    case 'wrong-password':
      return 'Mật khẩu không đúng.';
    // ... more mappings
  }
}
```

**Đặc biệt:**
- ✅ User-friendly error messages (tiếng Việt)
- ✅ Context-aware messages (khác nhau cho register vs login)

---

### 3. 🎨 PRESENTATION LAYER - UI với BLoC

#### **A. BLoC Pattern** - State Management

##### **AuthEvent** (`presentation/bloc/auth_event.dart`)

```dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthStateChanged extends AuthEvent {
  final AppUser? user;
  const AuthStateChanged(this.user);
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested(this.email, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String? phoneNumber;
  // ...
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested(this.email);
}

class AuthGoogleSignInRequested extends AuthEvent {}
```

**Đặc điểm:**
- ✅ Immutable events (tất cả fields đều `final`)
- ✅ Extends `Equatable` để compare events
- ✅ Mỗi event đại diện cho một user action

##### **AuthState** (`presentation/bloc/auth_state.dart`)

```dart
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {}  // Initial state

class AuthLoading extends AuthState {}  // Loading state

class AuthAuthenticated extends AuthState {
  final AppUser user;  // User đã đăng nhập
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}  // Chưa đăng nhập

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}

class AuthForgotPasswordLoading extends AuthState {}

class AuthForgotPasswordSuccess extends AuthState {}
```

**State machine:**
```
AuthInitial
  ↓
AuthLoading → AuthAuthenticated
  ↓             ↓
AuthFailure   (user logged in)
              ↓
           AuthUnauthenticated (logout)
```

##### **AuthBloc** (`presentation/bloc/auth_bloc.dart`)

**Luồng hoạt động:**

1. **Constructor - Setup stream listener:**
```dart
AuthBloc({...}) : super(AuthInitial()) {
  // Register event handlers
  on<AuthStateChanged>(_onAuthStateChanged);
  on<AuthLoginRequested>(_onLoginRequested);
  // ...
  
  // Listen auth state changes từ repository
  _authSubscription = _getAuthStateChangesUseCase().listen((user) {
    add(AuthStateChanged(user));  // Emit event khi có thay đổi
  });
}
```

**Đặc biệt:**
- ✅ Tự động listen auth state changes
- ✅ Auto-update state khi user login/logout từ nơi khác (ví dụ: từ Settings)
- ✅ Cleanup subscription khi bloc dispose

2. **Login Handler:**
```dart
void _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());  // Show loading
  
  final result = await _loginUseCase(event.email, event.password);
  
  result.fold(
    (failure) => emit(AuthFailure(failure.message)),  // Error
    (user) => emit(AuthAuthenticated(user)),          // Success
  );
}
```

**Either Pattern:**
- `fold()` nhận 2 callbacks:
  - Left callback: Xử lý error
  - Right callback: Xử lý success

3. **Register Handler:**
```dart
void _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  
  final result = await _registerUseCase(
    email: event.email,
    password: event.password,
    displayName: event.displayName,
    phoneNumber: event.phoneNumber,
  );
  
  result.fold(
    (failure) => emit(AuthFailure(failure.message)),
    (user) => emit(AuthAuthenticated(user)),  // Auto-login sau khi đăng ký
  );
}
```

4. **Logout Handler:**
```dart
void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
  await _logoutUseCase();
  emit(AuthUnauthenticated());
}
```

5. **Forgot Password Handler:**
```dart
Future<void> _onForgotPasswordRequested(
  AuthForgotPasswordRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthForgotPasswordLoading());
  
  final result = await _forgotPasswordUseCase(event.email);
  
  result.fold(
    (failure) => emit(AuthFailure(failure.message)),
    (_) => emit(AuthForgotPasswordSuccess()),
  );
}
```

6. **Google Sign In Handler:**
```dart
Future<void> _onGoogleSignInRequested(
  AuthGoogleSignInRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());
  
  final result = await _googleSignInUseCase();
  
  result.fold(
    (failure) => emit(AuthFailure(failure.message)),
    (user) => emit(AuthAuthenticated(user)),
  );
}
```

**Cleanup:**
```dart
@override
Future<void> close() {
  _authSubscription?.cancel();  // Cancel stream subscription
  return super.close();
}
```

#### **B. UI Screens**

##### **1. LoginScreen** (`presentation/screens/login_screen.dart`)

**Luồng hoạt động:**
```
User nhập email/password
  → Click "ĐĂNG NHẬP"
    → _handleLogin() (validate form)
      → context.read<AuthBloc>().add(AuthLoginRequested(...))
        → AuthBloc emit AuthLoading
          → UI hiển thị "Đang đăng nhập..."
            → UseCase xử lý
              → Success: AuthAuthenticated
                → BlocListener detect
                  → Navigate: admin → '/admin/overview', customer → '/home'
              → Error: AuthFailure
                → BlocListener detect
                  → Show SnackBar với error message
```

**Validation:**
- Email phải chứa '@'
- Password ≥ 6 ký tự
- Show/hide password toggle

**BLoC Integration:**
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      final isAdmin = state.user.role == 'admin';
      context.go(isAdmin ? '/admin/overview' : '/home');
    } else if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: ...,
)
```

**Đặc biệt:**
- ✅ Role-based navigation (admin vs customer)
- ✅ Error handling với user-friendly messages
- ✅ Loading state management

##### **2. SignUpScreen** (`presentation/screens/signup_screen.dart`)

**Fields:**
- Họ và tên (required)
- Email (required, validated)
- Mật khẩu (required, ≥ 6 ký tự)
- Nhập lại mật khẩu (required, phải khớp)
- Số điện thoại (optional)

**Validation logic:**
```dart
void _handleSignUp() {
  // Validate tất cả fields
  if (!isNameValid || !isEmailValid || ...) {
    // Show error
    return;
  }
  
  // Validate password match
  if (confirmPasswordController.text != passwordController.text) {
    // Show error
    return;
  }
  
  // Trigger register event
  context.read<AuthBloc>().add(
    AuthRegisterRequested(
      email: emailController.text.trim(),
      password: passwordController.text,
      displayName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim().isEmpty 
          ? null 
          : phoneController.text.trim(),
    ),
  );
}
```

**Đặc biệt:**
- ✅ Real-time validation (khi user type)
- ✅ Confirm password validation
- ✅ Optional phone number
- ✅ Auto-login sau khi đăng ký thành công

##### **3. ForgotPasswordScreen** (`presentation/screens/forgot_password_screen.dart`)

**Luồng:**
```
User nhập email
  → Click "Gửi"
    → Validate email format
      → context.read<AuthBloc>().add(AuthForgotPasswordRequested(email))
        → AuthBloc emit AuthForgotPasswordLoading
          → UseCase gửi email reset password
            → Success: AuthForgotPasswordSuccess
              → Show SnackBar "Đã gửi liên kết đặt lại mật khẩu!"
```

**Email validation:**
```dart
void _validateEmail(String value) {
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  setState(() => isEmailValid = regex.hasMatch(value));
}
```

**Đặc biệt:**
- ✅ Email format validation
- ✅ Firebase tự động gửi reset email
- ✅ User sẽ nhận email với link reset password (Firebase Console config)

##### **4. Reusable Widgets**

**AuthTextField:**
- Custom text field với validation UI
- Error messages
- Show/hide password toggle

**AuthButton:**
- Primary button style
- Loading state support

**SocialButtonRow:**
- Google Sign In button

---

## 🔑 ĐIỂM CẦN LƯU Ý QUAN TRỌNG

### 1. ⚠️ Dual Storage Strategy

**Vấn đề:**
- Firebase Auth chỉ lưu: email, displayName, photoURL
- App cần thêm: role, phoneNumber, avatarUrl, defaultAddressId, isDisabled

**Solution:**
- ✅ Firebase Auth: Quản lý authentication
- ✅ Firestore collection `users`: Lưu profile đầy đủ

**Sync strategy:**
- Khi đăng ký: Tạo user trong cả Auth và Firestore
- Khi update profile: Update cả Firestore và Firebase Auth (displayName)
- Khi login: Lấy profile từ Firestore (đầy đủ hơn Auth)

**Lưu ý:**
- ⚠️ Phải đảm bảo Firestore profile luôn sync với Auth
- ⚠️ Nếu user tồn tại trong Auth nhưng không có trong Firestore → Error

### 2. 🔄 Real-time Auth State Management

**Cơ chế:**
```
Firebase Auth State Changes
  ↓
Firestore Profile Changes (nếu có user)
  ↓
Combined Stream → UserModel?
  ↓
AuthBloc emits AuthStateChanged event
  ↓
UI tự động update
```

**Lợi ích:**
- ✅ Auto-update UI khi user login/logout từ nơi khác
- ✅ Real-time sync profile changes
- ✅ Handle multiple devices (login trên device khác → auto logout trên device này)

**Lưu ý:**
- Stream subscription được quản lý bởi AuthBloc
- Phải cleanup khi bloc dispose

### 3. 🎭 Role-based Access Control

**Implementation:**
- User có field `role`: `'customer'` hoặc `'admin'`
- Navigation sau login dựa trên role:
  ```dart
  final isAdmin = state.user.role == 'admin';
  context.go(isAdmin ? '/admin/overview' : '/home');
  ```

**Lưu ý:**
- ⚠️ Default role là `'customer'`
- ⚠️ Admin role phải được set manually trong Firestore (hoặc qua admin panel)
- ⚠️ Cần check role ở các protected routes

### 4. 🔒 Security Considerations

**Firebase Auth Security:**
- ✅ Password hashing tự động bởi Firebase
- ✅ JWT tokens để authenticate requests
- ✅ Re-authentication required cho sensitive operations (đổi password)

**Firestore Security Rules:**
- ⚠️ Phải setup rules trong Firebase Console:
  ```javascript
  match /users/{userId} {
    // User chỉ được đọc/update profile của chính mình
    allow read: if request.auth != null && request.auth.uid == userId;
    allow write: if request.auth != null && request.auth.uid == userId;
    
    // Admin có thể đọc tất cả users
    allow read: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
  }
  ```

**Error Handling:**
- ✅ Firebase exceptions được map sang user-friendly messages
- ✅ Không expose sensitive error details

### 5. 📸 Avatar Upload

**Luồng:**
```
User chọn ảnh
  → UploadProductImage useCase
    → CloudinaryService.uploadAvatarImage()
      → Upload lên Cloudinary (folder: 'avatars')
        → Nhận secure URL
          → updateUser(avatarUrl: url)
            → Update Firestore
              → Stream auto-update UI
```

**Đặc biệt:**
- ✅ Images lưu trên Cloudinary (không phải Firebase Storage)
- ✅ Auto-update UI qua authStateChanges stream

### 6. 🔄 Error Handling với Either Pattern

**Pattern:**
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
final result = await _loginUseCase(...);
result.fold(
  (failure) => emit(AuthFailure(failure.message)),
  (user) => emit(AuthAuthenticated(user)),
);
```

**Lợi ích:**
- ✅ Functional programming approach
- ✅ Type-safe error handling
- ✅ Compiler enforces error handling

### 7. 🌐 Google Sign In

**Setup requirements:**
1. Enable Google Sign In trong Firebase Console
2. Add SHA-1 fingerprint (Android)
3. Configure OAuth consent screen (iOS)

**Flow:**
1. User click Google button
2. Google Sign In SDK opens OAuth flow
3. User chọn Google account
4. Nhận ID token + Access token
5. Authenticate với Firebase bằng credential
6. Check Firestore profile → create nếu chưa có

**Đặc biệt:**
- ✅ Auto-create profile lần đầu
- ✅ Reuse existing profile nếu đã đăng nhập trước
- ✅ Lấy avatar từ Google account

### 8. 📧 Password Reset

**Flow:**
1. User nhập email
2. Firebase Auth gửi reset email
3. User click link trong email
4. Firebase redirect về app với reset token
5. User nhập password mới
6. Firebase update password

**Lưu ý:**
- ⚠️ Email template có thể customize trong Firebase Console
- ⚠️ Link reset có expiration time
- ⚠️ Cần handle deep link trong app để handle reset token

---

## 💡 ĐIỂM HAY CỦA KIẾN TRÚC

### 1. 🏗️ Clean Architecture Benefits

- **Separation of Concerns**: Business logic tách biệt hoàn toàn khỏi Firebase
- **Testability**: Dễ test từng layer độc lập (mock repository, mock datasource)
- **Flexibility**: Có thể switch từ Firebase sang Auth0, AWS Cognito, etc.

### 2. 🎯 BLoC Pattern

**Lợi ích:**
- ✅ Reactive state management
- ✅ Predictable state transitions
- ✅ Easy to test
- ✅ Good separation between UI và business logic

**Stream-based:**
- Real-time updates tự động
- Handle async operations elegantly

### 3. 🔄 Either Pattern

**Functional error handling:**
- Type-safe
- Compiler enforces error handling
- Clear success/error paths

### 4. 🔗 Dual Storage Sync

**Smart synchronization:**
- Auth state changes → Auto update Firestore profile
- Firestore profile changes → Auto update UI
- Real-time sync giữa Auth và Firestore

### 5. 👥 Role-based Architecture

**Scalable:**
- Dễ thêm roles mới (ví dụ: 'seller', 'moderator')
- Role checks ở nhiều layer (UI, BLoC, Repository)

---

## 🚀 CÁC ĐIỂM CÓ THỂ CẢI THIỆN

### 1. 🔐 Token Refresh

**Hiện tại:**
- Firebase tự động refresh tokens

**Có thể cải thiện:**
- Implement token refresh handler
- Handle token expiration gracefully

### 2. 📧 Email Verification

**Hiện tại:**
- Chưa có email verification flow

**Có thể thêm:**
- Send verification email sau đăng ký
- Check `emailVerified` flag
- Block access nếu chưa verify

### 3. 🔒 Two-Factor Authentication (2FA)

**Hiện tại:**
- Chỉ có password authentication

**Có thể thêm:**
- SMS OTP
- Email OTP
- Authenticator app (TOTP)

### 4. 📱 Biometric Authentication

**Hiện tại:**
- Chưa có

**Có thể thêm:**
- Face ID / Touch ID
- Fingerprint authentication

### 5. 🔄 Session Management

**Hiện tại:**
- Firebase quản lý session

**Có thể cải thiện:**
- Track active sessions
- Force logout từ các devices khác
- Session timeout

### 6. 🛡️ Rate Limiting

**Hiện tại:**
- Firebase có rate limiting tự động

**Có thể cải thiện:**
- Custom rate limiting logic
- Better error messages cho rate limit

### 7. 📊 Analytics & Logging

**Có thể thêm:**
- Log authentication attempts
- Track failed login attempts
- Security event logging

### 8. 🧪 Unit Tests

**Hiện tại:**
- Có thể có tests

**Nên có:**
- Unit tests cho use cases
- Unit tests cho BLoC
- Integration tests cho repository

---

## 📊 TÓM TẮT LUỒNG HOẠT ĐỘNG

### **User đăng ký:**
```
1. SignUpScreen → User điền form
2. Validate form
3. AuthBloc.add(AuthRegisterRequested(...))
4. RegisterUseCase → AuthRepository.register()
5. FirebaseAuthDatasource.register()
   → Firebase Auth: createUserWithEmailAndPassword()
   → Firestore: set user profile (role: 'customer')
6. Success → AuthAuthenticated state
7. BlocListener → Navigate: admin → '/admin/overview', customer → '/home'
```

### **User đăng nhập:**
```
1. LoginScreen → User nhập email/password
2. AuthBloc.add(AuthLoginRequested(...))
3. LoginUseCase → AuthRepository.login()
4. FirebaseAuthDatasource.login()
   → Firebase Auth: signInWithEmailAndPassword()
   → Firestore: get user profile
5. Success → AuthAuthenticated state
6. BlocListener → Navigate based on role
```

### **Google Sign In:**
```
1. User click Google button
2. AuthBloc.add(AuthGoogleSignInRequested())
3. GoogleSignInUseCase → AuthRepository.googleSignIn()
4. FirebaseAuthDatasource.signInWithGoogle()
   → GoogleSignIn().signIn()
   → Firebase Auth: signInWithCredential()
   → Firestore: check/create profile
5. Success → AuthAuthenticated state
6. Navigate
```

### **Auth State Changes (Real-time):**
```
1. App startup → AuthBloc constructor
2. Listen GetAuthStateChangesUseCase stream
3. Firebase Auth state changes → Firestore profile changes
4. Stream emits UserModel?
5. AuthBloc.add(AuthStateChanged(user))
6. AuthBloc emit AuthAuthenticated or AuthUnauthenticated
7. UI auto-update
```

### **Logout:**
```
1. User click logout
2. AuthBloc.add(AuthLogoutRequested())
3. LogoutUseCase → AuthRepository.logout()
4. FirebaseAuthDatasource.logout()
   → Firebase Auth: signOut()
5. AuthBloc emit AuthUnauthenticated
6. UI navigate to login screen
```

### **Forgot Password:**
```
1. ForgotPasswordScreen → User nhập email
2. AuthBloc.add(AuthForgotPasswordRequested(email))
3. ForgotPasswordUseCase → AuthRepository.forgotPassword()
4. FirebaseAuthDatasource.sendPasswordResetEmail()
   → Firebase Auth: sendPasswordResetEmail()
5. Success → AuthForgotPasswordSuccess
6. Show SnackBar "Đã gửi liên kết..."
```

---

## ✅ CHECKLIST ĐỂ VẬN HÀNH TỐT

- [ ] Firebase Auth enabled trong Firebase Console
- [ ] Email/Password provider enabled
- [ ] Google Sign In configured (SHA-1, OAuth consent screen)
- [ ] Firestore security rules setup đúng
- [ ] Collection `users` structure đúng
- [ ] Email templates customized (nếu cần)
- [ ] Role-based navigation hoạt động đúng
- [ ] Error messages user-friendly
- [ ] Real-time auth state changes hoạt động
- [ ] Logout cleanup đúng
- [ ] Session persistence hoạt động (Firebase tự động)

---

## 🎓 KẾT LUẬN

Feature Auth được thiết kế rất tốt với:
- ✅ Clean Architecture rõ ràng
- ✅ BLoC pattern cho state management
- ✅ Either pattern cho error handling
- ✅ Real-time auth state sync
- ✅ Role-based access control
- ✅ Multiple authentication methods (Email, Google)
- ✅ Comprehensive user management

**Điểm mạnh:**
- Kiến trúc sạch, dễ maintain
- Real-time sync giữa Auth và Firestore
- Type-safe error handling
- Scalable role system

**Có thể cải thiện:**
- Email verification
- 2FA support
- Biometric authentication
- Better session management
- Analytics & logging

---

**Tác giả:** AI Assistant  
**Ngày:** 2024

