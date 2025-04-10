import 'package:flutter/material.dart';
import 'dart:isolate';
import '../models/book.dart';
import '../services/library_database_helper.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LoadBooksDemoScreen extends StatefulWidget {
  const LoadBooksDemoScreen({super.key});

  @override
  State<LoadBooksDemoScreen> createState() => _LoadBooksDemoScreenState();
}

class _LoadBooksDemoScreenState extends State<LoadBooksDemoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _uiAnimationController;
  bool _isLoading = false;
  bool _useIsolate = false;
  List<Book> _books = [];
  int _loadTime = 0;
  int _droppedFrames = 0;
  final _animationController = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _uiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _books = [];
      _loadTime = 0;
    });

    // Start animation
    _startLoadingAnimation();

    try {
      final stopwatch = Stopwatch()..start();

      if (_useIsolate) {
        await _loadBooksWithIsolate();
      } else {
        _books = await LibraryDatabaseHelper.instance.getAllBooks();
      }

      stopwatch.stop();
      _loadTime = stopwatch.elapsedMilliseconds;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
      _animationController.value = 0;
    }
  }

  Future<void> _loadBooksWithIsolate() async {
    final receivePort = ReceivePort();
    final dbPath = await LibraryDatabaseHelper.instance.getDatabasePath();
    final rootIsolateToken = RootIsolateToken.instance!;

    await Isolate.spawn(_isolateFunction, [
      receivePort.sendPort,
      dbPath,
      rootIsolateToken,
    ]);

    final books = await receivePort.first as List<Book>;
    setState(() => _books = books);
  }

  static Future<void> _isolateFunction(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final String dbPath = args[1];
    final RootIsolateToken token = args[2];

    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbHelper = await LibraryDatabaseHelper.getInstance(dbPath);
    final books = await dbHelper.getAllBooks();

    sendPort.send(books);
    Isolate.exit();
  }

  void _startLoadingAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!_isLoading) return false;
      _animationController.value += 0.05;
      if (_animationController.value >= 1) {
        _animationController.value = 0;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Tải Sách')),
      body: Column(
        children: [
          // Phần demo khả năng phản hồi UI
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                RotationTransition(
                  turns: _uiAnimationController,
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                    child: const Center(
                      child: Text('UI', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kiểm tra độ mượt UI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Theo dõi hình vuông này - nó phải xoay mượt mà',
                        style: TextStyle(fontSize: 14),
                      ),
                      if (_droppedFrames > 0)
                        Text(
                          'Số khung hình bị giật: $_droppedFrames',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Phần điều khiển
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sử dụng Isolate'),
                  subtitle: Text(
                    _useIsolate
                        ? 'Đang tải trong luồng nền (UI vẫn mượt)'
                        : 'Đang tải trong luồng chính (UI có thể bị đứng)',
                    style: TextStyle(
                      color: _useIsolate ? Colors.green : Colors.orange,
                    ),
                  ),
                  value: _useIsolate,
                  onChanged:
                      _isLoading
                          ? null
                          : (value) {
                            setState(() => _useIsolate = value);
                          },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.refresh),
                  label: Text(_isLoading ? 'Đang tải...' : 'Tải 100k Sách'),
                  onPressed: _isLoading ? null : _loadBooks,
                ),
              ],
            ),
          ),

          // Phần kết quả
          if (_loadTime > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kết quả hiệu năng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Tổng số sách đã tải: ${_books.length}'),
                      Text('Thời gian tải: ${_loadTime}ms'),
                      Text(
                        'Độ mượt UI: ${_droppedFrames == 0 ? "Mượt mà ✅" : "Giật lag ❌"}',
                        style: TextStyle(
                          color:
                              _droppedFrames == 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Danh sách sách
          Expanded(
            child: ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(
                    'Mã ISBN: ${book.isbn}\nGiá: ${book.price.toStringAsFixed(2)}đ',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _uiAnimationController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
