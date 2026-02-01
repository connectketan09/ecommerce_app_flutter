import 'package:new_project/models/product_model.dart';

class Order {
  final int id;
  final String creationAt;
  final List<Product> products;

  Order({
    required this.id,
    required this.creationAt,
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<Product> parsedProducts = [];
    if (json['products'] != null) {
      if (json['products'] is List) {
        parsedProducts = (json['products'] as List).map((i) => Product.fromJson(i)).toList();
      }
    }
    
    return Order(
      id: json['id'],
      creationAt: json['creationAt'],
      products: parsedProducts,
    );
  }
}
