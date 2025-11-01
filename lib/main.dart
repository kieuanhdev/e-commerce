import 'package:e_commerce/di.dart';
import 'package:e_commerce/firebase_options.dart';
import 'package:e_commerce/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env file từ assets
  try {
    await dotenv.load(); // Load từ assets (đã khai báo trong pubspec.yaml)
  } catch (e) {
    print('Warning: Không tìm thấy file .env hoặc lỗi khi load: $e');
    print('Vui lòng tạo file .env ở root project và thêm vào assets trong pubspec.yaml');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initDI();
  runApp(MyApp());
}
