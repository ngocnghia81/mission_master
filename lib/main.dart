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
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              'Transactions Demo',
              Icons.speed,
              'So sánh hiệu suất riêng lẻ vs transactions vs batch',
              () => Navigator.pushNamed(context, '/transactions'),
            ),
          ),
          Expanded(
            child: _buildFeatureCard(
              'Lazy Loading & Caching',
              Icons.view_list,
              'Demo infinite scrolling và chiến lược cache hiệu quả',
              () => Navigator.pushNamed(context, '/lazy_loading'),
            ),
          ),
        ],
      ),
      // ... rest of code ...
    ],
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
