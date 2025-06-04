import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'dart:io';
import 'package:provider/provider.dart';

// Page
import 'package:mission_master/features/home/screens/employee_home_screen.dart';
=======
import 'package:mission_master/features/admin/screens/admin_home_screen.dart';
import 'package:mission_master/features/admin/screens/create_manager_screen.dart';
import 'package:mission_master/features/admin/screens/employee_detail_screen.dart';
import 'package:mission_master/features/admin/screens/notification_screen.dart';
import 'package:mission_master/features/admin/screens/profile_screen.dart';
>>>>>>> develop
import 'package:mission_master/features/auth/screens/login_screen.dart';
import 'package:mission_master/features/auth/screens/register_screen.dart';
import 'package:mission_master/features/home/screens/calendar_task_screen.dart';
import 'package:mission_master/features/manager/screens/create_project_screen.dart';
import 'package:mission_master/features/tasks/screens/task_list_screen.dart';
import 'package:mission_master/features/projects/screens/project_list_screen.dart';
import 'package:mission_master/core/models/user.dart';

// Providers
import 'package:mission_master/emp_providers/user_provider.dart';
import 'package:mission_master/emp_providers/task_provider.dart';
import 'package:mission_master/emp_providers/project_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Database initialization removed

//  runApp(const MyApp());
runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),

        ChangeNotifierProxyProvider<UserProvider, TaskProvider>(
          create: (_) => TaskProvider(userId: 0),
          update: (_, userProvider, __) =>
              TaskProvider(userId: userProvider.userId ?? 0),
        ),

        ChangeNotifierProxyProvider2<UserProvider, TaskProvider, ProjectProvider>(
          create: (_) => ProjectProvider(
              userId: 0, taskProvider: TaskProvider(userId: 0)),
          update: (_, userProvider, taskProvider, __) => ProjectProvider(
            userId: userProvider.userId ?? 0,
            taskProvider: taskProvider,
          ),
        ),
      ],
      child: const MyApp(), // <-- MaterialApp ở trong Provider scope
    ),
  );
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
      initialRoute: '/login',
      routes: {
        '/': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        //'/home': (context) => CalendarTaskScreen(), -- của Nghĩa
        '/home_employee': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return EmployeeHomeScreen(userId: args['userId']);
        },
        '/tasks': (context) => const TaskListScreen(),
        '/projects': (context) => const ProjectListScreen(),
        '/admin': (context) => const AdminHomeScreen(),
        '/admin/profile': (context) => const ProfileScreen(),
        '/admin/dashboard': (context) => const AdminHomeScreen(),
        '/admin/notifications': (context) => const AdminNotificationScreen(),
        '/admin/create_manager': (context) => const CreateManagerScreen(),
      },
      // Handle route generation based on user role
      onGenerateRoute: (settings) {
        if (settings.name == '/role_redirect') {
          // Extract the user argument
          final args = settings.arguments as Map<String, dynamic>;
          final user = args['user'] as User;

          // Redirect based on user role
          if (user.isAdmin) {
            return MaterialPageRoute(
              builder: (context) => const AdminHomeScreen(),
            );
          } else if (user.isManager) {
            return MaterialPageRoute(
              builder: (context) => const ProjectListScreen(),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => CalendarTaskScreen(),
            );
          }
        }
        return null;
      },
    );
  }
}
