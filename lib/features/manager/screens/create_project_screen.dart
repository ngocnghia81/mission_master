import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mission_master/core/theme/app_colors.dart';
import 'package:mission_master/features/home/screens/calendar_task_screen.dart';
import 'package:mission_master/features/projects/screens/project_list_screen.dart';
import 'package:mission_master/shared/widgets/app_bar_widget.dart';
import 'package:mission_master/shared/widgets/bottom_nav_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:mission_master/core/models/user.dart';
import 'package:mission_master/core/models/project.dart';
import 'package:mission_master/core/models/project_membership.dart';
import 'package:mission_master/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class CreateProjectScreen extends StatefulWidget {
  final User currentUser;

  const CreateProjectScreen({Key? key, required this.currentUser})
      : super(key: key);

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _status = ProjectStatus.notStarted.value;
  File? _logoFile;
  String? _logoBase64;

  bool _isLoading = false;
  List<User> _employees = [];
  List<User> _selectedEmployees = [];
  int? _leaderId;

  // Theo dõi bước hiện tại (1: thông tin dự án, 2: chọn nhân viên)
  int _currentStep = 1;

  // Bottom navigation
  BottomNavItem _currentNavItem = BottomNavItem.projects;

  // Danh sách bottom nav bar
  final List<BottomNavItem> _navItems = [
    BottomNavItem.home,
    BottomNavItem.projects,
    BottomNavItem.tasks,
    BottomNavItem.profile,
  ];

  // Kiểm soát trạng thái tìm kiếm nhân_currentNavItem  viên
  final _searchController = TextEditingController();
  List<User> _filteredEmployees = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final api = ApiService.instance;

      // Lấy danh sách người dùng từ API
      final usersData = await api.getUsers();

      // Lọc ra những người dùng có role là employee (role_id = 3)
      final employeeUsers =
          usersData.where((user) => user['role_id'] == 3).toList();

      setState(() {
        _employees = employeeUsers.map((e) => User.fromMap(e)).toList();
        _filteredEmployees = _employees;
      });
    } catch (e) {
      print('Error loading employees: $e');
      // Hiển thị lỗi cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách nhân viên: $e')),
      );
    }
  }

  Future<void> _pickLogo() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _logoFile = file;
          _logoBase64 = 'data:image/png;base64,$base64Image';
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Cập nhật ngày kết thúc nếu ngày bắt đầu lớn hơn
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _searchEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = _employees.where((employee) {
          return employee.fullName
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              employee.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleEmployee(User employee) {
    setState(() {
      if (_selectedEmployees.contains(employee)) {
        _selectedEmployees.remove(employee);
        // Nếu người bị xóa là leader, xóa leader
        if (_leaderId == employee.id) {
          _leaderId = null;
        }
      } else {
        _selectedEmployees.add(employee);
      }
    });
  }

  void _setLeader(User employee) {
    if (!_selectedEmployees.contains(employee)) {
      return; // Chỉ có thể đặt leader cho người đã được chọn
    }

    setState(() {
      _leaderId = _leaderId == employee.id ? null : employee.id;
    });
  }

  void _moveToNextStep() {
    if (_currentStep == 1) {
      // Xác thực form bước 1
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 2;
        });
      }
    }
  }

  void _moveBackToPreviousStep() {
    if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _handleNavItemSelected(BottomNavItem item) {
    if (item != _currentNavItem) {
      Navigator.of(context).pop();
      // Navigate to the appropriate screen based on the selected item
      if (item == BottomNavItem.home) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (item == BottomNavItem.tasks) {
        Navigator.of(context).pushReplacementNamed('/tasks');
      }
    }
  }

  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final api = ApiService.instance;

        // 1. Tạo dự án mới thông qua API
        final projectData = {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'start_date': _startDate.toIso8601String(),
          'end_date': _endDate.toIso8601String(),
          'status': _status,
          'manager_id': widget.currentUser.id,
          'logo': null, // Có thể thêm tính năng upload logo sau
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          // Thêm thông tin về các thành viên dự án
          'members': [
            // Người quản lý (người tạo dự án)
            {
              'user_id': widget.currentUser.id,
              'role': 'manager',
              'is_leader': true
            },
            // Các nhân viên được chọn
            ..._selectedEmployees
                .map((employee) => {
                      'user_id': employee.id,
                      'role': 'member',
                      'is_leader': _leaderId == employee.id
                    })
                .toList()
          ]
        };

        // Gọi API để tạo dự án mới
        final createdProject = await api.createProject(projectData);

        // Hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dự án đã được tạo thành công')),
          );

          // Chuyển hướng đến màn hình danh sách dự án
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProjectListScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo dự án: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F3),
      appBar: AppBarWidget(
        title: 'Thêm dự án',
        showBackButton: true,
        onBackPressed: _currentStep == 2 ? _moveBackToPreviousStep : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentStep == 1
              ? _buildStep1()
              : _buildStep2(),
      bottomNavigationBar: BottomNavBarWidget(
        currentItem: _currentNavItem,
        onItemSelected: _handleNavItemSelected,
        items: _navItems,
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown loại dự án - Cố định là "Công việc"
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 24,
                    color: AppColors.primaryDark,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Thêm dự án',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark.withOpacity(0.6),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Công việc',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColors.primaryDark),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Tên dự án
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Text(
                      'Tên dự án',
                      style: TextStyle(
                        color: AppColors.primaryDark.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(
                        color: AppColors.primaryDark.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên dự án';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Mô tả
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mô tả',
                    style: TextStyle(
                      color: AppColors.primaryDark.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Mô tả dự án...',
                      hintStyle: TextStyle(
                        color: AppColors.primaryDark.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Ngày bắt đầu
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 20,
                      color: AppColors.primaryDark,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày bắt đầu',
                          style: TextStyle(
                            color: AppColors.primaryDark.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${DateFormat('dd').format(_startDate)} tháng ${DateFormat('M').format(_startDate)}, ${DateFormat('yyyy').format(_startDate)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_drop_down, color: AppColors.primaryDark),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Ngày kết thúc
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 20,
                      color: AppColors.primaryDark,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày kết thúc',
                          style: TextStyle(
                            color: AppColors.primaryDark.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${DateFormat('dd').format(_endDate)} tháng ${DateFormat('M').format(_endDate)}, ${DateFormat('yyyy').format(_endDate)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_drop_down, color: AppColors.primaryDark),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Logo dự án
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _logoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _logoFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.apps,
                                size: 36,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logo dự án',
                        style: TextStyle(
                          color: AppColors.primaryDark.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _logoFile != null
                            ? _logoFile!.path.split('/').last
                            : 'Shop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _pickLogo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMedium,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Thay đổi'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Nút tiếp tục
            Center(
              child: ElevatedButton(
                onPressed: _moveToNextStep,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                  backgroundColor: AppColors.primaryMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Tiếp',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tìm kiếm
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                )
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm nhân viên...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    onChanged: _searchEmployees,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Danh sách nhân viên
          Expanded(
            child: _filteredEmployees.isEmpty
                ? Center(
                    child: Text('Không tìm thấy nhân viên'),
                  )
                : ListView.builder(
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = _filteredEmployees[index];
                      final isSelected = _selectedEmployees.contains(employee);

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: index == 2
                              ? badges.Badge(
                                  badgeContent: Text(
                                    '39×39',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                  badgeStyle: badges.BadgeStyle(
                                    shape: badges.BadgeShape.square,
                                    badgeColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  position: badges.BadgePosition.bottomStart(),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                          title: Text(
                            employee.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          subtitle: Text(
                            index == 0
                                ? 'Marketing (3)'
                                : index == 1
                                    ? 'Nhân sự'
                                    : index == 2
                                        ? 'Kĩ thuật'
                                        : employee.role,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Container(
                            width: 60,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => _toggleEmployee(employee),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? Colors.red.shade400
                                    : Color(0xFF26BFBF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 0,
                                ),
                                minimumSize: Size(60, 30),
                              ),
                              child: Text(
                                isSelected ? 'Xóa' : 'Thêm',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Đã chọn
          if (_selectedEmployees.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              'Đã chọn:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                children: _selectedEmployees.map((employee) {
                  final isLeader = _leaderId == employee.id;
                  final index = _selectedEmployees.indexOf(employee);

                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          onTap: () => _setLeader(employee),
                          child: Container(
                            color: isLeader
                                ? Colors.blue.withOpacity(0.05)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isLeader
                                      ? Colors.teal.shade100
                                      : Colors.blue.shade100,
                                  child: Icon(
                                    isLeader ? Icons.stars : Icons.person,
                                    color: isLeader ? Colors.teal : Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            employee.fullName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                          if (isLeader)
                                            Container(
                                              margin: EdgeInsets.only(left: 8),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.teal
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Nhóm trưởng',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.teal,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        isLeader ? 'Tester' : 'Developer',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () => _toggleEmployee(employee),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 0,
                                      ),
                                      minimumSize: Size(60, 30),
                                    ),
                                    child: Text(
                                      'Xóa',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (index < _selectedEmployees.length - 1)
                        Divider(
                          color: Colors.grey.withOpacity(0.3),
                          thickness: 1,
                          height: 1,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],

          SizedBox(height: 16),

          // Nút thêm
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_selectedEmployees.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Vui lòng chọn ít nhất một nhân viên')),
                  );
                } else if (_leaderId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Vui lòng chọn nhóm trưởng bằng cách nhấn vào một nhân viên')),
                  );
                } else {
                  _saveProject();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                backgroundColor: AppColors.primaryMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                'Thêm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
