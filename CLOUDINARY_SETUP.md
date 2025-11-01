# Hướng dẫn cấu hình Cloudinary

## 1. Đăng ký tài khoản Cloudinary

1. Truy cập: https://cloudinary.com/signup
2. Đăng ký tài khoản miễn phí
3. Sau khi đăng nhập, vào **Dashboard**

## 2. Lấy Cloud Name và tạo Upload Preset

### Lấy Cloud Name:
- Vào Dashboard, bạn sẽ thấy **Cloud name** ở phần account details
- Copy cloud name của bạn (ví dụ: `dxtj8qxyz`)

### Tạo Upload Preset (cho unsigned upload):
1. Vào **Settings** → **Upload**
2. Scroll xuống phần **Upload presets**
3. Click **Add upload preset**
4. Thiết lập:
   - **Preset name**: `ml_default` (hoặc tên khác tùy bạn) - **Quan trọng: ghi nhớ tên này!**
   - **Signing mode**: Chọn **Unsigned** (quan trọng!)
   - **Folder**: `avatars` (tùy chọn - nơi lưu file)
   - **Eager transformations** (trong phần Incoming Transformation):
     - Click **Add eager transformation**
     - Thêm: `w_800,h_800,c_fill,g_face,q_auto,f_jpg`
     - Hoặc: `w_800,h_800,c_fill,g_face,q_auto` để tự động format
   - **Format**: Có thể để auto hoặc chọn `jpg`
5. **Quan trọng**: Bật **Allow unsigned uploads** (nếu có option này)
6. Click **Save**

**Lưu ý**: Với unsigned upload, bạn KHÔNG thể gửi `transformation` parameter trong request. Phải cấu hình transformations trong Upload Preset này!

## 3. Cấu hình .env file

Tạo file `.env` ở root của project (cùng cấp với `pubspec.yaml`):

```env
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_UPLOAD_PRESET=ml_default
```

Thay `your_cloud_name_here` bằng cloud name của bạn.

## 4. Đảm bảo .env được load

Code đã được cấu hình để tự động load `.env` file trong `main.dart`. Nếu có lỗi, kiểm tra:
- File `.env` có tồn tại ở root project không
- Các biến trong `.env` có đúng format không

## 5. Test upload

Sau khi cấu hình xong:
1. Chạy `flutter pub get` để cài đặt dependencies
2. Chạy app
3. Vào Settings và thử upload avatar
4. Kiểm tra console logs để xem quá trình upload

## Lưu ý quan trọng:

- **Upload Preset phải được set là "Unsigned"** để không cần API Secret
- Nếu muốn bảo mật hơn, có thể dùng signed upload nhưng cần thêm API Key và API Secret vào `.env`
- File ảnh sẽ được tự động resize về 800x800 và optimize
- Tất cả avatar sẽ được lưu trong folder `avatars` trên Cloudinary

## Troubleshooting:

### Lỗi "CLOUDINARY_CLOUD_NAME chưa được cấu hình":
- Kiểm tra file `.env` có tồn tại không
- Kiểm tra tên biến có đúng `CLOUDINARY_CLOUD_NAME` không
- Restart app sau khi thêm/sửa `.env`

### Lỗi "Invalid upload preset":
- Kiểm tra Upload Preset đã được tạo trong Cloudinary Dashboard chưa
- Kiểm tra tên preset trong `.env` có khớp với preset name trong Dashboard không
- Đảm bảo preset được set là "Unsigned"

### Upload timeout:
- Kiểm tra kết nối mạng
- File ảnh quá lớn (> 10MB) - nên resize trước khi upload

