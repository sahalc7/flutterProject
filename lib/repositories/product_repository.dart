import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proudcut_listing_app/models/product_model.dart';

class ProductRepository {
  ProductRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _productsUri = Uri.parse(
    'https://dummyjson.com/products?limit=0',
  );

  Future<List<ProductModel>> fetchProducts() async {
    final response = await _client.get(_productsUri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Failed to load products');
    }

    final products = body['products'];
    if (products is! List) {
      throw Exception('Failed to load products');
    }

    return products
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }
}
