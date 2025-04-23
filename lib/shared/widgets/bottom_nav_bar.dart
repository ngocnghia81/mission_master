import 'package:flutter/material.dart';
import 'package:mission_master/core/theme/app_colors.dart';

enum BottomNavItem {
  home,
  projects,
  tasks,
}

class BottomNavBarWidget extends StatelessWidget {
  final BottomNavItem currentItem;
  final Function(BottomNavItem) onItemSelected;

  const BottomNavBarWidget({
    Key? key,
    required this.currentItem,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryMedium,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentItem.index,
        elevation: 0,
        onTap: (index) => onItemSelected(BottomNavItem.values[index]),
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon('assets/images/home_icon.png', BottomNavItem.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(
                'assets/images/project_icon.png', BottomNavItem.projects),
            label: 'Dự án',
          ),
          BottomNavigationBarItem(
            icon:
                _buildIcon('assets/images/task_icon.png', BottomNavItem.tasks),
            label: 'Nhiệm vụ',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String assetPath, BottomNavItem item) {
    final bool isSelected = currentItem == item;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        assetPath,
        width: 24,
        height: 24,
        color: isSelected ? AppColors.primaryMedium : Colors.grey,
      ),
    );
  }
}
