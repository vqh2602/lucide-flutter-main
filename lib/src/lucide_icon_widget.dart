import 'package:flutter/material.dart';

/// The best ratio strokeWidth is size /6 or size /8
class LucideIconWidget extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const LucideIconWidget({
    Key? key,
    required this.icon,
    this.size,
    this.color,
    this.strokeWidth = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sử dụng CustomPaint để vẽ icon với độ đậm viền tùy chỉnh
    return CustomPaint(
      size: Size(size ?? 24.0, size ?? 24.0),
      painter: _LucideIconPainter(
        icon: icon,
        color: color ?? Theme.of(context).iconTheme.color ?? Colors.black,
        strokeWidth: strokeWidth ?? 0.0,
      ),
    );
  }
}

class _LucideIconPainter extends CustomPainter {
  final IconData icon;
  final Color color;
  final double strokeWidth;

  _LucideIconPainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
          fontWeight: strokeWidth > 2.0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: size.width);

    // Vẽ nhiều lần với offset nhỏ để tạo hiệu ứng đậm viền
    if (strokeWidth > 2.0) {
      final double offset = (strokeWidth - 2.0) * 0.3;

      // Vẽ nhiều lần với offset nhỏ để tạo hiệu ứng đậm viền
      for (double dx = -offset; dx <= offset; dx += offset) {
        for (double dy = -offset; dy <= offset; dy += offset) {
          if (dx == 0 && dy == 0) continue; // Bỏ qua vị trí chính giữa

          canvas.save();
          canvas.translate(
            (size.width - textPainter.width) / 2 + dx,
            (size.height - textPainter.height) / 2 + dy,
          );
          textPainter.paint(canvas, Offset.zero);
          canvas.restore();
        }
      }
    }

    // Vẽ icon chính
    canvas.save();
    canvas.translate(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LucideIconPainter oldDelegate) {
    return oldDelegate.icon != icon ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
