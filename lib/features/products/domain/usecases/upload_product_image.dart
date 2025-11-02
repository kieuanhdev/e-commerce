import 'package:e_commerce/features/products/domain/repositories/product_repository.dart';
import 'package:image_picker/image_picker.dart';

class UploadProductImage {
  final ProductRepository repository;

  UploadProductImage(this.repository);

  Future<String> call(XFile imageFile) {
    return repository.uploadProductImage(imageFile);
  }
}
