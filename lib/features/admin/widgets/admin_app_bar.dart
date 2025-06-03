import 'package:flutter/material.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/services/api_service.dart';
import 'package:mission_master/core/models/user.dart';

class AdminAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showDrawerButton;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AdminAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showDrawerButton = true,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<AdminAppBar> createState() => _AdminAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AdminAppBarState extends State<AdminAppBar> {
  User? _currentUser;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getNotificationCount();
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

  Future<void> _getNotificationCount() async {
    // Trong thực tế, bạn sẽ lấy số lượng thông báo chưa đọc từ API
    setState(() {
      _notificationCount = 3; // Giả sử có 3 thông báo chưa đọc
    });
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
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
              onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : (widget.showDrawerButton 
              ? Builder(
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
                )
              : null),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
      centerTitle: true,
      actions: widget.actions ??
          [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: AppColors.primaryMedium,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin/notifications');
                  },
                ),
                if (_notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        _notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
          ],
    );
  }
}
