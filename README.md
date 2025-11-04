# 🛍️ e_commerce

[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-blue.svg?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange.svg?logo=firebase)](https://firebase.google.com/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%20%7C%20Web-lightgrey.svg)](#)

---

## 🧩 Giới thiệu

**e_commerce** là ứng dụng **thương mại điện tử đa nền tảng** (Android / Web)  
được xây dựng bằng **Flutter** kết hợp **Firebase** và kiến trúc **Clean Architecture**.

Ứng dụng hướng tới:
- Trải nghiệm **mượt mà, tối ưu hiệu năng**
- **Dễ mở rộng & bảo trì**
- **Tích hợp Cloudinary** để upload ảnh bảo mật & nhanh chóng

---

## 🚀 Getting Started

Hướng dẫn cài đặt và chạy dự án trên máy cục bộ.

### 1️⃣ Điều kiện tiên quyết

Trước khi bắt đầu, hãy đảm bảo bạn đã cài đặt:

- ✅ [Flutter SDK](https://flutter.dev/docs/get-started/install) (**v3.19.x** trở lên)
- ✅ [Firebase CLI](https://firebase.google.com/docs/cli)
- ✅ Tài khoản [Firebase Console](https://console.firebase.google.com/)
- ✅ Tài khoản [Cloudinary](https://cloudinary.com/)

---

### 2️⃣ Cài đặt

#### 🔹 Clone dự án
```bash
git clone https://github.com/kieuanhdev/e-commerce.git
cd e_commerce
```

#### 🔹 Cài đặt dependencies
```bash
flutter pub get
```

#### 🔹 Cấu hình Firebase
1. Tạo dự án mới trong [Firebase Console](https://console.firebase.google.com/).
2. Thêm ứng dụng (Android/iOS/Web) vào dự án.
3. Bật:
   - **Firebase Auth** (Email/Password, Google)
   - **Cloud Firestore**
4. Chạy lệnh:
   ```bash
   flutterfire configure
   ```
   → Tự động tạo file `lib/firebase_options.dart`.

#### 🔹 Cấu hình biến môi trường

Tạo file `.env` ở thư mục gốc:

```ini
# Cloudinary Credentials
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

> ⚠️ Đảm bảo `.env` được thêm vào `.gitignore`.  
> Bạn có thể tạo file `.env.example` để chia sẻ cấu trúc mẫu.

---

### ▶️ 3️⃣ Chạy ứng dụng

```bash
flutter run
```

---

## 📚 Mục lục

- [Giới thiệu](#-giới-thiệu)
- [Các tính năng chính](#-các-tính-năng-chính)
- [Công nghệ & kiến trúc](#-công-nghệ--kiến-trúc)
  - [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
- [Bộ nhớ đệm (Caching)](#-bộ-nhớ-đệm-caching)
- [Lưu trữ ảnh bên thứ ba](#-lưu-trữ-ảnh-bên-thứ-ba)
- [Lưu ý cấu hình](#-lưu-ý-cấu-hình)
- [Hướng mở rộng](#-hướng-mở-rộng)
- [Giấy phép](#-giấy-phép)

---

## ✨ Các tính năng chính

| Nhóm tính năng | Mô tả |
|----------------|-------|
| 🔐 **Xác thực** | Đăng ký / Đăng nhập (Email & Google), quên mật khẩu, realtime session. |
| 🛒 **Sản phẩm** | Danh mục, xem chi tiết, tìm kiếm & lọc sản phẩm. |
| 🧺 **Giỏ hàng (Cart)** | Thêm / Xoá / Cập nhật số lượng sản phẩm; tính tổng tiền tạm tính. |
| 📦 **Đơn hàng (Orders)** | Tạo đơn hàng từ giỏ; xem lịch sử & trạng thái đơn hàng. |
| ⚙️ **Quản trị (Admin)** | Thêm / Sửa / Xoá sản phẩm; quản lý kho & thư viện ảnh. |
| 👤 **Hồ sơ cá nhân** | Cập nhật thông tin, đổi avatar, xem thông tin đơn hàng. |
| ☁️ **Quản lý ảnh** | Upload ảnh sản phẩm/avatar lên Cloudinary (Signed Upload). |

---

## 🧠 Công nghệ & Kiến trúc

### 🔧 Stack chính

- **Flutter (Dart)** – framework chính  
- **State management:** `bloc`, `flutter_bloc`  
- **Routing:** `go_router`  
- **Firebase:**  
  - `firebase_core`, `firebase_auth`, `cloud_firestore`  
- **Khác:**  
  - `get_it` (Dependency Injection)  
  - `flutter_dotenv` (biến môi trường)  
  - `google_fonts`, `lottie`, v.v.

---

### 🏗️ Kiến trúc hệ thống (High-Level)

```
lib/
├── core/                      # Tài nguyên & dịch vụ dùng chung
│   ├── data/                  # Data sources (Firestore DS, Cloudinary, ...)
│   ├── routing/               # Cấu hình go_router
│   ├── theme/                 # AppTheme, colors, typography
│   ├── utils/                 # Helpers, formatters, validators
│   └── widgets/               # Reusable UI components
├── features/
│   ├── auth/                  # Auth: login, register, Google Sign-In, forgot password
│   ├── products/              # Danh mục, danh sách, chi tiết sản phẩm
│   ├── bag/                   # Giỏ hàng / thanh toán
│   ├── orders/                # Lịch sử / chi tiết đơn hàng
│   ├── admin/                 # Trang quản trị sản phẩm/đơn hàng
│   ├── profile/               # Hồ sơ người dùng, avatar
│   ├── settings/              # Tuỳ chỉnh theme & cấu hình
│   ├── home/                  # Màn hình chính / entry
│   └── shop/                  # Khu vực cửa hàng (luồng mua sắm)
├── di.dart                    # Dependency Injection (get_it)
├── my_app.dart                # MaterialApp, theme, router
├── firebase_options.dart      # Cấu hình Firebase (tạo bởi flutterfire)
└── main.dart                  # Entry point: load .env, init Firebase & DI
```

---

## 🧠 Bộ nhớ đệm (Caching)

- **In-memory cache (ProductCacheService):**  
  Giữ danh sách sản phẩm trong bộ nhớ tối đa **5 phút** để giảm số lần gọi Firestore.  
  📄 `lib/features/products/domain/services/product_cache_service.dart`

- **Firestore cache:**  
  Ưu tiên `Source.serverAndCache`, fallback `Source.cache` khi mất mạng.  
  📄 `lib/core/data/firebase_remote_data_source.dart`

---

## ☁️ Lưu trữ ảnh bên thứ ba

- Ảnh sản phẩm/avatar được upload lên **Cloudinary** qua cơ chế **Signed Upload** để lấy `secure_url`.  
- Giúp:
  - Tối ưu băng thông & tốc độ tải.
  - Bảo mật key bằng upload server-side.

📂 `lib/core/data/cloudinary_service.dart`

🔑 Các biến môi trường:
```
CLOUDINARY_CLOUD_NAME
CLOUDINARY_API_KEY
CLOUDINARY_API_SECRET
```

---

## ⚠️ Lưu ý cấu hình

- Sử dụng `flutter_dotenv` để load biến môi trường `.env`.
- `.env` **không được commit** lên GitHub.
- Các key nhạy cảm nên lưu trong local hoặc CI/CD secrets.

---