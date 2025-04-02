import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/screens/Login.dart';
import 'core/services/database_service.dart';
import 'features/tasks/task_list_screen.dart';

void main() async {
  // t tạm tắt mấy lệnh này chứ không chạy được
  // WidgetsFlutterBinding.ensureInitialized();

  // // Initialize FFI for Linux
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  // // Khởi tạo database sau khi đã thiết lập databaseFactory
  // await DatabaseService.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mission Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF022E39)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
