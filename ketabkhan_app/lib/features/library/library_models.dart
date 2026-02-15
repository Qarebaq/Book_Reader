class Book {
  final int id;
  final String title;
  final String publisher;
  final String? coverUrl;

  Book({required this.id, required this.title, required this.publisher, this.coverUrl});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      publisher: json['publisher'] as String,
      coverUrl: json['cover_url'] as String?,
    );
  }
}
