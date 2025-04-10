import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/library_database_helper.dart';

class QueryOptimizationsScreen extends StatefulWidget {
  const QueryOptimizationsScreen({super.key});

  @override
  State<QueryOptimizationsScreen> createState() =>
      _QueryOptimizationsScreenState();
}

class _QueryOptimizationsScreenState extends State<QueryOptimizationsScreen> {
  final List<QueryExample> _queryExamples = [
    QueryExample(
      title: 'Tối ưu tìm kiếm với LIKE',
      badQuery: """
        SELECT id, title, publish_year, price 
        FROM books 
        WHERE title LIKE '%Adventure%'  -- Không thể sử dụng index với wildcard ở đầu
        ORDER BY publish_year DESC
      """,
      goodQuery: """
        SELECT id, title, publish_year, price 
        FROM books 
        WHERE title LIKE 'Adventure%'   -- Có thể sử dụng index với prefix search
        ORDER BY publish_year DESC
      """,
      explanation:
          'Cùng tìm các sách có từ "Adventure", nhưng prefix search cho phép sử dụng index nên nhanh hơn',
    ),
    QueryExample(
      title: 'Tối ưu JOIN và điều kiện lọc',
      badQuery: """
        SELECT b.*, a.name as author_name, c.name as category_name
        FROM books b 
        JOIN authors a ON b.author_id = a.id 
        JOIN categories c ON b.category_id = c.id
        WHERE b.price > 20
      """,
      goodQuery: """
        SELECT b.*, a.name as author_name, c.name as category_name
        FROM books b 
        JOIN authors a ON b.author_id = a.id 
        JOIN categories c ON b.category_id = c.id
        WHERE b.category_id = 1 AND b.price > 20  -- Thêm điều kiện có index
      """,
      explanation:
          'Cùng tìm sách và thông tin liên quan, nhưng thêm điều kiện có index để tối ưu tốc độ',
    ),
    QueryExample(
      title: 'Tối ưu điều kiện phạm vi',
      badQuery: """
        SELECT id, title, price, publish_year
        FROM books
        WHERE price >= 10 AND price <= 50 
        AND publish_year >= 2020
      """,
      goodQuery: """
        SELECT id, title, price, publish_year
        FROM books
        WHERE price BETWEEN 10 AND 50
        AND publish_year >= 2020
        AND category_id = 1  -- Thêm điều kiện có index
      """,
      explanation:
          'Cùng tìm sách trong khoảng giá và năm, nhưng sử dụng BETWEEN và thêm điều kiện index để tối ưu',
    ),
    QueryExample(
      title: 'Tối ưu sắp xếp',
      badQuery: """
        SELECT id, title, publish_year, price
        FROM books
        WHERE publish_year > 2020
        ORDER BY publish_year DESC, price DESC
      """,
      goodQuery: """
        SELECT id, title, publish_year, price
        FROM books
        WHERE category_id = 1 AND publish_year > 2020  -- Dùng compound index
        ORDER BY publish_year DESC, price DESC
      """,
      explanation:
          'Cùng tìm và sắp xếp sách theo năm và giá, nhưng tận dụng compound index để tối ưu',
    ),
    QueryExample(
      title: 'Tối ưu thống kê nhóm',
      badQuery: """
        SELECT category_id, COUNT(*) as book_count, AVG(price) as avg_price
        FROM books
        GROUP BY category_id
        HAVING COUNT(*) > 0
      """,
      goodQuery: """
        SELECT c.id, c.name, COUNT(b.id) as book_count, AVG(b.price) as avg_price
        FROM categories c
        LEFT JOIN books b ON c.id = b.category_id
        GROUP BY c.id, c.name
        HAVING COUNT(b.id) > 0
      """,
      explanation:
          'Cùng thống kê số lượng và giá trung bình theo danh mục, nhưng JOIN để có thêm thông tin và tối ưu group',
    ),
    QueryExample(
      title: 'Tối ưu JOIN với Index',
      badQuery: """
        SELECT b.title, b.publish_year, a.name as author_name
        FROM books b
        JOIN authors a ON b.author_id = a.id
        WHERE b.publish_year > 2020
        ORDER BY b.publish_year DESC
        -- Query plan sẽ hiện SCAN TABLE books và SCAN TABLE authors
      """,
      goodQuery: """
        SELECT b.title, b.publish_year, a.name as author_name
        FROM books b
        JOIN authors a ON b.author_id = a.id
        WHERE b.category_id = 1 
        AND b.publish_year > 2020
        ORDER BY b.publish_year DESC
        -- Query plan sẽ hiện:
        -- SEARCH TABLE books USING INDEX idx_books_category_year
        -- SEARCH TABLE authors USING INTEGER PRIMARY KEY
      """,
      explanation:
          'So sánh hiệu suất khi JOIN: Truy vấn đầu phải quét toàn bộ bảng books và authors (SCAN TABLE). '
          'Truy vấn thứ hai tận dụng được index trên category_id và publish_year (SEARCH USING INDEX), '
          'cũng như primary key của bảng authors.',
    ),
    QueryExample(
      title: 'Tối ưu với Covering Index và Subquery',
      badQuery: """
        SELECT b.title, b.price
        FROM books b
        WHERE b.category_id IN (
          SELECT id FROM categories 
          WHERE name LIKE '%Fiction%'
        )
        -- Query plan sẽ hiện:
        -- SCAN TABLE categories
        -- SCAN TABLE books
        -- Subquery phải chạy cho mỗi dòng trong bảng books
      """,
      goodQuery: """
        -- Đã tạo covering index:
        -- CREATE INDEX idx_books_cat_price ON books(category_id, title, price)
        SELECT b.title, b.price
        FROM books b
        JOIN categories c ON b.category_id = c.id
        WHERE c.name LIKE 'Fiction%'
        -- Query plan sẽ hiện:
        -- SEARCH TABLE categories USING INDEX idx_categories_name
        -- SEARCH TABLE books USING COVERING INDEX idx_books_cat_price
      """,
      explanation:
          'Ví dụ về covering index và tránh subquery: '
          'Truy vấn đầu sử dụng subquery không hiệu quả, phải quét nhiều lần. '
          'Truy vấn thứ hai tận dụng covering index (bao gồm cả category_id, title và price) '
          'và JOIN trực tiếp thay vì dùng subquery.',
    ),
  ];

  String _selectedQuery = '';
  String _queryPlan = '';
  List<Book> _resultBooks = [];
  bool _isExecuting = false;
  int _executionTime = 0;

  Future<void> _executeQuery(String query) async {
    setState(() {
      _isExecuting = true;
      _selectedQuery = query;
      _resultBooks = [];
      _queryPlan = '';
      _executionTime = 0;
    });

    try {
      final stopwatch = Stopwatch()..start();
      final results = await LibraryDatabaseHelper.instance.executeRawQuery(
        query,
      );
      stopwatch.stop();

      final queryPlan = await LibraryDatabaseHelper.instance.explainQueryPlan(
        query,
      );

      setState(() {
        if (query.toLowerCase().contains('from books')) {
          _resultBooks = results.map((row) => Book.fromMap(row)).toList();
        }
        _queryPlan = queryPlan;
        _executionTime = stopwatch.elapsedMilliseconds;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi thực thi truy vấn: $e')));
    } finally {
      setState(() {
        _isExecuting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Query Optimization Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Các kỹ thuật tối ưu truy vấn SQLite',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Dưới đây là các ví dụ về truy vấn chưa tối ưu và cách cải thiện chúng. Nhấp vào từng ví dụ để xem kế hoạch truy vấn và kết quả.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danh sách các ví dụ truy vấn
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: ListView.separated(
                        itemCount: _queryExamples.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final example = _queryExamples[index];
                          return ListTile(
                            title: Text(example.title),
                            subtitle: Text('Nhấp để xem chi tiết'),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text(example.title),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Truy vấn chưa tối ưu:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                example.badQuery,
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              'Truy vấn đã tối ưu:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                example.goodQuery,
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Giải thích:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(example.explanation),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _executeQuery(example.badQuery);
                                          },
                                          child: const Text(
                                            'Chạy truy vấn chưa tối ưu',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _executeQuery(example.goodQuery);
                                          },
                                          child: const Text(
                                            'Chạy truy vấn đã tối ưu',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: const Text('Đóng'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Kết quả truy vấn
                  Expanded(
                    flex: 3,
                    child:
                        _selectedQuery.isEmpty
                            ? const Center(
                              child: Text(
                                'Chọn một ví dụ truy vấn để xem kết quả',
                              ),
                            )
                            : Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Kết quả truy vấn',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _selectedQuery,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Thời gian thực thi: $_executionTime ms',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Query Plan:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _queryPlan,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Số kết quả: ${_resultBooks.length}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child:
                                          _isExecuting
                                              ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                              : ListView.builder(
                                                itemCount:
                                                    _resultBooks.length > 10
                                                        ? 10
                                                        : _resultBooks.length,
                                                itemBuilder: (context, index) {
                                                  final book =
                                                      _resultBooks[index];
                                                  return ListTile(
                                                    title: Text(book.title),
                                                    subtitle: Text(
                                                      'Category: ${book.categoryId}, Year: ${book.publishYear}',
                                                    ),
                                                  );
                                                },
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QueryExample {
  final String title;
  final String badQuery;
  final String goodQuery;
  final String explanation;

  QueryExample({
    required this.title,
    required this.badQuery,
    required this.goodQuery,
    required this.explanation,
  });
}
