# Cách xem ảnh đã upload lên Cloudinary

## 1. Xem trong Cloudinary Dashboard

### Cách 1: Xem Media Library
1. Đăng nhập vào [Cloudinary Dashboard](https://console.cloudinary.com)
2. Click vào **Media Library** ở menu bên trái
3. Tất cả ảnh đã upload sẽ hiển thị ở đây
4. Nếu bạn đã cấu hình `folder: 'avatars'`, ảnh sẽ nằm trong folder `avatars`

### Cách 2: Tìm theo tên file
- Ảnh được upload với `public_id` là `avatar_{timestamp}`
- Ví dụ: `avatar_1234567890`
- Bạn có thể search trong Media Library bằng tên này

## 2. Xem URL trực tiếp

Sau khi upload thành công, code sẽ log URL trong console:
```
[Cloudinary] Upload thành công! URL: https://res.cloudinary.com/your_cloud_name/image/upload/v1/avatars/avatar_xxx.jpg
```

Bạn có thể:
- Copy URL này và paste vào browser để xem
- URL sẽ có dạng: `https://res.cloudinary.com/{cloud_name}/image/upload/...`

## 3. Kiểm tra trong code (Debug)

Thêm log để xem URL trong console:
- URL đã được log tự động trong `CloudinaryService`
- Xem console của Flutter để thấy URL sau khi upload thành công

## 4. Xem trong Firebase Firestore

Vì URL được lưu vào Firebase:
1. Vào Firebase Console
2. Firestore Database
3. Collection `users`
4. Document của user
5. Field `avatarUrl` sẽ chứa URL từ Cloudinary

## 5. Test nhanh trong app

Sau khi upload:
- Avatar trong Settings screen sẽ hiển thị ảnh mới
- Avatar trong Profile screen cũng sẽ hiển thị ảnh mới
- Nếu không thấy, có thể do cache - thử reload app

## Lưu ý:

- URL từ Cloudinary là public URL, ai cũng có thể truy cập nếu biết URL
- Để bảo mật hơn, có thể cấu hình **Access Control** trong Cloudinary Dashboard
- Ảnh được lưu trong folder `avatars` nếu bạn đã cấu hình trong code

