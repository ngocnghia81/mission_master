import 'package:flutter/material.dart';
import '../services/library_database_helper.dart';

class SchemaDemoScreen extends StatefulWidget {
  const SchemaDemoScreen({super.key});

  @override
  State<SchemaDemoScreen> createState() => _SchemaDemoScreenState();
}

class _SchemaDemoScreenState extends State<SchemaDemoScreen> {
  String _bookSchema = '';
  String _authorSchema = '';
  String _categorySchema = '';

  @override
  void initState() {
    super.initState();
    _loadSchemas();
  }

  Future<void> _loadSchemas() async {
    final bookSchema = await LibraryDatabaseHelper.instance.getTableSchema(
      'books',
    );
    final authorSchema = await LibraryDatabaseHelper.instance.getTableSchema(
      'authors',
    );
    final categorySchema = await LibraryDatabaseHelper.instance.getTableSchema(
      'categories',
    );

    setState(() {
      _bookSchema = bookSchema;
      _authorSchema = authorSchema;
      _categorySchema = categorySchema;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schema Optimization Demo')),
      body: SingleChildScrollView(
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
                      'Nguyên tắc tối ưu Schema',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. Chuẩn hóa dữ liệu để tránh lặp lại thông tin',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Sử dụng kiểu dữ liệu phù hợp (INTEGER, TEXT, REAL, etc.)',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. Sử dụng khóa chính (PRIMARY KEY) cho mỗi bảng',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4. Sử dụng khóa ngoại (FOREIGN KEY) để thiết lập mối quan hệ',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '5. Đặt ràng buộc NOT NULL cho các cột quan trọng',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'So sánh trước và sau khi tối ưu Schema',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Trước khi tối ưu:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Tất cả dữ liệu được lưu trong một bảng duy nhất\n'
                      '• Thông tin tác giả và thể loại bị lặp lại nhiều lần\n'
                      '• Không có ràng buộc về kiểu dữ liệu\n'
                      '• Khó khăn trong việc cập nhật và bảo trì\n'
                      '• Tốn không gian lưu trữ không cần thiết',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sau khi tối ưu:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Tách thành 3 bảng riêng biệt có quan hệ\n'
                      '• Sử dụng khóa ngoại để liên kết dữ liệu\n'
                      '• Áp dụng ràng buộc kiểu dữ liệu chặt chẽ\n'
                      '• Dễ dàng mở rộng và bảo trì\n'
                      '• Tối ưu không gian lưu trữ',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mô hình quan hệ Database',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppBar(
                              title: const Text('Mô hình quan hệ Database'),
                              leading: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            Flexible(
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: Image.asset(
                                  'assets/db_schema.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/db_schema.png',
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text(
                              'Biểu đồ Schema',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Nhấn để phóng to',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
            const SizedBox(height: 24),
            const Text(
              'Chi tiết cấu trúc bảng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSchemaCard('Bảng Books', _bookSchema, [
              'id: Khóa chính, tự động tăng',
              'title: Tên sách (TEXT, NOT NULL)',
              'isbn: Mã ISBN sách (TEXT, UNIQUE)',
              'author_id: Khóa ngoại tới bảng Authors',
              'category_id: Khóa ngoại tới bảng Categories',
              'publish_year: Năm xuất bản (INTEGER)',
              'price: Giá sách (REAL)',
              'stock_quantity: Số lượng tồn kho (INTEGER)',
            ]),
            const SizedBox(height: 16),
            _buildSchemaCard('Bảng Authors', _authorSchema, [
              'id: Khóa chính, tự động tăng',
              'name: Tên tác giả (TEXT, NOT NULL)',
              'email: Email tác giả (TEXT)',
              'country: Quốc gia (TEXT)',
            ]),
            const SizedBox(height: 16),
            _buildSchemaCard('Bảng Categories', _categorySchema, [
              'id: Khóa chính, tự động tăng',
              'name: Tên thể loại (TEXT, NOT NULL)',
              'description: Mô tả (TEXT)',
            ]),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lợi ích của thiết kế schema tối ưu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. Giảm dư thừa dữ liệu, tiết kiệm không gian lưu trữ',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Đảm bảo tính toàn vẹn dữ liệu với các ràng buộc',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. Tối ưu hiệu suất truy vấn với cấu trúc hợp lý',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4. Dễ dàng mở rộng và bảo trì khi ứng dụng phát triển',
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

  Widget _buildSchemaCard(
    String title,
    String schema,
    List<String> descriptions,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...descriptions.map(
              (desc) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('• $desc', style: const TextStyle(fontSize: 14)),
              ),
            ),
            if (schema.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Schema SQL:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  schema,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
