import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'library_app.dart';
import 'services/sample_data_service.dart';

void main() async {
  // Đảm bảo Flutter đã khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo databaseFactory cho main thread
  sqfliteFfiInit();
  // Đặt database factory để sử dụng FFI
  databaseFactory = databaseFactoryFfi;

  // Tạo dữ liệu mẫu khi ứng dụng khởi động
  await SampleDataService.initializeSampleData();

  runApp(const LibraryApp());
}

Widget _buildFeatureCards(BuildContext context) {
  final features = [
    {
      'title': 'Transactions Demo',
      'icon': Icons.speed,
      'description': 'So sánh hiệu suất riêng lẻ vs transactions vs batch',
      'route': '/transactions',
    },
    {
      'title': 'Lazy Loading & Caching',
      'icon': Icons.view_list,
      'description': 'Demo infinite scrolling và chiến lược cache hiệu quả',
      'route': '/lazy_loading',
    },
    {
      'title': 'Load Books Demo',
      'icon': Icons.book,
      'description': 'So sánh hiệu suất load sách với và không có Isolate',
      'color': Colors.teal[100],
      'iconColor': Colors.teal[700],
      'route': '/load_books_demo',
    },
  ];

  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 3 / 2,
    ),
    itemCount: features.length,
    itemBuilder: (context, index) {
      final feature = features[index];
      return Card(
        color: feature['color'] as Color?,
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, feature['route'] as String),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  feature['icon'] as IconData,
                  size: 48,
                  color: feature['iconColor'] as Color?,
                ),
                const SizedBox(height: 16),
                Text(
                  feature['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  feature['description'] as String,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildFeatureCard(
  String title,
  IconData icon,
  String description,
  VoidCallback onPressed,
) {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.all(8),
    child: InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    ),
  );
}
