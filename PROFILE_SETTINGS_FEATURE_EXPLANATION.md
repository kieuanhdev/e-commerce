# 👤 GIẢI THÍCH CHI TIẾT FEATURES PROFILE & SETTINGS

## 🏗️ KIẾN TRÚC TỔNG QUAN

Profile và Settings được thiết kế để quản lý thông tin user và cài đặt tài khoản. Chúng tận dụng Auth repository để thao tác với user data:

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (UI)             │
│  ┌──────────┬──────────┬──────────────┐  │
│  │ Profile  │ Settings │ BLoC         │  │
│  │ Screen   │ Screen   │ (State Mgmt) │  │
│  └──────────┴──────────┴──────────────┘  │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│     DOMAIN LAYER (Business Logic)       │
│  ┌──────────┬─────────────────────────┐  │
│  │ UseCases │ Repository Interface    │  │
│  │          │ (IAuthRepository)       │  │
│  └──────────┴─────────────────────────┘  │
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

**Lưu ý quan trọng:**
- Profile chỉ có Presentation layer (đọc từ AuthBloc)
- Settings có Domain layer với use cases riêng
- Cả 2 đều dùng chung `IAuthRepository` từ Auth feature

---

## 📁 CẤU TRÚC THƯ MỤC

```
lib/features/
├── profile/                       # PROFILE FEATURE
│   └── presentation/
│       └── profile_screen.dart   # Display user profile, navigation
│
└── settings/                      # SETTINGS FEATURE
    ├── domain/
    │   └── usecase/              # Business logic operations
    │       ├── get_current_user.dart
    │       ├── update_user_settings.dart
    │       ├── change_password.dart
    │       └── upload_avatar_image.dart
    └── presentation/
        ├── bloc/                 # BLoC State Management
        │   ├── settings_bloc.dart
        │   ├── settings_event.dart
        │   └── settings_state.dart
        ├── settings_screen.dart
        └── widgets/
            └── settings_text_field.dart
```

---

## 🔄 LUỒNG HOẠT ĐỘNG CHI TIẾT

### 1. 👤 PROFILE FEATURE - Hiển thị thông tin user

#### **ProfileScreen** (`presentation/profile_screen.dart`)

**Chức năng:**
- ✅ Hiển thị thông tin user (avatar, tên, email)
- ✅ Navigation đến Orders, Settings
- ✅ Logout functionality

**Đặc điểm:**
- **Stateless**: Không quản lý state riêng, đọc từ AuthBloc
- **Reactive**: Tự động update khi auth state thay đổi
- **Simple**: Chỉ để hiển thị, không có logic phức tạp

**Luồng hoạt động:**
```
App start
  → ProfileScreen build
    → BlocBuilder<AuthBloc, AuthState>
      → Check AuthState
        → AuthAuthenticated: Hiển thị user info
          → Avatar (network/asset)
          → Display name
          → Email
          → Navigation tiles (Orders, Settings, Logout)
        → Khác: Show loading/error
```

**Code structure:**
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            // Hiển thị thông tin user
            return ListView(
              children: [
                // Avatar + Name + Email
                // Navigation tiles
              ],
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
```

**Navigation tiles:**
1. **"Đơn hàng của tôi"** → Navigate to Orders screen
2. **"Cài đặt"** → Navigate to Settings screen
3. **"Đăng xuất"** → Trigger logout:
   ```dart
   context.read<AuthBloc>().add(AuthLogoutRequested());
   ```

**Avatar display:**
```dart
final avatar = (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
    ? NetworkImage(user.avatarUrl!)  // Cloudinary URL
    : const AssetImage('images/avatar.png')  // Default avatar
```

**Đặc biệt:**
- ✅ Fallback về default avatar nếu chưa có avatarUrl
- ✅ Real-time update khi user thay đổi profile (qua AuthBloc stream)

---

### 2. ⚙️ SETTINGS FEATURE - Quản lý cài đặt tài khoản

#### **A. Domain Layer - Use Cases**

##### **1. GetCurrentUserUseCase** (`domain/usecase/get_current_user.dart`)

```dart
class GetCurrentUserUseCase {
  final IAuthRepository repo;
  GetCurrentUserUseCase(this.repo);
  
  Future<AppUser?> call() => repo.getCurrentUser();
}
```

**Nhiệm vụ:**
- Lấy user hiện tại từ Auth repository
- Dùng cho Settings screen để load profile data

**Luồng:**
```
GetCurrentUserUseCase()
  → IAuthRepository.getCurrentUser()
    → FirebaseAuthDatasource.getCurrentUser()
      → FirebaseAuth.currentUser
        → Firestore: get user profile
          → Return AppUser
```

##### **2. UpdateUserSettingsUseCase** (`domain/usecase/update_user_settings.dart`)

```dart
class UpdateUserSettingsUseCase {
  final IAuthRepository repo;
  UpdateUserSettingsUseCase(this.repo);
  
  Future<AppUser?> call({
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? defaultAddressId,
  }) {
    return repo.updateUser(
      displayName: displayName,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
      defaultAddressId: defaultAddressId,
    );
  }
}
```

**Nhiệm vụ:**
- Cập nhật thông tin user profile
- Trả về AppUser đã được cập nhật

**Lưu ý:**
- Chỉ update các fields được truyền vào (null = không update)
- Sync displayName lên Firebase Auth profile

##### **3. ChangePasswordUseCase** (`domain/usecase/change_password.dart`)

```dart
class ChangePasswordUseCase {
  final IAuthRepository repo;
  ChangePasswordUseCase(this.repo);
  
  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
```

**Nhiệm vụ:**
- Đổi mật khẩu user
- Yêu cầu re-authentication với password cũ
- Return Either để handle errors

**Security:**
- ✅ Re-authentication bắt buộc
- ✅ Either pattern để handle errors type-safely

##### **4. UploadAvatarImageUseCase** (`domain/usecase/upload_avatar_image.dart`)

```dart
class UploadAvatarImageUseCase {
  final IAuthRepository repo;
  UploadAvatarImageUseCase(this.repo);
  
  Future<AppUser?> call(XFile imageFile) {
    return repo.uploadAvatarImage(imageFile);
  }
}
```

**Nhiệm vụ:**
- Upload ảnh avatar lên Cloudinary
- Update avatarUrl trong Firestore
- Trả về AppUser đã được cập nhật

**Luồng:**
```
UploadAvatarImageUseCase(imageFile)
  → IAuthRepository.uploadAvatarImage()
    → CloudinaryService.uploadAvatarImage()
      → Upload lên Cloudinary (folder: 'avatars')
        → Nhận secure URL
          → AuthRepository.updateUser(avatarUrl: url)
            → Firestore: update avatarUrl
              → Sync displayName (nếu cần)
                → Return updated AppUser
```

---

#### **B. Presentation Layer - BLoC Pattern**

##### **SettingsEvent** (`presentation/bloc/settings_event.dart`)

```dart
abstract class SettingsEvent extends Equatable {}

class LoadSettings extends SettingsEvent {}
// Load user data khi mở Settings screen

class UpdateUserSettings extends SettingsEvent {
  final String? displayName;
  final XFile? avatarImageFile;  // Ảnh mới đã chọn
  final String? phoneNumber;
  final String? defaultAddressId;
}
// Cập nhật thông tin user

class ChangePasswordRequested extends SettingsEvent {
  final String currentPassword;
  final String newPassword;
}
// Đổi mật khẩu

class ImageSelected extends SettingsEvent {
  final XFile imageFile;
}
// Chọn ảnh để preview (chưa upload)
```

**Đặc điểm:**
- `ImageSelected`: Chỉ để preview, chưa upload
- `UpdateUserSettings`: Xử lý upload và update cùng lúc

##### **SettingsState** (`presentation/bloc/settings_state.dart`)

```dart
abstract class SettingsState extends Equatable {}

class SettingsInitial extends SettingsState {}
// Initial state

class SettingsLoading extends SettingsState {}
// Đang load/process

class SettingsLoaded extends SettingsState {
  final AppUser user;
  final String? selectedImagePath;  // Path của ảnh đã chọn (preview)
}
// Đã load thành công

class SettingsError extends SettingsState {
  final String message;
}
// Có lỗi xảy ra

class SettingsUpdated extends SettingsState {
  final String message;
}
// Update thành công

class UploadingAvatar extends SettingsState {
  final AppUser user;
}
// Đang upload avatar (optional, có thể không dùng)
```

**State machine:**
```
SettingsInitial
  ↓
SettingsLoading → SettingsLoaded
  ↓                ↓
SettingsError    (user có thể edit)
                  ↓
              UpdateUserSettings event
                  ↓
              SettingsLoading
                  ↓
              SettingsUpdated → SettingsLoaded (updated user)
                  ↓
              SettingsError (nếu fail)
```

**Đặc biệt:**
- `selectedImagePath`: Lưu path của ảnh đã chọn để preview, nhưng chưa upload
- Sau khi upload thành công → `selectedImagePath = null`

##### **SettingsBloc** (`presentation/bloc/settings_bloc.dart`)

**Constructor - Auto load:**
```dart
SettingsBloc({...}) : super(SettingsInitial()) {
  // Register event handlers
  on<LoadSettings>(_onLoadSettings);
  on<ImageSelected>(_onImageSelected);
  on<UpdateUserSettings>(_onUpdateUserSettings);
  on<ChangePasswordRequested>(_onChangePasswordRequested);
  
  // Auto load khi khởi tạo
  add(LoadSettings());
}
```

**Đặc biệt:**
- ✅ Tự động load user data khi khởi tạo bloc
- ✅ Không cần gọi LoadSettings manually từ UI

**1. LoadSettings Handler:**
```dart
on<LoadSettings>((event, emit) async {
  emit(SettingsLoading());
  try {
    final user = await getCurrentUser();
    if (user == null) {
      emit(const SettingsError('Không tìm thấy tài khoản!'));
    } else {
      emit(SettingsLoaded(user));
    }
  } catch (e) {
    emit(SettingsError(e.toString()));
  }
});
```

**2. ImageSelected Handler:**
```dart
on<ImageSelected>((event, emit) async {
  final currentState = state;
  if (currentState is SettingsLoaded) {
    // Chỉ cập nhật selectedImagePath để preview
    // Chưa upload lên Cloudinary
    emit(SettingsLoaded(
      currentState.user,
      selectedImagePath: event.imageFile.path,
    ));
  }
});
```

**Đặc biệt:**
- ✅ Preview pattern: Chọn ảnh → Preview ngay → Upload khi user click "Lưu"
- ✅ Better UX: User thấy preview trước khi commit

**3. UpdateUserSettings Handler:**
```dart
on<UpdateUserSettings>((event, emit) async {
  emit(SettingsLoading());
  try {
    String? avatarUrl;
    
    // Bước 1: Upload ảnh nếu có
    if (event.avatarImageFile != null) {
      try {
        final updated = await uploadAvatarImageUseCase(event.avatarImageFile!);
        if (updated != null) {
          avatarUrl = updated.avatarUrl;  // Lấy URL từ Cloudinary
        } else {
          emit(const SettingsError('Upload avatar thất bại!'));
          // Rollback: Load lại user data
          final user = await getCurrentUser();
          if (user != null) {
            emit(SettingsLoaded(user));
          }
          return;
        }
      } catch (e) {
        emit(SettingsError('Lỗi khi upload avatar: $e'));
        // Rollback
        final user = await getCurrentUser();
        if (user != null) {
          emit(SettingsLoaded(user));
        }
        return;
      }
    }
    
    // Bước 2: Update user settings (bao gồm avatarUrl nếu có)
    final updated = await updateUserSettings(
      displayName: event.displayName,
      avatarUrl: avatarUrl,
      phoneNumber: event.phoneNumber,
      defaultAddressId: event.defaultAddressId,
    );
    
    if (updated == null) {
      emit(const SettingsError('Cập nhật thất bại!'));
    } else {
      emit(SettingsUpdated('Cập nhật thành công!'));
      emit(SettingsLoaded(updated));  // Reset selectedImagePath = null
    }
  } catch (e) {
    emit(SettingsError(e.toString()));
  }
});
```

**Luồng upload avatar:**
```
UpdateUserSettings event (có avatarImageFile)
  ↓
1. UploadAvatarImageUseCase
   → Upload lên Cloudinary
     → Success: Lấy avatarUrl
     → Error: Rollback, emit error
  ↓
2. UpdateUserSettingsUseCase
   → Update Firestore với avatarUrl + displayName + ...
     → Success: SettingsUpdated → SettingsLoaded
     → Error: SettingsError
```

**Đặc biệt:**
- ✅ 2-step process: Upload image → Update profile
- ✅ Error handling: Rollback về user data cũ nếu upload fail
- ✅ Atomic operation: Nếu upload fail → không update profile

**4. ChangePasswordRequested Handler:**
```dart
on<ChangePasswordRequested>((event, emit) async {
  try {
    final result = await changePasswordUseCase(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => emit(const SettingsUpdated('Đổi mật khẩu thành công!')),
    );
  } catch (e) {
    emit(SettingsError(e.toString()));
  }
});
```

**Đặc biệt:**
- ✅ Either pattern để handle errors
- ✅ Success message để notify user

---

#### **C. UI Screen**

##### **SettingsScreen** (`presentation/settings_screen.dart`)

**State Management:**
```dart
class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _initialized = false;
  Uint8List? _previewImageBytes;  // Bytes của ảnh để preview
}
```

**Đặc điểm:**
- ✅ Local controllers để quản lý form inputs
- ✅ `_previewImageBytes`: Lưu bytes để preview ảnh (chưa upload)

**Avatar Selection Flow:**
```dart
Future<void> _pickImage(BuildContext blocContext) async {
  // 1. Show dialog chọn nguồn (Camera/Gallery)
  final ImageSource? source = await showDialog<ImageSource>(...);
  
  if (source == null) return;
  
  // 2. Pick image
  final XFile? image = await _imagePicker.pickImage(
    source: source,
    imageQuality: 85,
    maxWidth: 800,
    maxHeight: 800,
  );
  
  if (image != null) {
    // 3. Read bytes để preview
    final imageBytes = await image.readAsBytes();
    setState(() {
      _previewImageBytes = imageBytes;
    });
    
    // 4. Emit ImageSelected event (chỉ để preview, chưa upload)
    blocContext.read<SettingsBloc>().add(ImageSelected(imageFile: image));
  }
}
```

**Luồng preview:**
```
User tap avatar
  → _pickImage()
    → Dialog: Camera/Gallery
      → ImagePicker.pickImage()
        → Read bytes → _previewImageBytes
          → setState() → UI update với preview
            → SettingsBloc.add(ImageSelected())
              → SettingsLoaded với selectedImagePath
```

**Avatar Display Logic:**
```dart
CircleAvatar(
  backgroundImage: _previewImageBytes != null
      ? MemoryImage(_previewImageBytes!)  // Preview ảnh mới
      : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
          ? NetworkImage(user.avatarUrl!)  // Avatar hiện tại
          : const AssetImage('images/avatar.png')  // Default
)
```

**Priority order:**
1. Preview image (nếu có) - ưu tiên cao nhất
2. Network image (avatarUrl từ server)
3. Default asset image

**Save Settings Flow:**
```dart
onPressed: () {
  final currentState = context.read<SettingsBloc>().state;
  XFile? selectedImage;
  
  // Lấy XFile từ selectedImagePath nếu có
  if (currentState is SettingsLoaded && currentState.selectedImagePath != null) {
    selectedImage = XFile(currentState.selectedImagePath!);
  }
  
  // Emit UpdateUserSettings event
  context.read<SettingsBloc>().add(
    UpdateUserSettings(
      displayName: _displayNameController.text.trim(),
      avatarImageFile: selectedImage,  // Chỉ có nếu user đã chọn ảnh mới
    ),
  );
}
```

**Change Password Flow:**
```dart
onPressed: () {
  final current = _currentPasswordController.text.trim();
  final next = _newPasswordController.text.trim();
  final confirm = _confirmPasswordController.text.trim();
  
  // Validation
  if (next.isEmpty || current.isEmpty) {
    // Show error
    return;
  }
  
  if (next != confirm) {
    // Show error: passwords don't match
    return;
  }
  
  // Emit ChangePasswordRequested event
  context.read<SettingsBloc>().add(
    ChangePasswordRequested(
      currentPassword: current,
      newPassword: next,
    ),
  );
}
```

**BLoC Listener:**
```dart
BlocConsumer<SettingsBloc, SettingsState>(
  listener: (context, state) {
    if (state is SettingsUpdated) {
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
        ),
      );
    }
    if (state is SettingsError) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  builder: (context, state) {
    // Build UI based on state
  },
)
```

**Reset Preview sau khi save:**
```dart
if (state is SettingsLoaded) {
  // Nếu đã save thành công (selectedImagePath = null)
  // Reset preview bytes
  if (state.selectedImagePath == null && _previewImageBytes != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _previewImageBytes = null;
        });
      }
    });
  }
}
```

---

## 🔑 ĐIỂM CẦN LƯU Ý QUAN TRỌNG

### 1. ⚠️ Shared Repository Pattern

**Vấn đề:**
- Settings use cases dùng chung `IAuthRepository` với Auth feature
- Profile đọc từ `AuthBloc` (không có repository riêng)

**Lợi ích:**
- ✅ DRY (Don't Repeat Yourself): Không duplicate code
- ✅ Single source of truth: User data chỉ ở một nơi
- ✅ Consistency: Cùng một cách update user data

**Lưu ý:**
- Settings updates sẽ trigger AuthBloc stream (vì dùng chung repository)
- Profile screen sẽ tự động update khi Settings thay đổi

### 2. 📸 Avatar Upload Strategy

**2-step process:**
1. **Preview**: User chọn ảnh → Preview ngay (local)
2. **Upload**: User click "Lưu" → Upload lên Cloudinary → Update Firestore

**Lợi ích:**
- ✅ Better UX: User thấy preview trước khi commit
- ✅ Save bandwidth: Chỉ upload khi user confirm
- ✅ Cancel option: User có thể cancel trước khi upload

**Implementation:**
- `selectedImagePath`: Lưu path để reference
- `_previewImageBytes`: Lưu bytes để hiển thị preview
- Upload chỉ xảy ra khi `UpdateUserSettings` event có `avatarImageFile`

### 3. 🔄 State Synchronization

**Profile ↔ Settings sync:**
```
Settings screen: Update profile
  → UpdateUserSettingsUseCase
    → AuthRepository.updateUser()
      → Firestore: update user profile
        → AuthBloc.authStateChanges stream
          → Auto emit AuthStateChanged
            → Profile screen auto update (BlocBuilder)
```

**Đặc biệt:**
- ✅ Real-time sync giữa Profile và Settings
- ✅ No manual refresh needed
- ✅ Consistent data across screens

### 4. 🔒 Password Change Security

**Requirements:**
- ✅ Re-authentication với password cũ (bắt buộc)
- ✅ Validation: New password ≠ current password
- ✅ Confirm password match
- ✅ Either pattern để handle errors type-safely

**Flow:**
```
User nhập passwords
  → Validation (không rỗng, khớp)
    → ChangePasswordUseCase
      → AuthRepository.changePassword()
        → FirebaseAuthDatasource.changePassword()
          → Re-authenticate với currentPassword
            → Update password
              → Success/Error
```

### 5. 🎨 Image Preview Pattern

**Implementation:**
```dart
// 1. Chọn ảnh
final imageBytes = await image.readAsBytes();
setState(() => _previewImageBytes = imageBytes);

// 2. Preview trong UI
Image.memory(_previewImageBytes!)

// 3. Upload khi save
if (selectedImage != null) {
  uploadAvatarImageUseCase(selectedImage);
}
```

**Lợi ích:**
- ✅ Instant feedback
- ✅ No network request until save
- ✅ Better UX

### 6. 🔄 Auto Load on Init

**SettingsBloc constructor:**
```dart
SettingsBloc({...}) : super(SettingsInitial()) {
  // Register handlers
  // ...
  
  // Auto load
  add(LoadSettings());
}
```

**Lợi ích:**
- ✅ No manual load needed từ UI
- ✅ Always fresh data when screen opens

**Lưu ý:**
- ⚠️ Có thể trigger multiple loads nếu bloc được recreate nhiều lần
- ⚠️ Cần đảm bảo bloc lifecycle được quản lý đúng

### 7. 📝 Form Validation

**Display Name:**
- ✅ Optional (có thể để trống)
- ✅ Trim whitespace

**Password:**
- ✅ Required fields
- ✅ New password ≠ current password (có thể check)
- ✅ Confirm password match
- ✅ Minimum length (Firebase: ≥ 6 chars)

### 8. 🎯 Error Handling

**Strategy:**
- ✅ Try-catch trong bloc handlers
- ✅ Either pattern cho password change
- ✅ Rollback state nếu upload fail
- ✅ User-friendly error messages (tiếng Việt)

**Error recovery:**
```dart
// Nếu upload fail, rollback về user data cũ
catch (e) {
  emit(SettingsError('Lỗi khi upload avatar: $e'));
  final user = await getCurrentUser();
  if (user != null) {
    emit(SettingsLoaded(user));  // Restore previous state
  }
  return;
}
```

---

## 💡 ĐIỂM HAY CỦA KIẾN TRÚC

### 1. 🏗️ Separation of Concerns

**Profile:**
- ✅ Chỉ để display, không có business logic
- ✅ Đọc từ AuthBloc (shared state)

**Settings:**
- ✅ Domain layer riêng (use cases)
- ✅ Business logic tách biệt khỏi UI
- ✅ Testable

### 2. 🔄 Reactive Updates

**Real-time sync:**
- ✅ Settings update → AuthBloc stream → Profile auto update
- ✅ No manual refresh needed
- ✅ Consistent data

### 3. 📸 Smart Image Handling

**Preview pattern:**
- ✅ Local preview trước khi upload
- ✅ Better UX
- ✅ Save bandwidth

### 4. 🎯 BLoC Pattern

**State management:**
- ✅ Predictable state transitions
- ✅ Easy to test
- ✅ Clear separation

### 5. ♻️ Reuse Auth Repository

**DRY principle:**
- ✅ Không duplicate code
- ✅ Single source of truth
- ✅ Consistent updates

---

## 🚀 CÁC ĐIỂM CÓ THỂ CẢI THIỆN

### 1. 📱 Profile Feature Enhancement

**Hiện tại:**
- Chỉ hiển thị basic info

**Có thể thêm:**
- Edit profile từ Profile screen
- Orders count
- Total spent
- Join date display
- Address management

### 2. ⚙️ Settings Feature Enhancement

**Hiện tại:**
- Basic profile update
- Password change

**Có thể thêm:**
- Email verification
- Phone number verification
- Notification settings
- Privacy settings
- Language selection
- Theme settings (dark mode)

### 3. 🔄 State Management

**Hiện tại:**
- SettingsBloc auto-load trong constructor

**Có thể cải thiện:**
- Loading state riêng cho từng operation
- Optimistic updates
- Retry mechanism

### 4. 📸 Image Handling

**Hiện tại:**
- Basic preview và upload

**Có thể cải thiện:**
- Image cropping
- Image compression before upload
- Multiple image sizes (thumbnail, full)
- Image caching

### 5. 🔒 Security

**Có thể thêm:**
- Password strength indicator
- 2FA setup
- Active sessions management
- Login history

### 6. 📊 Analytics

**Có thể thêm:**
- Track profile updates
- Track password changes
- User engagement metrics

---

## 📊 TÓM TẮT LUỒNG HOẠT ĐỘNG

### **Profile Screen:**
```
1. App navigate to ProfileScreen
2. BlocBuilder<AuthBloc, AuthState>
3. Check AuthState:
   → AuthAuthenticated: 
     → Display user info (avatar, name, email)
     → Navigation tiles
   → Khác: Show loading
4. User tap navigation:
   → Orders: Navigate to orders
   → Settings: Navigate to settings
   → Logout: AuthBloc.add(AuthLogoutRequested())
```

### **Settings Screen - Load:**
```
1. App navigate to SettingsScreen
2. BlocProvider create SettingsBloc
3. SettingsBloc constructor:
   → add(LoadSettings())
4. LoadSettings handler:
   → GetCurrentUserUseCase()
     → IAuthRepository.getCurrentUser()
       → Return AppUser
5. emit(SettingsLoaded(user))
6. UI populate form fields
```

### **Settings Screen - Update Profile:**
```
1. User edit display name
2. User select new avatar
   → _pickImage()
     → ImagePicker
       → Read bytes → _previewImageBytes
         → setState() → Preview in UI
           → SettingsBloc.add(ImageSelected())
3. User click "Lưu thay đổi"
   → SettingsBloc.add(UpdateUserSettings(...))
4. UpdateUserSettings handler:
   → If avatarImageFile != null:
     → UploadAvatarImageUseCase()
       → Upload to Cloudinary
         → Get avatarUrl
   → UpdateUserSettingsUseCase()
     → Update Firestore
       → Return updated AppUser
5. emit(SettingsUpdated()) → emit(SettingsLoaded(updated))
6. AuthBloc stream auto-update
7. Profile screen auto-update
```

### **Settings Screen - Change Password:**
```
1. User enter passwords
2. Validation (not empty, match)
3. User click "Đổi mật khẩu"
   → SettingsBloc.add(ChangePasswordRequested(...))
4. ChangePasswordRequested handler:
   → ChangePasswordUseCase()
     → IAuthRepository.changePassword()
       → FirebaseAuthDatasource.changePassword()
         → Re-authenticate
           → Update password
5. Either<Failure, void>:
   → Left: emit(SettingsError)
   → Right: emit(SettingsUpdated)
```

---

## ✅ CHECKLIST ĐỂ VẬN HÀNH TỐT

- [ ] AuthBloc được provide ở root level
- [ ] SettingsBloc được create mới mỗi lần mở screen (factory)
- [ ] Avatar upload path đúng (Cloudinary config)
- [ ] Form validation hoạt động đúng
- [ ] Password change validation đúng
- [ ] Error messages user-friendly
- [ ] Preview image hoạt động đúng
- [ ] State sync giữa Profile và Settings
- [ ] Default avatar fallback hoạt động
- [ ] Loading states hiển thị đúng

---

## 🎓 KẾT LUẬN

Profile và Settings features được thiết kế tốt với:
- ✅ Clear separation: Profile chỉ display, Settings có logic riêng
- ✅ Reuse Auth repository: DRY principle
- ✅ Real-time sync: Auto-update giữa screens
- ✅ BLoC pattern: Predictable state management
- ✅ Smart image handling: Preview pattern

**Điểm mạnh:**
- Kiến trúc sạch, dễ maintain
- Reuse code hiệu quả
- Real-time synchronization
- Good UX với preview pattern

**Có thể cải thiện:**
- More settings options
- Better image handling (cropping, compression)
- Enhanced validation
- Analytics tracking

---

**Tác giả:** AI Assistant  
**Ngày:** 2024

