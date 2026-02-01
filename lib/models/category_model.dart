class Category {
  final int id;
  final String name;
  final String image;
  final String creationAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.creationAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      creationAt: json['creationAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'creationAt': creationAt,
      'updatedAt': updatedAt,
    };
  }
}
