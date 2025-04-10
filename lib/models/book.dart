class Book {
  final int? id;
  final String title;
  final String isbn;
  final int authorId;
  final int categoryId;
  final int publishYear;
  final double price;
  final int stockQuantity;

  Book({
    this.id,
    required this.title,
    required this.isbn,
    required this.authorId,
    required this.categoryId,
    required this.publishYear,
    required this.price,
    required this.stockQuantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isbn': isbn,
      'author_id': authorId,
      'category_id': categoryId,
      'publish_year': publishYear,
      'price': price,
      'stock_quantity': stockQuantity,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String? ?? 'Unknown',
      isbn: map['isbn'] as String? ?? '',
      authorId: map['author_id'] as int? ?? 0,
      categoryId: map['category_id'] as int? ?? 0,
      publishYear: map['publish_year'] as int? ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: map['stock_quantity'] as int? ?? 0,
    );
  }
}
