import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:new_project/models/product_model.dart';
import 'package:new_project/models/category_model.dart';
import 'package:new_project/models/user_model.dart';
import 'package:new_project/models/order_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  static void _log(String message) {
    if (kDebugMode) {
      print('[API] $message');
    }
  }

  // Products
  static Future<List<Product>> getProducts() async {
    final url = Uri.parse('$baseUrl/products');
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> searchProducts(String title) async {
    final url = Uri.parse('$baseUrl/products/?title=$title');
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
       _log('Error: ${response.body}');
      throw Exception('Failed to search products');
    }
  }
  
  static Future<List<Product>> filterByPrice(double price) async {
    final url = Uri.parse('$baseUrl/products/?price=$price');
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');

    if (response.statusCode == 200) {
       List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to filter products by price');
    }
  }

  static Future<List<Product>> filterByPriceRange(double min, double max) async {
    // Ensure we send integers as some mock APIs struggle with floats in query params
    final url = Uri.parse('$baseUrl/products/?price_min=${min.round()}&price_max=${max.round()}');
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');

    if (response.statusCode == 200) {
       List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to filter products by price range');
    }
  }

  static Future<List<Product>> getProductsByCategory(String categorySlug) async {
    final url = Uri.parse('$baseUrl/products/?categorySlug=$categorySlug');
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');

     if (response.statusCode == 200) {
       List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to load products by category');
    }
  }

  static Future<Product> getProductById(int id) async {
    final url = Uri.parse('$baseUrl/products/$id');
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to load product');
    }
  }

  // Categories
  static Future<List<Category>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Category.fromJson(item)).toList();
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to load categories');
    }
  }

  // Users
  static Future<List<User>> getUsers() async {
    final url = Uri.parse('$baseUrl/users');
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to load users');
    }
  }

  // Orders
  static Future<List<Order>> getOrdersByUser(int userId) async {
    // Platzi API likely uses /users/:id/orders or just /orders?userId=:id
    // Checking documentation style: usually /users/1/orders
    // But Escuelajs docs say: GET https://api.escuelajs.co/api/v1/orders/user/1
    // Let's try that.
    
    // Note: If that endpoint doesn't exist, we might have to just fetch all orders (GET /orders) and filter locally for this academic project, 
    // but usually specific endpoints exist.
    // Based on standard Fake Store API patterns:
    final url = Uri.parse('$baseUrl/orders/user/$userId'); // or $baseUrl/users/$userId/orders
    
    // Let's try the common one first described in similar fake apis
    // Actually, looking at previous knowledge of Platzi API: GET /orders returns all. 
    // GET /users/:id/orders is often supported.
    
    _log('GET Request: $url');
    final response = await http.get(url);
    _log('GET Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Order.fromJson(item)).toList();
    } else {
       // Fallback: try fetching all orders for now if user specific fails?
       // For now, return empty or throw log.
      _log('Error: ${response.body}');
      throw Exception('Failed to load orders');
    }
  }

  // Auth
  static Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    _log('POST Request: $url');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
     _log('POST Response: ${response.statusCode}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['access_token'];
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to login');
    }
  }

  static Future<User> getProfile(String token) async {
    final url = Uri.parse('$baseUrl/auth/profile');
    _log('GET Request: $url (with token)');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    _log('GET Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      _log('Error: ${response.body}');
      throw Exception('Failed to load profile');
    }
  }
}
