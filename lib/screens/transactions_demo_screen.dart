import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:isolate';
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../services/library_database_helper.dart';

class TransactionsDemoScreen extends StatefulWidget {
  const TransactionsDemoScreen({super.key});

  @override
  State<TransactionsDemoScreen> createState() => _TransactionsDemoScreenState();
}

class _TransactionsDemoScreenState extends State<TransactionsDemoScreen> {
  final _countController = TextEditingController(text: '1000');
  bool _isRunningBenchmark = false;
  Map<String, int> _benchmarkResults = {};
  bool _useIsolate = false;

  // Thêm sách riêng lẻ (không dùng transaction)
  Future<int> _addBooksIndividually(int count) async {
    final stopwatch = Stopwatch()..start();
    final random = Random();

    for (int i = 0; i < count; i++) {
      final book = _generateRandomBook(random, i);
      await LibraryDatabaseHelper.instance.insertBook(book);
    }

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  // Thêm sách sử dụng transaction
  Future<int> _addBooksWithTransaction(int count) async {
    final stopwatch = Stopwatch()..start();
    final random = Random();
    final db = await LibraryDatabaseHelper.instance.database;

    await db.transaction((txn) async {
      for (int i = 0; i < count; i++) {
        final book = _generateRandomBook(random, i);
        await txn.insert('books', book.toMap());
      }
    });

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  // Thêm sách sử dụng batch
  Future<int> _addBooksWithBatch(int count) async {
    final stopwatch = Stopwatch()..start();
    final random = Random();
    final db = await LibraryDatabaseHelper.instance.database;

    final batch = db.batch();
    for (int i = 0; i < count; i++) {
      final book = _generateRandomBook(random, i);
      batch.insert('books', book.toMap());
    }
    await batch.commit(noResult: true);

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  // Tạo sách ngẫu nhiên
  Book _generateRandomBook(Random random, int index) {
    final titlePrefixes = [
      'Giao dịch',
      'Transaction',
      'Tối ưu',
      'Hiệu suất',
      'Batched',
    ];
    final titleSuffixes = ['SQLite', 'Database', 'Flutter', 'Mobile', 'Demo'];

    final title =
        '${titlePrefixes[random.nextInt(titlePrefixes.length)]} ${titleSuffixes[random.nextInt(titleSuffixes.length)]} #${index + 1}';
    final isbn = 'BATCH-${random.nextInt(10000)}-${random.nextInt(10000)}';
    final authorId = random.nextInt(10) + 1; // giả sử có 10 tác giả
    final categoryId = random.nextInt(10) + 1; // giả sử có 10 thể loại
    final publishYear = 2020 + random.nextInt(5);
    final price = 100000.0 + random.nextInt(400) * 1000;
    final stockQuantity = random.nextInt(50) + 1;

    return Book(
      title: title,
      isbn: isbn,
      authorId: authorId,
      categoryId: categoryId,
      publishYear: publishYear,
      price: price,
      stockQuantity: stockQuantity,
    );
  }

  // Xóa toàn bộ sách demo
  Future<void> _clearBenchmarkBooks() async {
    final db = await LibraryDatabaseHelper.instance.database;
    await db.delete('books', where: "isbn LIKE ?", whereArgs: ['BATCH-%']);
  }

  // Chạy benchmark cho tất cả phương pháp
  Future<void> _runBenchmark() async {
    if (_isRunningBenchmark) return;

    final count = int.tryParse(_countController.text) ?? 1000;
    if (count <= 0 || count > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số lượng phải từ 1 đến 10000')),
      );
      return;
    }

    setState(() {
      _isRunningBenchmark = true;
      _benchmarkResults = {};
    });

    // Xóa dữ liệu cũ trước khi chạy test
    await _clearBenchmarkBooks();

    if (_useIsolate) {
      await _runBenchmarkInIsolate(count);
    } else {
      // Thêm sách riêng lẻ
      final individualTime = await _addBooksIndividually(count);
      await _clearBenchmarkBooks();

      // Thêm sách với transaction
      final transactionTime = await _addBooksWithTransaction(count);
      await _clearBenchmarkBooks();

      // Thêm sách với batch
      final batchTime = await _addBooksWithBatch(count);
      await _clearBenchmarkBooks();

      setState(() {
        _benchmarkResults = {
          'Thêm riêng lẻ': individualTime,
          'Dùng Transaction': transactionTime,
          'Dùng Batch': batchTime,
        };
        _isRunningBenchmark = false;
      });
    }
  }

  // Chạy benchmark trong isolate
  Future<void> _runBenchmarkInIsolate(int count) async {
    final receivePort = ReceivePort();

    // Chuẩn bị đường dẫn database để gửi sang isolate
    final dbPath = await LibraryDatabaseHelper.instance.getDatabasePath();

    // Lấy RootIsolateToken từ main isolate
    final rootIsolateToken = RootIsolateToken.instance!;

    await Isolate.spawn(_isolateEntryPoint, [
      receivePort.sendPort,
      count,
      dbPath,
      rootIsolateToken,
    ]);

    // Chờ kết quả từ isolate
    final results = await receivePort.first as Map<String, int>;

    setState(() {
      _benchmarkResults = results;
      _isRunningBenchmark = false;
    });
  }

  // Entry point cho isolate
  static Future<void> _isolateEntryPoint(List<dynamic> args) async {
    // Khởi tạo BackgroundIsolateBinaryMessenger cho isolate
    BackgroundIsolateBinaryMessenger.ensureInitialized(
      args[3] as RootIsolateToken,
    );

    // Khởi tạo databaseFactory cho isolate
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final SendPort sendPort = args[0] as SendPort;
    final int count = args[1] as int;
    final String dbPath = args[2] as String;

    // Tạo database helper riêng cho isolate
    final dbHelper = await LibraryDatabaseHelper.getInstance(dbPath);

    // Thêm sách riêng lẻ
    final individualTime = await _benchmarkIndividualInIsolate(count, dbHelper);
    await dbHelper.deleteBenchmarkBooks();

    // Thêm sách với transaction
    final transactionTime = await _benchmarkTransactionInIsolate(
      count,
      dbHelper,
    );
    await dbHelper.deleteBenchmarkBooks();

    // Thêm sách với batch
    final batchTime = await _benchmarkBatchInIsolate(count, dbHelper);
    await dbHelper.deleteBenchmarkBooks();

    // Gửi kết quả về main isolate
    sendPort.send({
      'Thêm riêng lẻ (Isolate)': individualTime,
      'Dùng Transaction (Isolate)': transactionTime,
      'Dùng Batch (Isolate)': batchTime,
    });

    // Đóng isolate
    Isolate.exit(sendPort);
  }

  // Các hàm benchmark trong isolate
  static Future<int> _benchmarkIndividualInIsolate(
    int count,
    LibraryDatabaseHelper dbHelper,
  ) async {
    final stopwatch = Stopwatch()..start();
    final random = Random();

    for (int i = 0; i < count; i++) {
      final book = _generateRandomBookInIsolate(random, i);
      await dbHelper.insertBook(book);
    }

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  static Future<int> _benchmarkTransactionInIsolate(
    int count,
    LibraryDatabaseHelper dbHelper,
  ) async {
    final stopwatch = Stopwatch()..start();
    final random = Random();
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      for (int i = 0; i < count; i++) {
        final book = _generateRandomBookInIsolate(random, i);
        await txn.insert('books', book.toMap());
      }
    });

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  static Future<int> _benchmarkBatchInIsolate(
    int count,
    LibraryDatabaseHelper dbHelper,
  ) async {
    final stopwatch = Stopwatch()..start();
    final random = Random();
    final db = await dbHelper.database;

    final batch = db.batch();
    for (int i = 0; i < count; i++) {
      final book = _generateRandomBookInIsolate(random, i);
      batch.insert('books', book.toMap());
    }
    await batch.commit(noResult: true);

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  // Tạo sách ngẫu nhiên trong isolate
  static Book _generateRandomBookInIsolate(Random random, int index) {
    final titlePrefixes = [
      'Giao dịch',
      'Transaction',
      'Tối ưu',
      'Hiệu suất',
      'Batched',
    ];
    final titleSuffixes = ['SQLite', 'Database', 'Flutter', 'Mobile', 'Demo'];

    final title =
        '${titlePrefixes[random.nextInt(titlePrefixes.length)]} ${titleSuffixes[random.nextInt(titleSuffixes.length)]} #${index + 1}';
    final isbn = 'BATCH-${random.nextInt(10000)}-${random.nextInt(10000)}';
    final authorId = random.nextInt(10) + 1; // giả sử có 10 tác giả
    final categoryId = random.nextInt(10) + 1; // giả sử có 10 thể loại
    final publishYear = 2020 + random.nextInt(5);
    final price = 100000.0 + random.nextInt(400) * 1000;
    final stockQuantity = random.nextInt(50) + 1;

    return Book(
      title: title,
      isbn: isbn,
      authorId: authorId,
      categoryId: categoryId,
      publishYear: publishYear,
      price: price,
      stockQuantity: stockQuantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions và Isolates')),
      body: SingleChildScrollView(
        child: Padding(
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
                        'Transactions và Background Processing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Demo này so sánh hiệu suất của ba phương pháp thêm bản ghi:',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Thêm từng bản ghi riêng lẻ',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. Thêm bản ghi trong một transaction',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '3. Thêm bản ghi sử dụng batch operations',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đồng thời, demo cũng so sánh việc thực thi trên Main Thread và Background Isolate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                        'Tham số benchmark',
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
                              controller: _countController,
                              decoration: const InputDecoration(
                                labelText: 'Số lượng bản ghi',
                                border: OutlineInputBorder(),
                                helperText: 'Từ 1 đến 10000',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.speed),
                            label: const Text('Chạy Benchmark'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed:
                                _isRunningBenchmark ? null : _runBenchmark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Sử dụng Background Isolate'),
                        subtitle: const Text(
                          'Chạy trong background thread để tránh block UI',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _useIsolate,
                        onChanged: (value) {
                          setState(() {
                            _useIsolate = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isRunningBenchmark
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Đang chạy benchmark... Vui lòng đợi.'),
                      ],
                    ),
                  )
                  : _benchmarkResults.isEmpty
                  ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lý do cần dùng Transactions và Batch',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '1. Transactions đảm bảo tính toàn vẹn dữ liệu:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '• Hoặc tất cả thao tác thành công, hoặc không thao tác nào được thực hiện',
                            style: TextStyle(fontSize: 14),
                          ),
                          const Text(
                            '• Giữ database trong trạng thái nhất quán',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '2. Transactions và Batch cải thiện hiệu suất:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '• Giảm số lần mở/đóng connections đến database',
                            style: TextStyle(fontSize: 14),
                          ),
                          const Text(
                            '• Tránh phí tổn I/O và giảm tải trên ổ đĩa',
                            style: TextStyle(fontSize: 14),
                          ),
                          const Text(
                            '• Giảm số lần cập nhật index, tối ưu hóa ghi dữ liệu',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '3. Khi nào sử dụng:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '• Thêm, cập nhật hoặc xóa nhiều bản ghi cùng lúc',
                            style: TextStyle(fontSize: 14),
                          ),
                          const Text(
                            '• Thao tác phụ thuộc lẫn nhau (VD: chuyển tiền giữa 2 tài khoản)',
                            style: TextStyle(fontSize: 14),
                          ),
                          const Text(
                            '• Import dữ liệu lớn từ file hoặc API',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Chạy Benchmark Ngay'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: _runBenchmark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kết quả benchmark với ${_countController.text} bản ghi',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBenchmarkResults(),
                          const SizedBox(height: 16),
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kết luận',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '1. Batch operations thường nhanh nhất cho các thao tác thêm/cập nhật nhiều bản ghi',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '2. Transactions cung cấp tính toàn vẹn dữ liệu với hiệu suất tốt hơn đáng kể so với thao tác riêng lẻ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '3. Thao tác riêng lẻ chậm nhất do phải mở/đóng nhiều kết nối và cập nhật index liên tục',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '4. Hiệu suất càng cải thiện rõ rệt khi số lượng bản ghi tăng lên',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenchmarkResults() {
    if (_benchmarkResults.isEmpty) {
      return const SizedBox();
    }

    // Tìm giá trị lớn nhất để tính tỷ lệ
    final maxTime = _benchmarkResults.values.reduce(max);

    // Tìm giá trị nhỏ nhất để tính cải thiện
    final minTime = _benchmarkResults.values.reduce(min);

    return Column(
      children: [
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.5),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.blue),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Phương pháp',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Thời gian (ms)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'So với thêm riêng lẻ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            ..._benchmarkResults.entries.map((entry) {
              final method = entry.key;
              final time = entry.value;

              // Tính % cải thiện so với thêm riêng lẻ
              final individualTime = _benchmarkResults['Thêm riêng lẻ'] ?? 1;
              final improvement =
                  (individualTime - time) / individualTime * 100;

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(method),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('$time ms'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        method == 'Thêm riêng lẻ'
                            ? const Text('-')
                            : Text(
                              '${improvement.toStringAsFixed(1)}% nhanh hơn',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'So sánh thời gian thực thi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._benchmarkResults.entries.map((entry) {
          final method = entry.key;
          final time = entry.value;

          final barColor =
              method == 'Thêm riêng lẻ'
                  ? Colors.red
                  : method == 'Dùng Transaction'
                  ? Colors.blue
                  : Colors.green;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 24,
                      width:
                          time /
                          maxTime *
                          MediaQuery.of(context).size.width *
                          0.7,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '$time ms',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }
}
