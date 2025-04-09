import 'package:flutter/material.dart';
import 'dart:math';
import '../models/book.dart';
import '../services/library_database_helper.dart';

class LazyLoadingDemoScreen extends StatefulWidget {
  const LazyLoadingDemoScreen({super.key});

  @override
  State<LazyLoadingDemoScreen> createState() => _LazyLoadingDemoScreenState();
}

class _LazyLoadingDemoScreenState extends State<LazyLoadingDemoScreen> {
  final List<Book> _books = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  final int _pageSize = 20;
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  // Để demo caching hiệu quả
  final Map<int, List<Book>> _cachedPages = {};
  bool _useCache = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMore();
  }

  // Scroll listener để load thêm dữ liệu khi cuộn đến cuối
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreData) {
      _loadMore();
    }
  }

  // Load thêm dữ liệu sử dụng lazy loading và caching
  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra nếu dữ liệu đã được cache và caching được bật
      if (_useCache && _cachedPages.containsKey(_currentPage)) {
        // Trì hoãn một chút để mô phỏng thời gian lấy dữ liệu từ cache
        await Future.delayed(const Duration(milliseconds: 100));

        setState(() {
          _books.addAll(_cachedPages[_currentPage]!);
          _currentPage++;
          _isLoading = false;
        });

        print('Lấy dữ liệu từ cache cho trang $_currentPage');
        return;
      }

      // Không có trong cache, query từ database
      final List<Book> newBooks = await _fetchBooksFromDatabase(
        _currentPage * _pageSize,
        _pageSize,
      );

      // Cache lại dữ liệu cho lần sau
      if (_useCache && newBooks.isNotEmpty) {
        _cachedPages[_currentPage] = newBooks;
      }

      setState(() {
        _books.addAll(newBooks);
        _currentPage++;
        _isLoading = false;
        _hasMoreData = newBooks.length == _pageSize;
      });

      print('Lấy dữ liệu từ database cho trang $_currentPage');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Lỗi khi load thêm sách: $e');
    }
  }

  // Truy vấn dữ liệu từ database với phân trang
  Future<List<Book>> _fetchBooksFromDatabase(int offset, int limit) async {
    final db = await LibraryDatabaseHelper.instance.database;

    // Giả lập thời gian truy vấn từ database
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'books',
        limit: limit,
        offset: offset,
        orderBy: 'id ASC',
      );

      // Nếu không có dữ liệu thật, tạo dữ liệu mẫu
      if (maps.isEmpty) {
        final random = Random();
        return List.generate(
          limit > 20 ? 20 : limit, // Giới hạn để mô phỏng hết dữ liệu
          (index) => _generateRandomBook(random, offset + index),
        );
      }

      return List.generate(maps.length, (i) {
        return Book.fromMap(maps[i]);
      });
    } catch (e) {
      print('Lỗi khi truy vấn database: $e');
      return [];
    }
  }

  // Tạo sách ngẫu nhiên
  Book _generateRandomBook(Random random, int index) {
    final titlePrefixes = [
      'Cuốn sách',
      'Kỹ thuật',
      'Nghệ thuật',
      'Khoa học',
      'Lịch sử',
    ];
    final titleSuffixes = ['SQLite', 'Flutter', 'Mobile', 'Database', 'Cache'];

    final title =
        '${titlePrefixes[random.nextInt(titlePrefixes.length)]} ${titleSuffixes[random.nextInt(titleSuffixes.length)]} #${index + 1}';
    final isbn = 'BOOK-${random.nextInt(10000)}-${random.nextInt(10000)}';
    final authorId = random.nextInt(10) + 1;
    final categoryId = random.nextInt(10) + 1;
    final publishYear = 2010 + random.nextInt(14);
    final price = 100000.0 + random.nextInt(400) * 1000;
    final stockQuantity = random.nextInt(50) + 1;

    return Book(
      id: index + 1,
      title: title,
      isbn: isbn,
      authorId: authorId,
      categoryId: categoryId,
      publishYear: publishYear,
      price: price,
      stockQuantity: stockQuantity,
    );
  }

  // Tạo dữ liệu mẫu để demo
  Future<void> _generateSampleData(int count) async {
    setState(() {
      _isLoading = true;
    });

    final db = await LibraryDatabaseHelper.instance.database;
    final random = Random();

    try {
      // Sử dụng batch để thêm nhanh
      final batch = db.batch();
      for (int i = 0; i < count; i++) {
        final book = _generateRandomBook(random, i);
        batch.insert('books', book.toMap());
      }
      await batch.commit(noResult: true);

      // Reset state để load lại
      setState(() {
        _books.clear();
        _cachedPages.clear();
        _currentPage = 0;
        _hasMoreData = true;
        _isLoading = false;
      });

      // Load lại dữ liệu
      _loadMore();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã tạo $count sách mẫu')));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Lỗi khi tạo dữ liệu mẫu: $e');
    }
  }

  // Xóa cache để làm mới dữ liệu
  void _clearCache() {
    setState(() {
      _cachedPages.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa cache')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lazy Loading & Caching'),
        actions: [
          // Toggle caching
          IconButton(
            icon: Icon(_useCache ? Icons.cached : Icons.disabled_by_default),
            tooltip: _useCache ? 'Caching đang bật' : 'Caching đang tắt',
            onPressed: () {
              setState(() {
                _useCache = !_useCache;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _useCache ? 'Đã bật caching' : 'Đã tắt caching',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          // Clear cache
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Xóa cache',
            onPressed: _clearCache,
          ),
          // Generate sample data
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tạo dữ liệu mẫu',
            onPressed: () => _generateSampleData(100),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thông tin giải thích
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demo Lazy Loading & Caching',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _useCache ? Icons.check_circle : Icons.cancel,
                        color: _useCache ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Caching: ${_useCache ? 'BẬT' : 'TẮT'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _useCache ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.storage, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đã nạp: ${_books.length} sách (${_cachedPages.length} trang đã cache)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cuộn xuống để nạp thêm dữ liệu (mỗi lần 20 sách)',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          // Danh sách sách
          Expanded(
            child:
                _books.isEmpty && _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _books.isEmpty
                    ? const Center(
                      child: Text('Không có sách nào. Tạo dữ liệu mẫu?'),
                    )
                    : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _books.clear();
                          _currentPage = 0;
                          _hasMoreData = true;
                        });
                        await _loadMore();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _books.length + (_hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _books.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final book = _books[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${book.id}')),
                              title: Text(
                                book.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ISBN: ${book.isbn}'),
                                  Text(
                                    'Năm XB: ${book.publishYear} | Giá: ${book.price.toStringAsFixed(0)} đ',
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                // Show thông tin chi tiết sách
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã chọn sách: ${book.title}',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
