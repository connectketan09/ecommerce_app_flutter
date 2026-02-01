import 'package:flutter/foundation.dart';
import 'package:new_project/models/product_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<Product> _items = [];

  List<Product> get items => _items;

  double get total => _items.fold(0, (sum, item) => sum + item.price);

  void add(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
