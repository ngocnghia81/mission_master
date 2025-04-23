import 'package:flutter/material.dart';
import 'package:mission_master/core/theme/app_colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const AppBarWidget({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.filterContainerBackground,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: Image.asset(
                'assets/images/arrow_left.png',
                width: 24,
                height: 24,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: Image.asset(
                'assets/images/arrow_left.png',
                width: 24,
                height: 24,
              ),
              onPressed: () {},
            ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryMedium,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: actions ??
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
