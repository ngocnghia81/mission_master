// lib/screens/CalendarTaskScreen.
import 'package:flutter/material.dart';
import '../widgets/CalendarWidget.dart';
import '../widgets/TaskListWidget.dart';
import '../widgets/BottomNavBar.dart'; // Import widget

class CalendarTaskScreen extends StatefulWidget {
  @override
  _CalendarTaskScreenState createState() => _CalendarTaskScreenState();
}

class _CalendarTaskScreenState extends State<CalendarTaskScreen> {
  DateTime _selectedDate = DateTime.now();

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Việc cần làm',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarWidget(onDateSelected: _onDateSelected),
          const SizedBox(height: 10),
          TaskListWidget(selectedDate: _selectedDate),
        ],
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(), // Sử dụng widget mới
    );
  }
}
