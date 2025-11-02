# Theme Configuration Guide

File cấu hình theme thống nhất cho ứng dụng E-Commerce.

## Cấu trúc

- **`app_colors.dart`**: Định nghĩa tất cả màu sắc
- **`app_text_styles.dart`**: Định nghĩa các kiểu chữ
- **`app_sizes.dart`**: Định nghĩa kích thước, spacing, border radius
- **`app_shadows.dart`**: Định nghĩa các kiểu đổ bóng
- **`app_theme.dart`**: Cấu hình theme chính của MaterialApp
- **`theme.dart`**: Export tất cả các file theme

## Cách sử dụng

### 1. Sử dụng màu sắc

```dart
import 'package:e_commerce/core/theme/app_colors.dart';

Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)
```

### 2. Sử dụng text styles

```dart
import 'package:e_commerce/core/theme/app_text_styles.dart';

Text(
  'Tiêu đề lớn',
  style: AppTextStyles.headlineLarge,
)

Text(
  'Nội dung',
  style: AppTextStyles.bodyMedium,
)

Text(
  'Giá: 100,000đ',
  style: AppTextStyles.price,
)
```

### 3. Sử dụng sizes và spacing

```dart
import 'package:e_commerce/core/theme/app_sizes.dart';

Container(
  padding: EdgeInsets.all(AppSizes.paddingMD),
  margin: EdgeInsets.symmetric(horizontal: AppSizes.marginLG),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
  ),
)
```

### 4. Sử dụng shadows

```dart
import 'package:e_commerce/core/theme/app_shadows.dart';

Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    boxShadow: AppShadows.card,
  ),
)
```

### 5. Sử dụng từ Theme của Material

Sau khi đã cấu hình trong `my_app.dart`, bạn có thể sử dụng theme từ context:

```dart
// Màu từ theme
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.background

// Text style từ theme
Theme.of(context).textTheme.headlineLarge
Theme.of(context).textTheme.bodyMedium

// Button style từ theme
Theme.of(context).elevatedButtonTheme
Theme.of(context).outlinedButtonTheme
```

### 6. Ví dụ Button

```dart
// ElevatedButton tự động sử dụng theme
ElevatedButton(
  onPressed: () {},
  child: Text('Nút chính'),
)

// Hoặc tùy chỉnh
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    minimumSize: Size(double.infinity, AppSizes.buttonHeightLG),
  ),
  child: Text('Nút phụ'),
)
```

### 7. Ví dụ Input Field

```dart
// TextField tự động sử dụng theme
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Nhập email của bạn',
  ),
)
```

### 8. Ví dụ Card

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(AppSizes.paddingMD),
    child: Column(
      children: [
        Text('Tiêu đề', style: AppTextStyles.titleLarge),
        SizedBox(height: AppSizes.spacingSM),
        Text('Nội dung', style: AppTextStyles.bodyMedium),
      ],
    ),
  ),
)
```

## Tùy chỉnh Theme

Nếu muốn thay đổi màu sắc hoặc style, chỉ cần chỉnh sửa các file trong thư mục `lib/core/theme/`:

- Thay đổi màu: Sửa `app_colors.dart`
- Thay đổi font chữ: Sửa `app_text_styles.dart`
- Thay đổi kích thước: Sửa `app_sizes.dart`
- Thay đổi theme tổng thể: Sửa `app_theme.dart`

## Lưu ý

- Luôn sử dụng các constant từ theme thay vì hardcode màu sắc hoặc kích thước
- Theme đã được áp dụng tự động cho Material widgets như Button, TextField, Card, etc.
- Có thể import tất cả thông qua: `import 'package:e_commerce/core/theme/theme.dart';`

