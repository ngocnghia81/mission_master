import 'package:flutter/material.dart';
import 'package:mission_master/features/auth/screens/login_screen.dart';
import 'package:mission_master/features/auth/screens/register_screen.dart';
import 'package:mission_master/features/home/screens/calendar_task_screen.dart';
import 'package:mission_master/features/home/screens/employee_home_screen.dart';
import 'package:mission_master/features/manager/screens/create_project_screen.dart';
import 'package:mission_master/features/tasks/screens/task_list_screen.dart';
import 'package:mission_master/features/projects/screens/project_list_screen.dart';

import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Database initialization removed

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mission Master',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      // initialRoute: '/login',
      // routes: {
      //   '/': (context) => LoginScreen(),
      //   '/login': (context) => LoginScreen(),
      //   '/register': (context) => RegisterScreen(),
      //   '/home': (context) => CalendarTaskScreen(),
      //   '/tasks': (context) => const TaskListScreen(),
      //   '/projects': (context) => const ProjectListScreen(),
      // },
      home: EmployeeHomeScreen(),
    );
  }
}
