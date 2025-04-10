import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/category.dart';
import 'dart:async';

class LibraryDatabaseHelper {
  static const _databaseName = "library.db";
  static const _databaseVersion = 1;

  // Singleton instance
  static LibraryDatabaseHelper? _instance;

  // Private constructor
  LibraryDatabaseHelper._privateConstructor();

  // Factory constructor to return the singleton instance
  factory LibraryDatabaseHelper() {
    return instance;
  }

  // Get singleton instance
  static LibraryDatabaseHelper get instance {
    _instance ??= LibraryDatabaseHelper._privateConstructor();
    return _instance!;
  }

  // Create an instance with a specific database path (for isolates)
  static Future<LibraryDatabaseHelper> getInstance(String dbPath) async {
    final helper = LibraryDatabaseHelper._privateConstructor();
    await helper._initDatabaseWithPath(dbPath);
    return helper;
  }

  // Database reference
  Database? _database;

  // Get database if exists, or initialize if not
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Get the database path
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  // Initialize database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'library.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        // Kiểm tra và tạo index nếu chưa tồn tại
        await _ensureIndexesExist(db);
      },
    );
  }

  // Initialize database with a specific path
  Future<Database> _initDatabaseWithPath(String path) async {
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
    );
  }

  // Delete benchmark books (for isolate testing)
  Future<void> deleteBenchmarkBooks() async {
    final db = await database;
    await db.delete('books', where: "isbn LIKE ?", whereArgs: ['BATCH-%']);
  }

  Future<void> _createDB(Database db, int version) async {
    // Create authors table
    await db.execute('''
    CREATE TABLE authors(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT,
      country TEXT
    )
    ''');

    // Create categories table
    await db.execute('''
    CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT
    )
    ''');

    // Create books table with foreign keys
    await db.execute('''
    CREATE TABLE books(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      isbn TEXT UNIQUE,
      author_id INTEGER,
      category_id INTEGER,
      publish_year INTEGER,
      price REAL,
      stock_quantity INTEGER,
      FOREIGN KEY (author_id) REFERENCES authors (id),
      FOREIGN KEY (category_id) REFERENCES categories (id)
    )
    ''');

    // Create indexes for optimized queries
    await db.execute('CREATE INDEX idx_books_title ON books(title)');
    await db.execute('CREATE INDEX idx_books_author_id ON books(author_id)');
    await db.execute(
      'CREATE INDEX idx_books_category_id ON books(category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_books_category_year ON books(category_id, publish_year)',
    );
  }

  // CRUD operations for Book
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert(
      'books',
      book.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Handle unique constraint conflicts
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<Book?> getBook(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Book>> searchBooksByTitle(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<List<Book>> searchBooksByCategoryAndYear(
    int categoryId,
    int year,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'category_id = ? AND publish_year = ?',
      whereArgs: [categoryId, year],
    );

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<List<Book>> getBooksPaginated({
    required int offset,
    required int limit,
  }) async {
    final db = await database;
    final results = await db.query(
      'books',
      limit: limit,
      offset: offset,
      orderBy: 'id DESC',
    );

    return results.map((row) => Book.fromMap(row)).toList();
  }

  Future<List<Book>> searchBooksByTitleOptimized(
    String keyword, {
    required int limit,
    int offset = 0,
  }) async {
    final db = await database;

    // Sử dụng JOIN để lấy thông tin đầy đủ
    final results = await db.rawQuery(
      '''
      SELECT b.*, a.name as author_name, c.name as category_name
      FROM books b
      LEFT JOIN authors a ON b.author_id = a.id
      LEFT JOIN categories c ON b.category_id = c.id
      WHERE b.title LIKE ?
      ORDER BY b.title
      LIMIT ? OFFSET ?
    ''',
      ['%$keyword%', limit, offset],
    );

    return results.map((row) => Book.fromMap(row)).toList();
  }

  // CRUD operations for Author
  Future<int> insertAuthor(Author author) async {
    final db = await database;
    return await db.insert('authors', author.toMap());
  }

  Future<List<Author>> getAllAuthors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('authors');

    return List.generate(maps.length, (i) {
      return Author.fromMap(maps[i]);
    });
  }

  // CRUD operations for Category
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  // Index management
  Future<bool> areIndexesEnabled() async {
    try {
      final db = await database;
      final indexResult = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_books_title'",
      );
      return indexResult.isNotEmpty;
    } catch (e) {
      print('Error checking index status: $e');
      return false;
    }
  }

  Future<void> dropAllIndexes() async {
    final db = await database;
    try {
      // Lấy tất cả index hiện có của books
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='books' AND name NOT LIKE 'sqlite_%'",
      );

      // Drop từng index
      for (final indexMap in indexes) {
        final indexName = indexMap['name'] as String;
        await db.execute('DROP INDEX IF EXISTS $indexName');
      }

      print('Đã xóa tất cả index');
    } catch (e) {
      print('Lỗi khi xóa index: $e');
    }
  }

  Future<void> recreateIndexes() async {
    final db = await database;
    try {
      // Xóa hết index cũ
      await dropAllIndexes();

      // Tạo lại index mới
      await _createIndexes(db);

      print('Đã tạo lại tất cả index');
    } catch (e) {
      print('Lỗi khi tạo lại index: $e');
    }
  }

  // Thêm phương thức để đo hiệu suất với và không có index
  Future<Map<String, int>> benchmarkQueryWithAndWithoutIndexes(
    String query,
    List<dynamic> args,
  ) async {
    final results = <String, int>{};

    // Xóa index
    await dropAllIndexes();

    // Đo hiệu suất không có index
    final stopwatch1 = Stopwatch()..start();
    await executeRawQuery(query, args);
    stopwatch1.stop();
    results['without_index'] = stopwatch1.elapsedMilliseconds;

    // Tạo lại index
    await recreateIndexes();

    // Đo hiệu suất có index
    final stopwatch2 = Stopwatch()..start();
    await executeRawQuery(query, args);
    stopwatch2.stop();
    results['with_index'] = stopwatch2.elapsedMilliseconds;

    return results;
  }

  Future<List<Map<String, dynamic>>> executeRawQuery(
    String query, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return await db.rawQuery(query, args);
  }

  // Query analysis
  Future<String> explainQueryPlan(String query, [List<Object?>? args]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'EXPLAIN QUERY PLAN $query',
      args,
    );

    String plan = '';
    for (var row in maps) {
      plan += '${row['detail']}\n';
    }

    return plan;
  }

  // Get table schema
  Future<String> getTableSchema(String tableName) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='$tableName'",
      );

      if (maps.isNotEmpty) {
        return maps.first['sql'] as String;
      }
      return '';
    } catch (e) {
      print('Error getting table schema: $e');
      return 'Error: $e';
    }
  }

  // Get all indexes
  Future<List<Map<String, dynamic>>> getAllIndexes() async {
    try {
      final db = await database;
      return await db.rawQuery(
        "SELECT name, tbl_name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
      );
    } catch (e) {
      print('Error getting indexes: $e');
      return [];
    }
  }

  // Delete all books
  Future<void> deleteAllBooks() async {
    final db = await database;
    await db.delete('books');
  }

  // Search books by year
  Future<List<Book>> searchBooksByYear(int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'publish_year = ?',
      whereArgs: [year],
    );
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  // Search books by price range
  Future<List<Book>> searchBooksByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'price BETWEEN ? AND ?',
      whereArgs: [minPrice, maxPrice],
    );
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  // Complex search query
  Future<List<Book>> searchBooksComplex(
    int year,
    double minPrice,
    double maxPrice,
    int categoryId,
  ) async {
    final db = await database;

    // Tận dụng compound index (category_id, publish_year)
    final results = await db.query(
      'books',
      where: 'category_id = ? AND publish_year = ? AND price BETWEEN ? AND ?',
      whereArgs: [categoryId, year, minPrice, maxPrice],
      orderBy: 'publish_year DESC, price DESC',
    );

    return results.map((row) => Book.fromMap(row)).toList();
  }

  Future<String> analyzeQueryPlan(String query, List<Object?> args) async {
    final db = await database;
    final results = await db.rawQuery('EXPLAIN QUERY PLAN $query', args);

    return results
        .map((row) => 'detail: ${row['detail']}, order: ${row['order']}')
        .join('\n');
  }

  // Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> _ensureIndexesExist(Database db) async {
    // Kiểm tra xem index đã tồn tại chưa
    final indexResult = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_books_title'",
    );

    if (indexResult.isEmpty) {
      // Tạo lại các index nếu chưa tồn tại
      await _createIndexes(db);
    }
  }

  Future<void> _createIndexes(Database db) async {
    // Chỉ tạo index cho các cột thường được dùng để tìm kiếm
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_title ON books(title)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_publish_year ON books(publish_year)',
    );

    // Đánh index trên cột price vì chúng ta có truy vấn theo khoảng giá
    // Thường các cột số được dùng trong BETWEEN hoặc so sánh phạm vi nên được đánh index
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_price ON books(price)',
    );

    // Đánh index trên khóa ngoại vì chúng được dùng trong JOIN
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_category_id ON books(category_id)',
    );

    // Tạo composite index cho các truy vấn phức hợp thường xuyên sử dụng
    // Thứ tự cột trong composite index rất quan trọng:
    // - Cột có tính chọn lọc cao hơn (nhiều giá trị khác nhau) nên đặt đầu tiên
    // - Cột thường xuyên được dùng trong WHERE nên đặt ở đầu
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_category_year ON books(category_id, publish_year)',
    );
  }
}
