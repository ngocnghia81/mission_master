import 'package:flutter/material.dart';
import 'core/services/database_service.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  String _status = 'Chưa kiểm tra';
  bool _isChecking = false;

  Future<void> _checkDatabase() async {
    setState(() {
      _isChecking = true;
      _status = 'Đang kiểm tra...';
    });

    try {
      final db = await DatabaseService.instance.database;

      // Thử thực hiện một truy vấn đơn giản
      await db.rawQuery('SELECT sqlite_version()');

      setState(() {
        _status = 'Kết nối database thành công!';
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Lỗi kết nối database: $e';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra Database'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _status.contains('thành công')
                    ? Icons.check_circle
                    : _status.contains('Lỗi')
                        ? Icons.error
                        : Icons.info,
                size: 80,
                color: _status.contains('thành công')
                    ? Colors.green
                    : _status.contains('Lỗi')
                        ? Colors.red
                        : Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isChecking ? null : _checkDatabase,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: _isChecking
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Kiểm tra Kết nối',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
