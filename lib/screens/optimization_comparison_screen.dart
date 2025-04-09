import 'package:flutter/material.dart';
import '../services/library_database_helper.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/category.dart';
import 'dart:math';

class OptimizationComparisonScreen extends StatefulWidget {
  const OptimizationComparisonScreen({Key? key}) : super(key: key);

  @override
  _OptimizationComparisonScreenState createState() =>
      _OptimizationComparisonScreenState();
}

class _OptimizationComparisonScreenState
    extends State<OptimizationComparisonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recordCountController = TextEditingController(text: '1000');
  final List<String> _logMessages = [];
  bool _isLoading = false;
  bool _hasIndexes = true;

  @override
  void initState() {
    super.initState();
    _checkIndexStatus();
  }

  Future<void> _checkIndexStatus() async {
    _hasIndexes = await LibraryDatabaseHelper.instance.areIndexesEnabled();
    setState(() {});
  }

  void _addLogMessage(String message) {
    setState(() {
      _logMessages.insert(0, message);
    });
  }

  Future<void> _runComparison() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _logMessages.clear();
    });

    try {
      final recordCount = int.parse(_recordCountController.text);

      // Xóa dữ liệu cũ
      await LibraryDatabaseHelper.instance.deleteAllBooks();
      _addLogMessage('Đã xóa dữ liệu cũ');

      // Tạo dữ liệu mẫu
      await _generateSampleData(recordCount);
      _addLogMessage('Đã tạo $recordCount bản ghi mẫu');

      // Chạy các bài test hiệu suất
      await _runPerformanceTests(recordCount);
    } catch (e) {
      _addLogMessage('Lỗi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSampleData(int count) async {
    final random = Random();

    // Tạo dữ liệu mẫu cho authors và categories
    final authorId = await LibraryDatabaseHelper.instance.insertAuthor(
      Author(
        name: 'Test Author',
        email: 'test@example.com',
        country: 'Test Country',
      ),
    );

    final categoryId = await LibraryDatabaseHelper.instance.insertCategory(
      Category(name: 'Test Category', description: 'Test Description'),
    );

    // Tạo dữ liệu mẫu cho books
    for (var i = 0; i < count; i++) {
      await LibraryDatabaseHelper.instance.insertBook(
        Book(
          title: 'Test Book $i',
          isbn: 'ISBN$i',
          authorId: authorId,
          categoryId: categoryId,
          publishYear: 2000 + random.nextInt(24),
          price: 10.0 + random.nextDouble() * 90,
          stockQuantity: random.nextInt(100),
        ),
      );
    }
  }

  Future<void> _runPerformanceTests(int recordCount) async {
    // Test 1: Tìm kiếm theo tiêu đề
    _addLogMessage('\n=== Test 1: Tìm kiếm theo tiêu đề ===');
    await _testQueryPerformance(
      'Tìm kiếm theo tiêu đề (có index)',
      () => LibraryDatabaseHelper.instance.searchBooksByTitle('Test Book'),
    );

    // Test 2: Tìm kiếm theo năm xuất bản
    _addLogMessage('\n=== Test 2: Tìm kiếm theo năm xuất bản ===');
    await _testQueryPerformance(
      'Tìm kiếm theo năm xuất bản (có index)',
      () => LibraryDatabaseHelper.instance.searchBooksByYear(2020),
    );

    // Test 3: Tìm kiếm theo khoảng giá
    _addLogMessage('\n=== Test 3: Tìm kiếm theo khoảng giá ===');
    await _testQueryPerformance(
      'Tìm kiếm theo khoảng giá (có index)',
      () => LibraryDatabaseHelper.instance.searchBooksByPriceRange(20.0, 50.0),
    );

    // Test 4: Tìm kiếm phức hợp
    _addLogMessage('\n=== Test 4: Tìm kiếm phức hợp ===');
    await _testQueryPerformance(
      'Tìm kiếm phức hợp (có index)',
      () => LibraryDatabaseHelper.instance.searchBooksComplex(
        2020,
        20.0,
        50.0,
        1,
      ),
    );

    // Tắt index và chạy lại các test
    _addLogMessage('\n=== Tắt index và chạy lại các test ===');
    await LibraryDatabaseHelper.instance.dropAllIndexes();
    await _checkIndexStatus();

    // Test 1: Tìm kiếm theo tiêu đề (không có index)
    _addLogMessage('\n=== Test 1: Tìm kiếm theo tiêu đề (không có index) ===');
    await _testQueryPerformance(
      'Tìm kiếm theo tiêu đề (không có index)',
      () => LibraryDatabaseHelper.instance.searchBooksByTitle('Test Book'),
    );

    // Test 2: Tìm kiếm theo năm xuất bản (không có index)
    _addLogMessage(
      '\n=== Test 2: Tìm kiếm theo năm xuất bản (không có index) ===',
    );
    await _testQueryPerformance(
      'Tìm kiếm theo năm xuất bản (không có index)',
      () => LibraryDatabaseHelper.instance.searchBooksByYear(2020),
    );

    // Test 3: Tìm kiếm theo khoảng giá (không có index)
    _addLogMessage(
      '\n=== Test 3: Tìm kiếm theo khoảng giá (không có index) ===',
    );
    await _testQueryPerformance(
      'Tìm kiếm theo khoảng giá (không có index)',
      () => LibraryDatabaseHelper.instance.searchBooksByPriceRange(20.0, 50.0),
    );

    // Test 4: Tìm kiếm phức hợp (không có index)
    _addLogMessage('\n=== Test 4: Tìm kiếm phức hợp (không có index) ===');
    await _testQueryPerformance(
      'Tìm kiếm phức hợp (không có index)',
      () => LibraryDatabaseHelper.instance.searchBooksComplex(
        2020,
        20.0,
        50.0,
        1,
      ),
    );

    // Khôi phục index
    await LibraryDatabaseHelper.instance.recreateIndexes();
    await _checkIndexStatus();
  }

  Future<void> _testQueryPerformance(
    String operationName,
    Future<List<Book>> Function() queryFunction,
  ) async {
    final stopwatch = Stopwatch()..start();
    final results = await queryFunction();
    stopwatch.stop();

    _addLogMessage('$operationName:');
    _addLogMessage('- Thời gian thực hiện: ${stopwatch.elapsedMilliseconds}ms');
    _addLogMessage('- Số kết quả: ${results.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh hiệu suất SQLite'),
        actions: [
          IconButton(
            icon: Icon(_hasIndexes ? Icons.speed : Icons.speed_outlined),
            tooltip: _hasIndexes ? 'Index đang bật' : 'Index đang tắt',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _hasIndexes ? 'Index đang bật' : 'Index đang tắt',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _recordCountController,
                decoration: const InputDecoration(
                  labelText: 'Số lượng bản ghi',
                  hintText: 'Nhập số lượng bản ghi cần tạo',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng bản ghi';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Vui lòng nhập số nguyên dương';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _runComparison,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Chạy so sánh hiệu suất'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListView.builder(
                  itemCount: _logMessages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        _logMessages[index],
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    );
                  },
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
    _recordCountController.dispose();
    super.dispose();
  }
}
