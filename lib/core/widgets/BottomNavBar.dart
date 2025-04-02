import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('assets/images/home_icon.png'), size: 24),
          label: '', // Added label
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('assets/images/project_icon.png'), size: 24),
          label: '', // Added label
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('assets/images/task_icon.png'), size: 24),
          label: '', // Added label
        ),
      ],
    );
  }
}