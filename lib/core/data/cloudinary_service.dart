import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Generic service để upload ảnh lên Cloudinary và lấy URL
/// Có thể dùng cho avatar, product images, reviews, etc.
class CloudinaryService {
  // Lấy credentials từ .env file
  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  /// Upload image lên Cloudinary
  /// 
  /// [imageFile]: File ảnh cần upload
  /// [folder]: Folder để lưu ảnh (ví dụ: 'avatars', 'products', 'reviews')
  /// [uploadPreset]: Upload preset name (mặc định lấy từ .env hoặc 'ml_default')
  /// [publicIdPrefix]: Prefix cho public_id (ví dụ: 'avatar', 'product')
  /// 
  /// Trả về secure URL của ảnh đã upload
  Future<String> uploadImage({
    required XFile imageFile,
    required String folder,
    String? uploadPreset,
    String? publicIdPrefix,
  }) async {
    try {
      // Validate cloud_name
      if (_cloudName.isEmpty) {
        throw Exception(
          'CLOUDINARY_CLOUD_NAME chưa được cấu hình trong file .env'
        );
      }

      // Upload preset (mặc định từ .env hoặc 'ml_default')
      final preset = uploadPreset ?? dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'ml_default';
      final prefix = publicIdPrefix ?? folder;
      
      print('[Cloudinary] Bắt đầu upload image...');
      print('[Cloudinary] Cloud name: $_cloudName');
      print('[Cloudinary] Upload preset: $preset');
      print('[Cloudinary] Folder: $folder');
      
      // Đọc bytes từ file
      final Uint8List imageBytes = await imageFile.readAsBytes();
      print('[Cloudinary] File size: ${imageBytes.length} bytes');

      // Cloudinary upload endpoint (unsigned upload)
      final uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

      // Tạo multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Thêm các parameters cho unsigned upload
      // Lưu ý: Với unsigned upload, chỉ được phép dùng một số tham số nhất định
      request.fields['upload_preset'] = preset;
      request.fields['folder'] = folder;
      request.fields['public_id'] = '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
      // Không dùng 'transformation' và 'format' trong unsigned upload
      // Transformations phải được cấu hình trong Upload Preset trên Cloudinary Dashboard

      // Thêm file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'image.jpg',
        ),
      );

      print('[Cloudinary] Đang upload lên Cloudinary...');
      
      // Gửi request với timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout sau 60 giây');
        },
      );

      // Đọc response
      final response = await http.Response.fromStream(streamedResponse);
      
      print('[Cloudinary] Response status: ${response.statusCode}');
      print('[Cloudinary] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final secureUrl = responseData['secure_url'] as String?;
        
        if (secureUrl == null) {
          throw Exception('Cloudinary không trả về URL. Response: ${response.body}');
        }
        
        print('[Cloudinary] Upload thành công! URL: $secureUrl');
        return secureUrl;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? response.body;
        print('[Cloudinary] Upload thất bại: ${response.statusCode} - $errorMessage');
        throw Exception('Lỗi khi upload lên Cloudinary (${response.statusCode}): $errorMessage');
      }
    } catch (e, stackTrace) {
      print('[Cloudinary] Lỗi: $e');
      print('[Cloudinary] Stack trace: $stackTrace');
      
      if (e.toString().contains('timeout')) {
        throw Exception('Upload quá lâu. Vui lòng kiểm tra kết nối mạng và thử lại.');
      } else if (e.toString().contains('CLOUDINARY')) {
        rethrow;
      } else {
        throw Exception('Lỗi khi upload ảnh lên Cloudinary: ${e.toString()}');
      }
    }
  }

  /// Upload avatar image (convenience method)
  Future<String> uploadAvatarImage(XFile imageFile) {
    return uploadImage(
      imageFile: imageFile,
      folder: 'avatars',
      publicIdPrefix: 'avatar',
    );
  }
}

