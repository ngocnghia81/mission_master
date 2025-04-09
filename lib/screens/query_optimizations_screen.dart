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
      title: 'Tìm kiếm chính xác',
      badQuery: "SELECT * FROM books WHERE title LIKE '%Adventure%'",
      goodQuery: "SELECT * FROM books WHERE title = 'Adventure'",
      explanation:
          'Sử dụng so sánh chính xác (=) thay vì LIKE với wildcard ở cả hai đầu khi cần tìm chính xác',
    ),
    QueryExample(
      title: 'Tìm kiếm tiền tố',
      badQuery: "SELECT * FROM books WHERE title LIKE '%Adventure'",
      goodQuery: "SELECT * FROM books WHERE title LIKE 'Adventure%'",
      explanation:
          'LIKE với wildcard ở đầu không thể tận dụng index, trong khi wildcard ở cuối thì có thể',
    ),
    QueryExample(
      title: 'Sử dụng IN thay vì OR',
      badQuery:
          "SELECT * FROM books WHERE category_id = 1 OR category_id = 2 OR category_id = 3",
      goodQuery: "SELECT * FROM books WHERE category_id IN (1, 2, 3)",
      explanation:
          'Sử dụng IN thay vì nhiều điều kiện OR giúp tối ưu hiệu suất truy vấn',
    ),
    QueryExample(
      title: 'Giới hạn kết quả trả về',
      badQuery: "SELECT * FROM books",
      goodQuery: "SELECT * FROM books LIMIT 100",
      explanation:
          'Thêm LIMIT để giới hạn số lượng kết quả trả về, tránh tải dữ liệu không cần thiết',
    ),
    QueryExample(
      title: 'Chỉ lấy các cột cần thiết',
      badQuery:
          "SELECT * FROM books JOIN authors ON books.author_id = authors.id",
      goodQuery:
          "SELECT books.title, authors.name FROM books JOIN authors ON books.author_id = authors.id",
      explanation:
          'Chỉ chọn các cột cần thiết thay vì lấy tất cả (*) giúp giảm lượng dữ liệu truyền tải',
    ),
    QueryExample(
      title: 'Sử dụng điều kiện trên cột có index',
      badQuery: "SELECT * FROM books WHERE price > 20.0",
      goodQuery: "SELECT * FROM books WHERE category_id = 1 AND price > 20.0",
      explanation:
          'Kết hợp điều kiện trên cột có index (category_id) với điều kiện khác để tối ưu truy vấn',
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
    });

    final stopwatch = Stopwatch()..start();
    final results = await LibraryDatabaseHelper.instance.executeRawQuery(query);
    stopwatch.stop();

    final queryPlan = await LibraryDatabaseHelper.instance.explainQueryPlan(
      query,
    );

    final books = results.map((row) => Book.fromMap(row)).toList();

    setState(() {
      _resultBooks = books;
      _queryPlan = queryPlan;
      _executionTime = stopwatch.elapsedMilliseconds;
      _isExecuting = false;
    });
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
