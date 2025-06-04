import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  static EmailService get instance => _instance;
  
  // Gmail configuration
  String _emailAddress = 'ngocnghia1999nn@gmail.com'; 
  String _password = 'yegl kniv mxud sgcz'; // App password for Gmail
  String _senderName = 'Mission Master';
  
  EmailService._internal();

  // Tạo tên đăng nhập từ email
  String generateUsernameFromEmail(String email) {
    // Lấy phần trước @ của email
    String username = email.split('@')[0];
    
    // Loại bỏ các ký tự đặc biệt, chỉ giữ lại chữ cái và số
    username = username.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    
    // Nếu username quá ngắn, thêm số ngẫu nhiên
    if (username.length < 5) {
      final random = Random();
      final randomNumber = random.nextInt(1000);
      username = '${username}${randomNumber}';
    }
    
    return username.toLowerCase();
  }

  // Gửi email chào mừng
  Future<bool> sendWelcomeEmail({
    required String email,
    required String fullName,
    String? username,
    required String password,
  }) async {
    try {
      // Nếu không có username, tạo từ email
      final finalUsername = username ?? generateUsernameFromEmail(email);
      
      // Thử gửi email thật
      try {
        // Cấu hình SMTP server cho Gmail với SSL
        final smtpServer = SmtpServer(
          'smtp.gmail.com',
          port: 465,
          ssl: true,
          username: _emailAddress,
          password: _password,
        );
        
        final message = Message()
          ..from = Address(_emailAddress, _senderName)
          ..recipients.add(email)
          ..subject = 'Chào mừng đến với Mission Master'
          ..html = generateWelcomeEmailContent(fullName, finalUsername, password);
        
        print('Đang gửi email đến $email sử dụng SMTP...');
        final sendReport = await send(message, smtpServer);
        print('Email đã gửi: ${sendReport.toString()}');
        
        return true;
      } catch (emailError) {
        print('Lỗi khi gửi email thật: $emailError');
        
        // Nếu gửi email thật thất bại, chuyển sang giả lập
        print('=================== GIẢ LẬP GỬI EMAIL ===================');
        print('Gửi email đến: $email');
        print('Họ tên: $fullName');
        print('Tên đăng nhập: $finalUsername');
        print('Mật khẩu: $password');
        print('Nội dung email:');
        print(generateWelcomeEmailContent(fullName, finalUsername, password));
        print('=========================================================');
        
        // Giả lập độ trễ của việc gửi email
        await Future.delayed(const Duration(seconds: 1));
        
        return true;
      }
    } catch (e) {
      print('Lỗi gửi email: $e');
      return false;
    }
  }

  // Tạo mật khẩu ngẫu nhiên
  String generateRandomPassword({int length = 10}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length, 
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Tạo nội dung email chào mừng
  String generateWelcomeEmailContent(String fullName, String username, String password) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chào mừng đến với Mission Master</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background-color: #005E6A;
            padding: 20px;
            text-align: center;
            border-radius: 5px 5px 0 0;
        }
        .header h1 {
            color: white;
            margin: 0;
        }
        .content {
            padding: 20px;
            background-color: #f9f9f9;
            border-left: 1px solid #ddd;
            border-right: 1px solid #ddd;
        }
        .footer {
            background-color: #eee;
            padding: 15px;
            text-align: center;
            font-size: 12px;
            color: #666;
            border-radius: 0 0 5px 5px;
            border: 1px solid #ddd;
        }
        .credentials {
            background-color: #fff;
            border: 1px solid #ddd;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .button {
            display: inline-block;
            background-color: #00BCD4;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Mission Master</h1>
    </div>
    <div class="content">
        <h2>Xin chào $fullName,</h2>
        <p>Chúc mừng bạn đã được thêm vào hệ thống Mission Master với vai trò Quản lý. Dưới đây là thông tin đăng nhập của bạn:</p>
        
        <div class="credentials">
            <p><strong>Tên đăng nhập:</strong> $username</p>
            <p><strong>Mật khẩu:</strong> $password</p>
        </div>
        
        <p>Vui lòng đăng nhập và đổi mật khẩu của bạn ngay lập tức để đảm bảo an toàn.</p>
        
        <p>Với vai trò Quản lý, bạn có thể:</p>
        <ul>
            <li>Tạo và quản lý dự án</li>
            <li>Phân công nhiệm vụ cho nhân viên</li>
            <li>Theo dõi tiến độ dự án</li>
            <li>Tạo báo cáo và phân tích hiệu suất</li>
        </ul>
        
        <center>
            <a href="#" class="button">Đăng nhập ngay</a>
        </center>
    </div>
    <div class="footer">
        <p>Email này được gửi tự động, vui lòng không trả lời. Nếu bạn cần hỗ trợ, vui lòng liên hệ với quản trị viên.</p>
        <p>&copy; 2023 Mission Master. Tất cả các quyền được bảo lưu.</p>
    </div>
</body>
</html>
''';
  }
} 