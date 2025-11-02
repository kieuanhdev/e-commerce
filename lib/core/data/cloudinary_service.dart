import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Generic service để upload ảnh lên Cloudinary và lấy URL
/// Sử dụng Signed Upload với API Key và API Secret
/// Có thể dùng cho avatar, product images, reviews, etc.
class CloudinaryService {
  // Lấy credentials từ .env file
  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get _apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String get _apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  /// Upload image lên Cloudinary sử dụng Signed Upload
  ///
  /// [imageFile]: File ảnh cần upload
  /// [folder]: Folder để lưu ảnh (ví dụ: 'avatars', 'products', 'reviews')
  /// [publicIdPrefix]: Prefix cho public_id (ví dụ: 'avatar', 'product')
  ///
  /// Trả về secure URL của ảnh đã upload
  Future<String> uploadImage({
    required XFile imageFile,
    required String folder,
    String? publicIdPrefix,
  }) async {
    try {
      // Validate credentials
      if (_cloudName.isEmpty) {
        throw Exception(
          'CLOUDINARY_CLOUD_NAME chưa được cấu hình trong file .env.\n'
          'Vui lòng thêm: CLOUDINARY_CLOUD_NAME=your_cloud_name',
        );
      }

      if (_apiKey.isEmpty) {
        throw Exception(
          'CLOUDINARY_API_KEY chưa được cấu hình trong file .env.\n'
          'Vui lòng thêm: CLOUDINARY_API_KEY=your_api_key',
        );
      }

      if (_apiSecret.isEmpty) {
        throw Exception(
          'CLOUDINARY_API_SECRET chưa được cấu hình trong file .env.\n'
          'Vui lòng thêm: CLOUDINARY_API_SECRET=your_api_secret',
        );
      }

      final prefix = publicIdPrefix ?? folder;

      print('[Cloudinary] Bắt đầu upload image (Signed Upload)...');
      print('[Cloudinary] Cloud name: $_cloudName');
      print('[Cloudinary] Folder: $folder');

      // Đọc bytes từ file
      final Uint8List imageBytes = await imageFile.readAsBytes();
      print('[Cloudinary] File size: ${imageBytes.length} bytes');

      // Cloudinary upload endpoint
      final uploadUrl =
          'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

      // Tạo multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      final publicId = '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000)
          .round()
          .toString();

      // Signed Upload: Sử dụng API key và secret
      request.fields['folder'] = folder;
      request.fields['public_id'] = publicId;
      request.fields['timestamp'] = timestamp;

      // Tạo signature cho signed upload
      final signature = _generateSignature({
        'folder': folder,
        'public_id': publicId,
        'timestamp': timestamp,
      });
      request.fields['signature'] = signature;
      request.fields['api_key'] = _apiKey;

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
          throw Exception(
            'Cloudinary không trả về URL. Response: ${response.body}',
          );
        }

        print('[Cloudinary] Upload thành công! URL: $secureUrl');
        return secureUrl;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? response.body;
        print(
          '[Cloudinary] Upload thất bại: ${response.statusCode} - $errorMessage',
        );
        throw Exception(
          'Lỗi khi upload lên Cloudinary (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e, stackTrace) {
      print('[Cloudinary] Lỗi: $e');
      print('[Cloudinary] Stack trace: $stackTrace');

      if (e.toString().contains('timeout')) {
        throw Exception(
          'Upload quá lâu. Vui lòng kiểm tra kết nối mạng và thử lại.',
        );
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

  /// Upload product image (convenience method)
  Future<String> uploadProductImage(XFile imageFile) {
    return uploadImage(
      imageFile: imageFile,
      folder: 'products',
      publicIdPrefix: 'product',
    );
  }

  /// Tạo signature cho signed upload
  /// Cloudinary yêu cầu signature được tạo từ các parameters đã sắp xếp theo thứ tự alphabet
  String _generateSignature(Map<String, String> params) {
    // Sắp xếp parameters theo thứ tự alphabet
    final sortedKeys = params.keys.toList()..sort();

    // Tạo string để sign: key1=value1&key2=value2&...
    final stringToSign = sortedKeys
        .map((key) => '$key=${params[key]}')
        .join('&');

    // Thêm API secret vào cuối
    final fullString = '$stringToSign$_apiSecret';

    // Tạo SHA-1 hash
    final bytes = utf8.encode(fullString);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}
