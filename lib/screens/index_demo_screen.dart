import 'package:flutter/material.dart';
import 'dart:math';
import '../models/book.dart';
import '../services/library_database_helper.dart';

class IndexDemoScreen extends StatefulWidget {
  const IndexDemoScreen({super.key});

  @override
  State<IndexDemoScreen> createState() => _IndexDemoScreenState();
}

class _IndexDemoScreenState extends State<IndexDemoScreen> {
  final _searchController = TextEditingController();

  List<Book> _books = [];
  List<Map<String, dynamic>> _indexes = [];
  String _queryPlan = '';
  bool _isSearching = false;
  bool _hasIndexes = true;
  String _currentQuery = '';
  int _lastExecutionTime = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkIndexStatus();
  }

  Future<void> _loadData() async {
    final books = await LibraryDatabaseHelper.instance.getAllBooks();
    final indexes = await LibraryDatabaseHelper.instance.getAllIndexes();

    setState(() {
      _books = books;
      _indexes = indexes;
    });
  }

  Future<void> _checkIndexStatus() async {
    final hasIndexes = await LibraryDatabaseHelper.instance.areIndexesEnabled();
    setState(() {
      _hasIndexes = hasIndexes;
    });
  }

  Future<void> _toggleIndexes() async {
    if (_hasIndexes) {
      await LibraryDatabaseHelper.instance.dropAllIndexes();
    } else {
      await LibraryDatabaseHelper.instance.recreateIndexes();
    }
    await _checkIndexStatus();
    await _loadData();

    // Re-run the last search to compare performance
    if (_currentQuery.isNotEmpty) {
      _searchBooksByTitle();
    }
  }

  Future<void> _searchBooksByTitle() async {
    if (_searchController.text.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery =
          "SELECT * FROM books WHERE title LIKE '%${_searchController.text}%'";
    });

    final stopwatch = Stopwatch()..start();
    final books = await LibraryDatabaseHelper.instance.searchBooksByTitle(
      _searchController.text,
    );
    stopwatch.stop();

    final queryPlan = await LibraryDatabaseHelper.instance.explainQueryPlan(
      _currentQuery,
    );

    setState(() {
      _books = books;
      _queryPlan = queryPlan;
      _lastExecutionTime = stopwatch.elapsedMilliseconds;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indexing Demo'),
        actions: [
          IconButton(
            icon: Icon(_hasIndexes ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleIndexes,
            tooltip: _hasIndexes ? 'Disable Indexes' : 'Enable Indexes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasIndexes ? Icons.check_circle : Icons.cancel,
                          color: _hasIndexes ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Indexes: ${_hasIndexes ? "Đang bật" : "Đang tắt"}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Indexes giúp tăng tốc độ tìm kiếm dữ liệu, tương tự như mục lục của sách.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: Icon(
                        _hasIndexes ? Icons.flash_off : Icons.flash_on,
                      ),
                      label: Text(_hasIndexes ? 'Tắt Indexes' : 'Bật Indexes'),
                      onPressed: _toggleIndexes,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Các loại Indexes trong SQLite',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. Single-column Index: Tạo chỉ mục trên một cột',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Composite Index: Tạo chỉ mục trên nhiều cột',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. Unique Index: Đảm bảo giá trị trong cột không trùng lặp',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Các Indexes trong ứng dụng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Danh sách các indexes đang có:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_indexes.isEmpty)
                      const Text('Không có indexes nào được tạo')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _indexes.length,
                        itemBuilder: (context, index) {
                          final indexInfo = _indexes[index];
                          return ListTile(
                            leading: const Icon(Icons.list_alt),
                            title: Text(indexInfo['name'].toString()),
                            subtitle: Text(
                              'Table: ${indexInfo['tbl_name']}, Columns: ${indexInfo['columns'] ?? 'N/A'}',
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Demo tìm kiếm với và không có Index',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Nhập từ khóa tìm kiếm',
                              border: OutlineInputBorder(),
                              hintText: 'Nhập từ khóa để tìm sách',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSearching ? null : _searchBooksByTitle,
                          child:
                              _isSearching
                                  ? const CircularProgressIndicator()
                                  : const Text('Tìm kiếm'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_currentQuery.isNotEmpty && _lastExecutionTime > 0) ...[
                      Text(
                        'Thời gian thực thi: $_lastExecutionTime ms',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Trạng thái Index: '),
                          Text(
                            _hasIndexes ? 'Đang bật ✓' : 'Đang tắt ✗',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _hasIndexes ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Query Plan:',
                        style: TextStyle(
                          fontSize: 16,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SQL: $_currentQuery',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            const Divider(),
                            Text(
                              _queryPlan,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Kết quả tìm thấy: ${_books.length} sách',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _books.length > 5 ? 5 : _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return ListTile(
                            title: Text(book.title),
                            subtitle: Text('ISBN: ${book.isbn}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khi nào nên dùng Indexes?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. Các cột thường xuyên được sử dụng trong mệnh đề WHERE',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Các cột thường xuyên được sử dụng trong mệnh đề JOIN',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. Các cột thường xuyên được sử dụng trong mệnh đề ORDER BY',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Lưu ý: Indexing cũng có nhược điểm!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Tốn không gian lưu trữ',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Làm chậm các thao tác insert, update, delete',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. Không hiệu quả với các bảng có ít dữ liệu',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
