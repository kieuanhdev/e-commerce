import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service để upload ảnh lên Cloudinary và lấy URL
class CloudinaryService {
  // Lấy credentials từ .env file
  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  /// Upload avatar image lên Cloudinary
  /// Trả về URL của ảnh đã upload
  /// 
  /// Lưu ý: Cần setup Upload Preset trong Cloudinary Dashboard để sử dụng unsigned upload
  /// Hoặc cung cấp upload_preset trong .env
  Future<String> uploadAvatarImage(XFile imageFile) async {
    try {
      // Validate cloud_name (chỉ cần cloud_name cho unsigned upload)
      if (_cloudName.isEmpty) {
        throw Exception(
          'CLOUDINARY_CLOUD_NAME chưa được cấu hình trong file .env'
        );
      }

      // Upload preset (nên tạo trong Cloudinary Dashboard)
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'ml_default';
      
      print('[Cloudinary] Bắt đầu upload avatar...');
      print('[Cloudinary] Cloud name: $_cloudName');
      print('[Cloudinary] Upload preset: $uploadPreset');
      
      // Đọc bytes từ file
      final Uint8List imageBytes = await imageFile.readAsBytes();
      print('[Cloudinary] File size: ${imageBytes.length} bytes');

      // Cloudinary upload endpoint (unsigned upload)
      final uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

      // Tạo multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Thêm các parameters cho unsigned upload
      // Lưu ý: Với unsigned upload, chỉ được phép dùng một số tham số nhất định
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'avatars'; // Lưu vào folder avatars
      request.fields['public_id'] = 'avatar_${DateTime.now().millisecondsSinceEpoch}'; // Tên file unique
      // Không dùng 'transformation' và 'format' trong unsigned upload
      // Transformations phải được cấu hình trong Upload Preset trên Cloudinary Dashboard

      // Thêm file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'avatar.jpg',
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
}

