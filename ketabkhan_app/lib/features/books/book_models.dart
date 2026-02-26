class BookSummary {
  final int id;
  final String title;
  final String publisher;
  final int price;
  final String? coverUrl;
  final bool purchased;

  BookSummary({
    required this.id,
    required this.title,
    required this.publisher,
    required this.price,
    required this.coverUrl,
    required this.purchased,
  });

  factory BookSummary.fromJson(Map<String, dynamic> json) {
    return BookSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      publisher: json['publisher'] as String,
      price: json['price'] as int,
      coverUrl: json['cover_url'] as String?,
      purchased: (json['purchased'] as bool?) ?? false,
    );
  }
}

class BookDetail extends BookSummary {
  final String? description;

  BookDetail({
    required super.id,
    required super.title,
    required super.publisher,
    required super.price,
    required super.coverUrl,
    required super.purchased,
    required this.description,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    return BookDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      publisher: json['publisher'] as String,
      price: json['price'] as int,
      coverUrl: json['cover_url'] as String?,
      purchased: (json['purchased'] as bool?) ?? false,
      description: json['description'] as String?,
    );
  }
}
