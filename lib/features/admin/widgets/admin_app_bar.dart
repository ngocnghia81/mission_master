import 'package:flutter/material.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/services/api_service.dart';
import 'package:mission_master/core/models/user.dart';

class AdminAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AdminAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  State<AdminAppBar> createState() => _AdminAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AdminAppBarState extends State<AdminAppBar> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final userMap = await ApiService.instance.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = User.fromMap(userMap);
        });
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';

    List<String> nameParts = fullName.split(' ');
    if (nameParts.length == 1) return nameParts[0][0];

    return nameParts.first[0] + nameParts.last[0];
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.filterContainerBackground,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: CircleAvatar(
            backgroundColor: AppColors.primaryMedium,
            radius: 16,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                _currentUser != null
                    ? _getInitials(_currentUser!.fullName)
                    : 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xin chào,',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
      actions: widget.actions ??
          [
            IconButton(
              icon: Image.asset(
                'assets/images/bell.png',
                width: 24,
                height: 24,
                color: AppColors.primaryMedium,
              ),
              onPressed: () {},
            ),
          ],
    );
  }
}
