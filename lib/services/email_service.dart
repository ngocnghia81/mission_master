import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  static EmailService get instance => _instance;
  
  // Cấu hình SMTP cho Outlook - Thay đổi thông tin này theo tài khoản email của bạn
  String _emailAddress = 'ngocnghia2004nn@outlook.com'; // Thay đổi thành email Outlook của bạn
  String _password = 'Lshsg47@'; // Thay đổi thành mật khẩu Outlook của bạn
  String _senderName = 'Mission Master';
  
  // Cấu hình SMTP server cho Outlook
  final String _smtpHost = 'smtp-mail.outlook.com';
  final int _smtpPort = 587;
  final bool _smtpSecure = false; // Outlook sử dụng STARTTLS

  EmailService._internal();

  // Gửi email chào mừng
  Future<bool> sendWelcomeEmail({
    required String email,
    required String fullName,
    required String username,
    required String password,
  }) async {
    try {
      // Kiểm tra xem đã cấu hình email chưa
      if (_emailAddress == 'your.email@outlook.com' || _password == 'your-password') {
        print('Email not properly configured. Using dummy email sending...');
        // Giả lập gửi email nếu chưa cấu hình
        print('=================== GIẢ LẬP GỬI EMAIL ===================');
        print('Gửi email đến: $email');
        print('Họ tên: $fullName');
        print('Tên đăng nhập: $username');
        print('Mật khẩu: $password');
        print('Nội dung email:');
        print(generateWelcomeEmailContent(fullName, username, password));
        print('=========================================================');
        
        // Giả lập độ trễ của việc gửi email
        await Future.delayed(const Duration(seconds: 1));
        
        return true;
      }
      
      // Cấu hình SMTP server cho Outlook
      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        ssl: _smtpSecure,
        username: _emailAddress,
        password: _password,
        allowInsecure: true, // Cho phép kết nối không bảo mật (cần thiết cho một số cấu hình)
      );
      
      // Tạo message
      final message = Message()
        ..from = Address(_emailAddress, _senderName)
        ..recipients.add(email)
        ..subject = 'Chào mừng đến với Mission Master'
        ..html = generateWelcomeEmailContent(fullName, username, password);
      
      // Gửi email
      print('Sending email to $email using Outlook SMTP...');
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
      
      return true;
    } catch (e) {
      print('Error sending email: $e');
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