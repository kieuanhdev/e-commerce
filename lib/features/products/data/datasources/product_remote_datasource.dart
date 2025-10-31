
import 'package:e_commerce/core/data/firebase_remote_data_source.dart';
import 'package:e_commerce/features/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAll();
  Future<ProductModel?> getProduct(String id);
  Future<void> add(ProductModel product);
  Future<void> update(ProductModel product);
  Future<void> delete(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseRemoteDS<ProductModel> _remoteSource;

  ProductRemoteDataSourceImpl()
    : _remoteSource = FirebaseRemoteDS<ProductModel>(
        collectionName: 'products',
        fromFirestore: (doc) => ProductModel.fromFirestore(doc),
        toFirestore: (model) => model.toJson(),
      );

  @override
  Future<List<ProductModel>> getAll() async {
    List<ProductModel> products = [];
    products = await _remoteSource.getAll();
    return products;
  }

  @override
  Future<ProductModel?> getProduct(String id) async {
    ProductModel? product = await _remoteSource.getById(id);
    return product;
  }

  @override
  Future<void> add(ProductModel product) async {
    await _remoteSource.add(product);
  }

  @override
  Future<void> update(ProductModel product) async {
    await _remoteSource.update(product.id.toString(), product);
  }

  @override
  Future<void> delete(String id) async {
    await _remoteSource.delete(id);
  }
}
