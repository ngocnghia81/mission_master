import 'package:flutter/material.dart';
import 'dart:math';
import 'models/book.dart';
import 'models/author.dart';
import 'models/category.dart';
import 'services/library_database_helper.dart';
import 'screens/index_demo_screen.dart';
import 'screens/schema_demo_screen.dart';
import 'screens/query_optimizations_screen.dart';
import 'screens/performance_comparison_screen.dart';
import 'screens/transactions_demo_screen.dart';
import 'screens/lazy_loading_demo_screen.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Optimization Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite Optimization Demo')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SQLite Optimization',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Các phần demo',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Tổng quan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LibraryHomePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schema),
              title: const Text('Schema Optimization'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SchemaDemoScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Indexing Demo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IndexDemoScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Query Optimization'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QueryOptimizationsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Performance Comparison'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerformanceComparisonScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Transactions Demo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsDemoScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Lazy Loading & Caching'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LazyLoadingDemoScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Về ứng dụng này'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'SQLite Optimization Demo',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.storage),
                  applicationLegalese:
                      'Ứng dụng demo minh họa các nguyên tắc tối ưu hóa SQLite trong Flutter.',
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Ứng dụng này được thiết kế để minh họa các khái niệm tối ưu hóa SQLite bao gồm: thiết kế schema, indexing, và tối ưu hóa truy vấn.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.storage, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'SQLite Optimization Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ứng dụng minh họa các nguyên tắc tối ưu hóa SQLite trong Flutter',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Chọn một mục từ menu để bắt đầu demo:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.schema,
                    title: 'Schema Optimization',
                    description: 'Thiết kế cấu trúc DB hiệu quả',
                    screen: const SchemaDemoScreen(),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.list_alt,
                    title: 'Indexing Demo',
                    description: 'So sánh hiệu suất với và không có index',
                    screen: const IndexDemoScreen(),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.search,
                    title: 'Query Optimization',
                    description: 'Các kỹ thuật tối ưu truy vấn',
                    screen: const QueryOptimizationsScreen(),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.speed,
                    title: 'Performance Comparison',
                    description: 'So sánh hiệu suất các kỹ thuật',
                    screen: const PerformanceComparisonScreen(),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.swap_horiz,
                    title: 'Transactions Demo',
                    description: 'So sánh hiệu suất transactions và batch',
                    screen: const TransactionsDemoScreen(),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.view_list,
                    title: 'Lazy Loading & Caching',
                    description: 'Demo infinite scrolling và cache hiệu quả',
                    screen: const LazyLoadingDemoScreen(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Khởi động Demo Đầy Đủ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LibraryHomePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Widget screen,
  }) {
    return SizedBox(
      width: 250,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 40, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryHomePage extends StatefulWidget {
  const LibraryHomePage({super.key});

  @override
  State<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends State<LibraryHomePage> {
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _isbnController = TextEditingController();
  final _searchController = TextEditingController();
  final _categoryController = TextEditingController();
  final _yearController = TextEditingController();

  List<Book> _books = [];
  List<Author> _authors = [];
  List<Category> _categories = [];
  String _queryPlan = '';
  bool _isSearching = false;
  bool _isGenerating = false;
  bool _hasIndexes = true;
  String _currentQuery = '';
  String _currentQueryType = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
    _checkIndexStatus();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _currentPage = 0;
      _hasMoreItems = true;
      _books = [];
    });
    await _loadMoreData();
    await _loadAuthorsAndCategories();
  }

  Future<void> _loadAuthorsAndCategories() async {
    final authors = await LibraryDatabaseHelper.instance.getAllAuthors();
    final categories = await LibraryDatabaseHelper.instance.getAllCategories();

    if (!mounted) return;
    setState(() {
      _authors = authors;
      _categories = categories;
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final books = await LibraryDatabaseHelper.instance.getBooksPaginated(
        offset: _currentPage * _pageSize,
        limit: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        if (books.length < _pageSize) {
          _hasMoreItems = false;
        }
        _books.addAll(books);
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
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
  }

  Future<void> _addBook() async {
    if (_formKey.currentState!.validate()) {
      // For demo purposes, we'll use random author and category
      final random = Random();
      final authorId =
          _authors.isNotEmpty
              ? _authors[random.nextInt(_authors.length)].id!
              : 1;
      final categoryId =
          _categories.isNotEmpty
              ? _categories[random.nextInt(_categories.length)].id!
              : 1;

      final book = Book(
        title: _titleController.text,
        isbn: _isbnController.text,
        authorId: authorId,
        categoryId: categoryId,
        publishYear: 2023,
        price: 29.99,
        stockQuantity: 10,
      );

      await LibraryDatabaseHelper.instance.insertBook(book);
      _titleController.clear();
      _isbnController.clear();
      _loadInitialData();
    }
  }

  Future<void> _searchBooksByTitle() async {
    if (_searchController.text.isEmpty) {
      _loadInitialData();
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQueryType = 'Search by Title';
      _currentQuery = """
        SELECT b.*, a.name as author_name, c.name as category_name
        FROM books b
        LEFT JOIN authors a ON b.author_id = a.id
        LEFT JOIN categories c ON b.category_id = c.id
        WHERE b.title LIKE ?
        ORDER BY b.title
        LIMIT $_pageSize
      """;
    });

    try {
      final stopwatch = Stopwatch()..start();
      final books = await LibraryDatabaseHelper.instance
          .searchBooksByTitleOptimized(
            _searchController.text,
            limit: _pageSize,
          );
      stopwatch.stop();

      final queryPlan = await LibraryDatabaseHelper.instance.explainQueryPlan(
        _currentQuery,
        ['%${_searchController.text}%'],
      );

      if (!mounted) return;
      setState(() {
        _books = books;
        _queryPlan =
            'Query execution time: ${stopwatch.elapsedMilliseconds}ms\n'
            'Indexes: ${_hasIndexes ? "Enabled ✅" : "Disabled ❌"}\n'
            'Query plan:\n$queryPlan';
        _isSearching = false;
        _hasMoreItems = books.length == _pageSize;
        _currentPage = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
    }
  }

  Future<void> _searchBooksByCategoryAndYear() async {
    if (_categoryController.text.isEmpty || _yearController.text.isEmpty) {
      return;
    }

    final categoryId = int.tryParse(_categoryController.text);
    final year = int.tryParse(_yearController.text);

    if (categoryId == null || year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập Category ID và Year hợp lệ'),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQueryType = 'Search by Category and Year';
      _currentQuery = '''
        SELECT b.*, a.name as author_name, c.name as category_name
        FROM books b
        LEFT JOIN authors a ON b.author_id = a.id
        LEFT JOIN categories c ON b.category_id = c.id
        WHERE b.category_id = $categoryId AND b.publish_year = $year
        ORDER BY b.title
      ''';
    });

    try {
      final stopwatch = Stopwatch()..start();
      final books = await LibraryDatabaseHelper.instance
          .searchBooksByCategoryAndYear(categoryId, year);
      stopwatch.stop();

      final queryPlan = await LibraryDatabaseHelper.instance.explainQueryPlan(
        _currentQuery,
        [categoryId, year],
      );

      if (!mounted) return;
      setState(() {
        _books = books;
        _queryPlan =
            'Query execution time: ${stopwatch.elapsedMilliseconds}ms\n'
            'Indexes: ${_hasIndexes ? "Enabled ✅" : "Disabled ❌"}\n'
            'Query plan:\n$queryPlan';
        _isSearching = false;
        _hasMoreItems = false; // Disable lazy loading for search results
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
    }
  }

  Future<void> _generateSampleData() async {
    setState(() {
      _isGenerating = true;
    });

    final random = Random();

    // Generate authors
    final authorNames = [
      'J.K. Rowling',
      'George R.R. Martin',
      'Stephen King',
      'Agatha Christie',
      'Dan Brown',
    ];
    final countries = ['UK', 'USA', 'France', 'Germany', 'Japan'];

    for (int i = 0; i < 5; i++) {
      final author = Author(
        name: authorNames[i],
        email:
            '${authorNames[i].toLowerCase().replaceAll(' ', '.')}@example.com',
        country: countries[i],
      );
      await LibraryDatabaseHelper.instance.insertAuthor(author);
    }

    // Generate categories
    final categoryNames = [
      'Fiction',
      'Non-Fiction',
      'Mystery',
      'Science Fiction',
      'Romance',
    ];
    final descriptions = [
      'Fictional stories',
      'Educational content',
      'Mystery novels',
      'Sci-fi books',
      'Romance novels',
    ];

    for (int i = 0; i < 5; i++) {
      final category = Category(
        name: categoryNames[i],
        description: descriptions[i],
      );
      await LibraryDatabaseHelper.instance.insertCategory(category);
    }

    // Generate books
    final titles = [
      'The Great Adventure',
      'Mystery of the Night',
      'The Lost City',
      'Future World',
      'The Last Chapter',
      'Hidden Secrets',
      'The Final Frontier',
      'Eternal Love',
      'The Dark Path',
      'The Bright Future',
    ];

    for (int i = 0; i < 100; i++) {
      final title =
          titles[random.nextInt(titles.length)] + ' ${random.nextInt(1000)}';
      final isbn =
          '978-${random.nextInt(10000)}-${random.nextInt(10000)}-${random.nextInt(10)}';
      final authorId = random.nextInt(5) + 1;
      final categoryId = random.nextInt(5) + 1;
      final publishYear = 2010 + random.nextInt(14);
      final price = 10.0 + random.nextDouble() * 40.0;
      final stockQuantity = random.nextInt(50) + 1;

      final book = Book(
        title: title,
        isbn: isbn,
        authorId: authorId,
        categoryId: categoryId,
        publishYear: publishYear,
        price: price,
        stockQuantity: stockQuantity,
      );

      await LibraryDatabaseHelper.instance.insertBook(book);
    }

    setState(() {
      _isGenerating = false;
    });

    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Schema Optimization Demo'),
        actions: [
          // Toggle indexes button
          IconButton(
            icon: Icon(_hasIndexes ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleIndexes,
            tooltip: _hasIndexes ? 'Disable Indexes' : 'Enable Indexes',
          ),
          // Generate data button
          IconButton(
            icon:
                _isGenerating
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.data_array),
            onPressed: _isGenerating ? null : _generateSampleData,
            tooltip: 'Generate Sample Data',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SQLite Optimization',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Các phần demo',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Tổng quan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schema),
              title: const Text('Schema Optimization'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SchemaDemoScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Indexing Demo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IndexDemoScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Query Optimization'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QueryOptimizationsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Performance Comparison'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerformanceComparisonScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add book form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Book',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _isbnController,
                        decoration: const InputDecoration(
                          labelText: 'ISBN',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an ISBN';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addBook,
                        child: const Text('Add Book'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search Books',
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
                              labelText: 'Search by title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSearching ? null : _searchBooksByTitle,
                          child:
                              _isSearching
                                  ? const CircularProgressIndicator()
                                  : const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category ID',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _yearController,
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed:
                              _isSearching
                                  ? null
                                  : _searchBooksByCategoryAndYear,
                          child:
                              _isSearching
                                  ? const CircularProgressIndicator()
                                  : const Text('Search'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Query plan display
            if (_queryPlan.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Query: $_currentQueryType',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _currentQuery,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(_queryPlan),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Books list
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Books (${_books.length}${_hasMoreItems ? '+' : ''})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_isLoadingMore)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _books.length + (_hasMoreItems ? 1 : 0),
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
                            final author = _authors.firstWhere(
                              (a) => a.id == book.authorId,
                              orElse:
                                  () => Author(
                                    name: 'Unknown',
                                    email: '',
                                    country: '',
                                  ),
                            );
                            final category = _categories.firstWhere(
                              (c) => c.id == book.categoryId,
                              orElse:
                                  () => Category(
                                    name: 'Unknown',
                                    description: '',
                                  ),
                            );

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(book.title),
                                subtitle: Text(
                                  '${author.name} | ${category.name} | '
                                  '${book.publishYear} | \$${book.price.toStringAsFixed(2)}',
                                ),
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _isbnController.dispose();
    _searchController.dispose();
    _categoryController.dispose();
    _yearController.dispose();
    LibraryDatabaseHelper.instance.close();
    super.dispose();
  }
}
