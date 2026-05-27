import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:com_mock/mock_utils.dart' as mock;

class Product {
  final String id;
  final String title;
  final String imageUrl;

  Product({required this.id, required this.title, required this.imageUrl});
}

abstract class HomeService {
  Future<List<Product>> fetchProducts();
  Future<List<String>> fetchSliderImages();

  /// For tests: build products from user list or other mocked sources.
  void seedFromUsers(List<dynamic> users) {}
}

class MockHomeService implements HomeService {
  MockHomeService._();
  static final MockHomeService instance = MockHomeService._();

  late final List<Product> _products = _buildProducts();

  List<Product> _buildProducts() {
    if (kReleaseMode) {
      return List.generate(
        12,
        (i) => Product(
          id: 'p\$i',
          title: 'Sản phẩm \\\$i',
          imageUrl: 'https://picsum.photos/seed/product_\\$i/400/400',
        ),
      );
    }

    return List.generate(
      12,
      (i) => Product(
        id: 'p\$i',
        title: mock.randomName(),
        imageUrl: mock.randomImage(w: 400, h: 400),
      ),
    );
  }

  late final List<String> _slider = _buildSlider();

  List<String> _buildSlider() {
    if (kReleaseMode) {
      return List.generate(
        5,
        (i) => 'https://picsum.photos/seed/slide_\$i/800/400',
      );
    }

    return List.generate(5, (i) => mock.randomImage(w: 800, h: 400));
  }

  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List<Product>.from(_products);
  }

  @override
  Future<List<String>> fetchSliderImages() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List<String>.from(_slider);
  }

  @override
  void seedFromUsers(List<dynamic> users) {
    // If users were passed (e.g., from MockAuthService.listUsers), use their names/images
    if (users.isEmpty) return;
    final ints = users.cast();
    // map first few users to products for demo
    for (var i = 0; i < ints.length && i < _products.length; i++) {
      final u = ints[i];
      _products[i] = Product(
        id: _products[i].id,
        title: u.name ?? _products[i].title,
        imageUrl: u.avatarUrl ?? _products[i].imageUrl,
      );
    }
  }
}
