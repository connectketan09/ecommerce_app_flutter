import 'package:new_project/models/category_model.dart';

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;
  final String creationAt;
  final String updatedAt;
  final Category category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    required this.creationAt,
    required this.updatedAt,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle implementation where images might be strings inside stringified list or dirty data
    // The API sometimes returns "[\"url\"]" instead of ["url"]
    List<String> parsedImages = [];
    if (json['images'] != null) {
      var imagesList = json['images'];
      if (imagesList is List) {
        parsedImages = imagesList.map((e) {
          // Clean up stringified image URLs if necessary
          String urls = e.toString();
          if (urls.startsWith('["') && urls.endsWith('"]')) {
             urls = urls.replaceAll('["', '').replaceAll('"]', '').replaceAll('"', '');
          }
           if (urls.startsWith('[') && urls.endsWith(']')) {
             urls = urls.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
          }
          return urls;
        }).toList();
      }
    }

    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      images: parsedImages,
      creationAt: json['creationAt'],
      updatedAt: json['updatedAt'],
      category: Category.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'images': images,
      'creationAt': creationAt,
      'updatedAt': updatedAt,
      'category': category.toJson(),
    };
  }
}
