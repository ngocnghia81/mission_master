import 'package:flutter/material.dart';
import 'package:mission_master/core/theme/app_colors.dart';

/// Enum defining the navigation items available in the admin bottom navigation bar
enum AdminNavItem {
  dashboard,
  users,
}

/// A specialized bottom navigation bar for the admin role
class AdminBottomNavBar extends StatelessWidget {
  final AdminNavItem currentItem;
  final Function(AdminNavItem) onItemSelected;

  const AdminBottomNavBar({
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
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentItem.index,
        elevation: 0,
        onTap: (index) => onItemSelected(AdminNavItem.values[index]),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: currentItem == AdminNavItem.dashboard
                  ? AppColors.primaryMedium
                  : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: currentItem == AdminNavItem.users
                  ? AppColors.primaryMedium
                  : Colors.grey,
            ),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
