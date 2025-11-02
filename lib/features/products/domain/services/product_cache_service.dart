import '../entities/product.dart';
import '../usecases/get_products.dart';

/// Service để cache products và tránh load lại nhiều lần
class ProductCacheService {
  static ProductCacheService? _instance;
  static ProductCacheService get instance {
    _instance ??= ProductCacheService._();
    return _instance!;
  }

  ProductCacheService._();

  List<Product>? _cachedProducts;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  bool _isLoading = false;

  /// Get products - trả về cache nếu còn valid, nếu không thì load lại
  Future<List<Product>> getProducts(GetProducts getProductsUseCase, {bool forceRefresh = false}) async {
    // Nếu đang loading, đợi load xong
    while (_isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final now = DateTime.now();
    
    // Kiểm tra cache còn valid không
    if (!forceRefresh && 
        _cachedProducts != null && 
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < _cacheValidDuration) {
      return _cachedProducts!;
    }

    // Load từ server
    _isLoading = true;
    try {
      final products = await getProductsUseCase();
      _cachedProducts = products;
      _lastFetchTime = now;
      return products;
    } finally {
      _isLoading = false;
    }
  }

  /// Clear cache - để force refresh lần sau
  void clearCache() {
    _cachedProducts = null;
    _lastFetchTime = null;
  }

  /// Get cached products nếu có (không load từ server)
  List<Product>? getCachedProducts() => _cachedProducts;

  /// Kiểm tra cache còn valid không
  bool isCacheValid() {
    if (_cachedProducts == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  /// Lấy thời gian cache được tạo (để check tuổi cache)
  DateTime? get lastFetchTime => _lastFetchTime;
}

