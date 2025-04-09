import 'package:flutter/material.dart';
import '../services/library_database_helper.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/category.dart';
import 'dart:math';

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
    });

    // Xóa dữ liệu cũ
    await LibraryDatabaseHelper.instance.deleteAllBooks();

    // Tạo danh mục nếu chưa có
    final categories = await LibraryDatabaseHelper.instance.getAllCategories();
    if (categories.isEmpty) {
      await _createSampleCategories();
    }

    // Tạo tác giả nếu chưa có
    final authors = await LibraryDatabaseHelper.instance.getAllAuthors();
    if (authors.isEmpty) {
      await _createSampleAuthors();
    }

    // Lấy danh sách danh mục và tác giả để sử dụng
    final updatedCategories =
        await LibraryDatabaseHelper.instance.getAllCategories();
    final updatedAuthors = await LibraryDatabaseHelper.instance.getAllAuthors();

    // Tạo ngẫu nhiên sách
    final random = Random();
    for (int i = 0; i < count; i++) {
      final book = Book(
        title: 'Book ${i + 1} - ${_getRandomTitle(random)}',
        isbn: 'ISBN-${10000 + i}',
        authorId: updatedAuthors[random.nextInt(updatedAuthors.length)].id!,
        categoryId:
            updatedCategories[random.nextInt(updatedCategories.length)].id!,
        publishYear: 2010 + random.nextInt(14), // 2010-2023
        price: 10 + random.nextDouble() * 90, // $10-$100
        stockQuantity: random.nextInt(100),
      );

      await LibraryDatabaseHelper.instance.insertBook(book);

      // Cập nhật UI mỗi 20 cuốn để người dùng thấy tiến trình
      if (i % 20 == 0) {
        setState(() {});
      }
    }

    setState(() {
      _isGeneratingData = false;
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
          results = await LibraryDatabaseHelper.instance.searchBooksComplex(
            int.parse(_yearController.text),
            double.parse(_minPriceController.text),
            double.parse(_maxPriceController.text),
            int.parse(_categoryIdController.text),
          );
          plan = await LibraryDatabaseHelper.instance.analyzeQueryPlan(
            'SELECT * FROM books WHERE publish_year = ? AND price BETWEEN ? AND ? AND category_id = ?',
            [
              int.parse(_yearController.text),
              double.parse(_minPriceController.text),
              double.parse(_maxPriceController.text),
              int.parse(_categoryIdController.text),
            ],
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
                          ElevatedButton(
                            onPressed:
                                _isGeneratingData ? null : _generateSampleData,
                            child:
                                _isGeneratingData
                                    ? const CircularProgressIndicator()
                                    : const Text('Tạo dữ liệu mẫu'),
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
