import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mission_master/core/models/task_detail.dart';

//Giao diện
import 'package:mission_master/core/widgets/TaskListWidget.dart';
import 'package:mission_master/emp_providers/user_provider.dart';
import 'package:mission_master/features/home/screens/calendar_task_screen.dart'
    as calendar;
import 'package:mission_master/features/projects/screens/project_list_screen.dart';
import 'package:mission_master/features/tasks/task_list_screen.dart';

// Color và widgets
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/shared/widgets/bottom_nav_bar.dart';
import 'package:mission_master/shared/widgets/progress_circle_painter.dart';

//Các model
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/models/project.dart';
import 'package:mission_master/core/models/task.dart';
import 'package:mission_master/core/models/task_detail.dart';
import 'package:mission_master/core/models/project_membership.dart';

//Providers
import 'package:provider/provider.dart';
import 'package:mission_master/emp_providers/task_provider.dart';
import 'package:mission_master/emp_providers/project_provider.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final int userId;
  const EmployeeHomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EmployeeHomeScreenState createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  BottomNavItem _currentItem =
      BottomNavItem.home; 
  double _totalRatio = 0.0; 
  User? _user;
  int get userId => widget.userId; 
  List<Project> _currentProjects = [];
  List<Task> _tasks = []; 
  List<ProjectMembership> _projectMembers = []; 
  List<TaskDetail> _taskDetails = []; 
  Map<int, double> _projectProgress =
      {}; 
  Map<int, double> _taskProgress = {}; 
  bool _isLoading = true;

  // Danh sách item Employee
  final List<BottomNavItem> _navItems = [
    BottomNavItem.home,
    BottomNavItem.projects,
    BottomNavItem.tasks,
    BottomNavItem.profile,
  ];

  @override
  void initState() {
    super.initState();
    _currentItem =
        BottomNavItem.home; 
    _loadAllUserData();
  }

  // load dữ liệu từ các Provider
  Future<void> _loadAllUserData() async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await taskProvider.loadUserData();
      await projectProvider.loadUserData();

      setState(() {
        _user = userProvider.currentUser;
        _tasks = taskProvider.tasks;
        _taskDetails = taskProvider.taskDetails;
        _currentProjects = projectProvider.projects.where(
        (project) =>
            project.status.toLowerCase() == 'not_started' ||
            project.status.toLowerCase() == 'in_progress',
      ).toList();
        _projectMembers = projectProvider.projectMemberships;
        _projectProgress = projectProvider.projectProgress;
        _taskProgress = taskProvider.taskProgress;
        _totalRatio = calculateAverageProgress();
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi load dữ liệu: $e');
    }
  }

  void _onItemSelected(BottomNavItem item) {
    if (item == BottomNavItem.home) {
      // Đã ở EmployeeHomeScreen, không cần điều hướng
      setState(() {
        _currentItem = item;
      });
      return;
    }

    // Điều hướng sang màn hình tương ứng
    Widget? targetScreen;
    switch (item) {
      case BottomNavItem.projects:
        targetScreen = const ProjectListScreen();
        break;
      case BottomNavItem.tasks:
        targetScreen = const TaskListScreen();
        break;
      case BottomNavItem.profile:
        targetScreen = calendar.CalendarTaskScreen();
        break;
      default:
        return;
    }

    // Điều hướng sang màn hình mới, và khi quay lại thì set lại item về home
    Navigator.push(
      context,
      createSlideTransitionRoute(targetScreen),
    ).then((_) {
      setState(() {
        _currentItem = BottomNavItem.home;
      });
    });
  }


  // Tính toán tỷ lệ công việc của từng dự án
  double calculateProjectProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;

    final int completedCount =
        tasks.where((e) => e.status.toLowerCase() == 'completed').length;

    return completedCount / tasks.length;
  }

  // Tính toán tỷ lệ công việc của từng task
  double calculateTaskProgress(List<TaskDetail> taskDetails) {
    if (taskDetails.isEmpty) return 0.0;

    final int completedCount =
        taskDetails.where((e) => e.status.toLowerCase() == 'completed').length;

    return completedCount / taskDetails.length;
  }

  //Tính toán tỷ lệ tổng công việc trong ngày
  double calculateAverageProgress() {
    final today = DateTime.now();

    // Lọc các task có ngày tạo là hôm nay
    final todayTasks = _tasks.where((task) {
      final createdAt = task.createdAt;
      return createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day;
    }).toList();

    if (todayTasks.isEmpty) return 0.0;

    // Đếm số task đã hoàn thành
    final completedCount =
        todayTasks.where((task) => task.status == 'completed').length;

    // Tính phần trăm
    return completedCount / todayTasks.length;
  }

  // Chuyển đổi tỷ lệ từ 0-1 sang 0-100
  double normalizeProgress(double? value) {
    if (value == null) return 0.0;
    return value.clamp(0.0, 1.0);
  }

// Hàm tạo hiệu ứng chuyển trang dạng trượt từ phải sang trái
  Route createSlideTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // Kiểm tra xem nhiệm vụ có mới hay không
  bool isNewTask(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24; // Mới nếu được tạo trong vòng 24 giờ
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Builder(
            builder: (context) => InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              splashColor: Colors.grey,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.only(left: 16, top: 10),
            child: ClipOval(
              child: Image.asset(
                'assets/images/${_user?.avatar ?? 'ava 2'}.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Xin chào,',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMedium,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _user?.fullName ?? 'Người dùng',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.primaryMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(right: 16),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAllUserData,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: Text('Item 1'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shadowColor: Colors.grey,
                        color: AppColors.primaryMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6 -
                                    32,
                                child: Column(
                                  children: [
                                    const Text(
                                      'Nhiệm vụ ngày hôm nay của bạn!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          createSlideTransitionRoute(
                                            TaskListWidget(
                                                selectedDate: DateTime.now()),
                                          ),
                                        ).then((_) {
                                          // Khi quay lại, đặt lại _currentItem
                                          setState(() {
                                            _currentItem = BottomNavItem.home;
                                          });
                                        });
                                      },
                                      child: const Text(
                                        'Hiện công việc',
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.primaryMedium,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: CustomPaint(
                                      painter: ProgressCirclePainter(
                                        progress: _totalRatio,
                                        progressColor:
                                            AppColors.progress ?? Colors.orange,
                                        backgroundColor: Colors.white,
                                        strokeWidth: 8.0,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${(normalizeProgress(_totalRatio) * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFA726),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Dự án hiện tại (${_currentProjects.length})',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ignore: sized_box_for_whitespace
                      Container(
                        height: 120,
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _currentProjects.length,
                          controller: PageController(
                            viewportFraction: 0.8,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  createSlideTransitionRoute(
                                    TaskListWidget(
                                        selectedDate: DateTime.now()),
                                  ),
                                ).then((_) {
                                  // Khi quay lại, đặt lại _currentItem
                                  setState(() {
                                    _currentItem = BottomNavItem.home;
                                  });
                                });
                              },
                              child: Card(
                                color: AppColors.contentColorList[
                                    index % AppColors.contentColorList.length],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            width: 220,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${_projectMembers.where((e) => e.projectId == _currentProjects[index].id).length} thành viên',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.primaryMedium,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _currentProjects[index]
                                                          .name
                                                          ?.toString() ??
                                                      'Không có tên',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color:
                                                        AppColors.primaryDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                              right: 15,
                                            ),
                                            child: Image.asset(
                                              'assets/images/calendar_icon.png',
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.error),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            height: 10,
                                            width: constraints.maxWidth * 0.9,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  return Container(
                                                    height: 8,
                                                    width:
                                                        constraints.maxWidth *
                                                            0.9,
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: _projectProgress[
                                                              _currentProjects[
                                                                  index]] ??
                                                          0.0,
                                                      backgroundColor:
                                                          Colors.white,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        AppColors
                                                                .progressColorsList[
                                                            index %
                                                                AppColors
                                                                    .progressColorsList
                                                                    .length],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          onPageChanged: (index) {
                            print('Chuyển sang trang khác: $index');
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Việc cần làm',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                createSlideTransitionRoute(
                                  TaskListWidget(selectedDate: DateTime.now()),
                                ),
                              ).then((_) {
                                // Khi quay lại, đặt lại _currentItem
                                setState(() {
                                  _currentItem = BottomNavItem.home;
                                });
                              });
                            },
                            child: Card(
                              elevation: 4,
                              shadowColor: Colors.grey,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            width: constraints.maxWidth * 0.6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _tasks[index]
                                                          .title
                                                          ?.toString() ??
                                                      'Không có nhiệm vụ',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.primaryMedium,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // Kiểm tra xem nhiệm vụ có mới hay không
                                    // Nếu mới, hiển thị biểu tượng mới
                                    isNewTask(_tasks[index].createdAt ??
                                            DateTime.now())
                                        ? SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: Image.asset(
                                              'assets/images/new_icon.png',
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.error),
                                            ),
                                          )
                                        : Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: CustomPaint(
                                                  painter:
                                                      ProgressCirclePainter(
                                                    progress: _taskProgress[
                                                            _tasks[index].id] ??
                                                        0.0,
                                                    progressColor:
                                                        AppColors.taskProgress,
                                                    backgroundColor:
                                                        Colors.black,
                                                    strokeWidth: 4.0,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "${(normalizeProgress(_taskProgress[_tasks[index].id]) * 100).toInt()}%",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.taskProgress,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBarWidget(
          currentItem: _currentItem,
          onItemSelected: _onItemSelected,
          items: _navItems,
        ),
      ),
    );
  }
}
