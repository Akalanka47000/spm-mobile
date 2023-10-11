import 'package:enhanced_http/enhanced_http.dart';

class ProductService {
  static final EnhancedHttp _http = EnhancedHttp(baseURL: "https://ca01-2402-d000-8114-3a2a-c53-8763-8549-6631.ngrok-free.app");

  static Future<dynamic> getProduct(String id) async {
    dynamic product = await _http.get("/api/v1/products/$id");
    return product;
  }
}
