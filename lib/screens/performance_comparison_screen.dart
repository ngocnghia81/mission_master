import 'package:flutter/material.dart';
import '../services/library_database_helper.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/category.dart';
import 'dart:math';
import 'dart:async';

class PerformanceComparisonScreen extends StatefulWidget {
  const PerformanceComparisonScreen({super.key});

  @override
  State<PerformanceComparisonScreen> createState() =>
      _PerformanceComparisonScreenState();
}

class _PerformanceComparisonScreenState
    extends State<PerformanceComparisonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _sampleDataController = TextEditingController(text: '100');

  bool _isGeneratingData = false;
  bool _isLoading = false;
  List<Book> _searchResults = [];
  String _queryPlan = '';
  Duration _executionTime = Duration.zero;
  double _progress = 0.0;
  StreamController<double>? _progressController;

  @override
  void initState() {
    super.initState();
    _yearController.text = '2020';
    _minPriceController.text = '10.0';
    _maxPriceController.text = '50.0';
    _categoryIdController.text = '1';
  }

  @override
  void dispose() {
    _yearController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _categoryIdController.dispose();
    _sampleDataController.dispose();
    _progressController?.close();
    super.dispose();
  }

  Future<void> _generateSampleData() async {
    final count = int.tryParse(_sampleDataController.text) ?? 100;
    if (count <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số lượng phải lớn hơn 0')));
      return;
    }

    setState(() {
      _isGeneratingData = true;
      _progress = 0.0;
    });

    // Khởi tạo StreamController
    _progressController = StreamController<double>();
    _progressController!.stream.listen((progress) {
      setState(() => _progress = progress);
    });

    // Xóa dữ liệu cũ
    await LibraryDatabaseHelper.instance.deleteAllBooks();

    // Tạo categories và authors nếu chưa có
    final categories = await LibraryDatabaseHelper.instance.getAllCategories();
    if (categories.isEmpty) await _createSampleCategories();

    final authors = await LibraryDatabaseHelper.instance.getAllAuthors();
    if (authors.isEmpty) await _createSampleAuthors();

    // Lấy danh sách categories và authors
    final updatedCategories =
        await LibraryDatabaseHelper.instance.getAllCategories();
    final updatedAuthors = await LibraryDatabaseHelper.instance.getAllAuthors();

    final random = Random();
    final batchSize = 1000; // Số lượng sách xử lý mỗi batch
    final batches = (count / batchSize).ceil();

    for (var i = 0; i < batches; i++) {
      final currentBatchSize = min(batchSize, count - (i * batchSize));
      final batch = await LibraryDatabaseHelper.instance.database.then(
        (db) => db.batch(),
      );

      for (var j = 0; j < currentBatchSize; j++) {
        final bookIndex = (i * batchSize) + j;
        final book = Book(
          title: 'Book ${bookIndex + 1} - ${_getRandomTitle(random)}',
          isbn: 'ISBN-${10000 + bookIndex}',
          authorId: updatedAuthors[random.nextInt(updatedAuthors.length)].id!,
          categoryId:
              updatedCategories[random.nextInt(updatedCategories.length)].id!,
          publishYear: 2010 + random.nextInt(14),
          price: 10 + random.nextDouble() * 90,
          stockQuantity: random.nextInt(100),
        );

        batch.insert('books', book.toMap());
      }

      await batch.commit(noResult: true);

      // Cập nhật tiến trình
      final progress = min(((i + 1) * batchSize) / count, 1.0);
      _progressController?.add(progress);
    }

    _progressController?.close();
    _progressController = null;

    setState(() {
      _isGeneratingData = false;
      _progress = 1.0;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã tạo $count sách mẫu')));
  }

  Future<void> _createSampleCategories() async {
    final categories = [
      {'name': 'Fiction', 'description': 'Fictional works of literature'},
      {'name': 'Science', 'description': 'Scientific topics and research'},
      {'name': 'History', 'description': 'Historical events and figures'},
      {'name': 'Technology', 'description': 'Technology and computing'},
      {'name': 'Business', 'description': 'Business and economics'},
    ];

    for (final category in categories) {
      await LibraryDatabaseHelper.instance.insertCategory(
        Category(
          name: category['name']!,
          description: category['description']!,
        ),
      );
    }
  }

  Future<void> _createSampleAuthors() async {
    final authors = [
      {'name': 'John Smith', 'email': 'john@example.com', 'country': 'USA'},
      {
        'name': 'Maria Garcia',
        'email': 'maria@example.com',
        'country': 'Spain',
      },
      {'name': 'Li Wei', 'email': 'liwei@example.com', 'country': 'China'},
      {
        'name': 'Nguyen Van A',
        'email': 'nguyenvana@example.com',
        'country': 'Vietnam',
      },
      {'name': 'Ahmed Khan', 'email': 'ahmed@example.com', 'country': 'India'},
    ];

    for (final author in authors) {
      await LibraryDatabaseHelper.instance.insertAuthor(
        Author(
          name: author['name']!,
          email: author['email']!,
          country: author['country']!,
        ),
      );
    }
  }

  String _getRandomTitle(Random random) {
    final adjectives = [
      'Amazing',
      'Great',
      'Fantastic',
      'Wonderful',
      'Exciting',
    ];
    final nouns = ['Adventure', 'Journey', 'Mystery', 'Story', 'Tale'];
    return '${adjectives[random.nextInt(adjectives.length)]} ${nouns[random.nextInt(nouns.length)]}';
  }

  Future<void> _runSearch(String searchType) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _queryPlan = '';
      _executionTime = Duration.zero;
    });

    final stopwatch = Stopwatch()..start();
    List<Book> results = [];
    String plan = '';

    try {
      switch (searchType) {
        case 'year':
          results = await LibraryDatabaseHelper.instance.searchBooksByYear(
            int.parse(_yearController.text),
          );
          plan = await LibraryDatabaseHelper.instance.analyzeQueryPlan(
            'SELECT * FROM books WHERE publish_year = ?',
            [int.parse(_yearController.text)],
          );
          break;
        case 'price':
          results = await LibraryDatabaseHelper.instance
              .searchBooksByPriceRange(
                double.parse(_minPriceController.text),
                double.parse(_maxPriceController.text),
              );
          plan = await LibraryDatabaseHelper.instance.analyzeQueryPlan(
            'SELECT * FROM books WHERE price BETWEEN ? AND ?',
            [
              double.parse(_minPriceController.text),
              double.parse(_maxPriceController.text),
            ],
          );
          break;
        case 'complex':
          final year = int.parse(_yearController.text);
          final minPrice = double.parse(_minPriceController.text);
          final maxPrice = double.parse(_maxPriceController.text);
          final categoryId = int.parse(_categoryIdController.text);

          results = await LibraryDatabaseHelper.instance.searchBooksComplex(
            year,
            minPrice,
            maxPrice,
            categoryId,
          );

          plan = await LibraryDatabaseHelper.instance.analyzeQueryPlan(
            '''SELECT * FROM books 
               WHERE category_id = ? 
               AND publish_year = ? 
               AND price BETWEEN ? AND ?''',
            [categoryId, year, minPrice, maxPrice],
          );
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }

    stopwatch.stop();
    setState(() {
      _searchResults = results;
      _queryPlan = plan;
      _executionTime = stopwatch.elapsed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Comparison')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phần tạo dữ liệu mẫu
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tạo dữ liệu mẫu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sampleDataController,
                              decoration: const InputDecoration(
                                labelText: 'Số lượng sách',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập số lượng';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed:
                                    _isGeneratingData
                                        ? null
                                        : _generateSampleData,
                                child:
                                    _isGeneratingData
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text('Tạo dữ liệu mẫu'),
                              ),
                              if (_isGeneratingData)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${(_progress * 100).toStringAsFixed(1)}%',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Phần tìm kiếm
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tìm kiếm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          labelText: 'Năm xuất bản',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập năm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Giá tối thiểu',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập giá tối thiểu';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _maxPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Giá tối đa',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập giá tối đa';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID Danh mục',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập ID danh mục';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                _isLoading ? null : () => _runSearch('year'),
                            child: const Text('Tìm theo năm'),
                          ),
                          ElevatedButton(
                            onPressed:
                                _isLoading ? null : () => _runSearch('price'),
                            child: const Text('Tìm theo giá'),
                          ),
                          ElevatedButton(
                            onPressed:
                                _isLoading ? null : () => _runSearch('complex'),
                            child: const Text('Tìm phức hợp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Phần kết quả
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_searchResults.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tìm thấy ${_searchResults.length} kết quả trong ${_executionTime.inMilliseconds}ms',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Kế hoạch truy vấn:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 8, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_queryPlan),
                        ),
                        const Text(
                          'Kết quả:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              _searchResults.length > 10
                                  ? 10
                                  : _searchResults.length,
                          itemBuilder: (context, index) {
                            final book = _searchResults[index];
                            return ListTile(
                              title: Text(book.title),
                              subtitle: Text(
                                'Năm: ${book.publishYear}, Giá: \$${book.price.toStringAsFixed(2)}',
                              ),
                            );
                          },
                        ),
                        if (_searchResults.length > 10)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Hiển thị 10/${_searchResults.length} kết quả',
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
