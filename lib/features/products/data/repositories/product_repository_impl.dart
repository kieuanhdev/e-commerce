import 'package:e_commerce/core/data/cloudinary_service.dart';
import 'package:e_commerce/features/products/data/datasources/product_remote_datasource.dart';
import 'package:e_commerce/features/products/data/models/product_model.dart';
import 'package:e_commerce/features/products/domain/entities/product.dart';
import 'package:e_commerce/features/products/domain/repositories/product_repository.dart';
import 'package:image_picker/image_picker.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final CloudinaryService cloudinaryService;

  ProductRepositoryImpl(this.remoteDataSource, this.cloudinaryService);

  @override
  Future<void> createProduct(Product product) async {
    ProductModel productModel = ProductModel.fromEntity(product);
    await remoteDataSource.add(productModel);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await remoteDataSource.delete(id);
  }

  @override
  Future<Product> getProduct(String id) async {
    ProductModel? productModel = await remoteDataSource.getProduct(id);
    if (productModel == null) {
      throw Exception('Product not found');
    }
    return productModel.toEntity();
  }

  @override
  Future<List<Product>> getProducts() async {
    List<ProductModel> productModels = await remoteDataSource.getAll();
    return productModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateProduct(Product product) async {
    await remoteDataSource.update(ProductModel.fromEntity(product));
  }

  @override
  Future<String> uploadProductImage(XFile imageFile) async {
    try {
      return await cloudinaryService.uploadProductImage(imageFile);
    } catch (e) {
      throw Exception('Lỗi khi upload ảnh sản phẩm: ${e.toString()}');
    }
  }
}
