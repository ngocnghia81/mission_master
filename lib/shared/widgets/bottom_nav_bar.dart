import 'package:flutter/material.dart';
import 'package:mission_master/core/theme/app_colors.dart';

enum BottomNavItem {
  home,
  projects,
  employee,
  tasks,
  profile,
}

extension BottomNavItemExtension on BottomNavItem {
  String get iconPath {
    switch (this) {
      case BottomNavItem.home:
        return 'assets/images/home_icon.png';
      case BottomNavItem.projects:
        return 'assets/images/project_icon.png';
      case BottomNavItem.tasks:
        return 'assets/images/task_icon.png';
      case BottomNavItem.employee:
        return 'assets/images/employee_icon.png';
      case BottomNavItem.profile:
        return 'assets/images/profile_icon.png';
    }
  }

  String get label {
    switch (this) {
      case BottomNavItem.home:
        return 'Trang chủ';
      case BottomNavItem.projects:
        return 'Dự án';
      case BottomNavItem.tasks:
        return 'Nhiệm vụ';
      case BottomNavItem.employee:
        return 'Nhân viên';
      case BottomNavItem.profile:
        return 'Hồ sơ';
    }
  }
}

class BottomNavBarWidget extends StatelessWidget {
  final BottomNavItem currentItem;
  final Function(BottomNavItem) onItemSelected;
  final List<BottomNavItem> items;

  const BottomNavBarWidget({
    Key? key,
    required this.currentItem,
    required this.onItemSelected,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem currentItem có trong items không, nếu không thì dùng item đầu tiên
    final int currentIndex =
        items.contains(currentItem) ? items.indexOf(currentItem) : 0;

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
        currentIndex: currentIndex,
        elevation: 0,
        onTap: (index) => onItemSelected(items[index]),
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: _buildIcon(item.iconPath, item),
            label: item.label,
          );
        }).toList(),
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
