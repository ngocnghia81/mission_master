import 'package:flutter/material.dart';
import 'dart:math' as math;

// CustomPainter để vẽ biểu đồ vòng tròn
class ProgressCirclePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  ProgressCirclePainter({
    required this.progress,
    this.progressColor = Colors.green, // Màu mặc định
    this.backgroundColor = const Color(0xFFEEEEEE), // Màu nền mặc định
    this.strokeWidth = 3.0, // Độ dày của vòng tròn
  }) {
    assert(progress >= 0 && progress <= 1, 'Progress must be between 0 and 1');
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Vẽ vòng tròn nền
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Vẽ phần progress
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Bắt đầu từ góc -90 độ
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// Cách sử dụng trong widget
// Stack(
//   alignment: Alignment.center,
//   children: [
//     SizedBox(
//       width: 100,
//       height: 100,
//       child: CustomPaint(
//         painter: ProgressCirclePainter(progress: 0.6), <---- Thay đổi giá trị này để điều chỉnh phần trăm
//       ),
//     ),
//     const Text(
//       '60%', // phần trăm công việc
//       style: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: Color(0xFFFFA726),
//       ),
//     ),
//   ],
// ),
