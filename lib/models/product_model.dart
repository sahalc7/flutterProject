class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.rating,
    this.category = '',
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
  final double rating;
  final String category;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    final thumbnail = json['thumbnail'];
    final imageUrl = thumbnail is String && thumbnail.isNotEmpty
        ? thumbnail
        : images is List && images.isNotEmpty && images.first is String
        ? images.first as String
        : '';

    return ProductModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      imageUrl: imageUrl,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? '',
    );
  }
}
