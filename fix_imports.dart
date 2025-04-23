import 'dart:io';

void main() async {
  // Đường dẫn gốc của dự án
  final projectRoot = '/home/tripleng/Workspace/Study/3/HK2/LTDD/project/mission_master';
  
  // Thư mục features chứa các file UI
  final featuresDir = Directory('$projectRoot/lib/features');
  
  // Danh sách các file cần sửa
  final filesToFix = await _findDartFiles(featuresDir);
  
  // Đường dẫn cũ và mới
  final oldPaths = [
    'package:mission_master/core/config/database_config.dart',
    'package:mission_master/core/services/database_service.dart',
  ];
  
  final newPaths = [
    'package:mission_master/config/database_config.dart',
    'package:mission_master/core/services/database_service.dart',
  ];
  
  // Sửa các file
  for (final file in filesToFix) {
    await _fixImports(file, oldPaths, newPaths);
  }
  
  print('Đã sửa xong ${filesToFix.length} file.');
}

Future<List<File>> _findDartFiles(Directory dir) async {
  final files = <File>[];
  
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }
  
  return files;
}

Future<void> _fixImports(File file, List<String> oldPaths, List<String> newPaths) async {
  try {
    final content = await file.readAsString();
    var newContent = content;
    
    for (var i = 0; i < oldPaths.length; i++) {
      newContent = newContent.replaceAll(oldPaths[i], newPaths[i]);
    }
    
    if (content != newContent) {
      await file.writeAsString(newContent);
      print('Đã sửa file: ${file.path}');
    }
  } catch (e) {
    print('Lỗi khi sửa file ${file.path}: $e');
  }
}
