import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/src/icon_data.dart';

class LucideIconsExtension {
  static Widget toWeight(
    IconData icon, {
    double? size,
    Color? color,
    LucideIconsWeight? weight,
  }) {
    return Icon(
      LucideIconData(icon.codePoint, fontFamily: _getFont(weight)),
      size: size,
      color: color,
    );
  }

  static _getFont(
    LucideIconsWeight? weight,
  ) {
    switch (weight) {
      case LucideIconsWeight.w700:
        return 'Lucide700';
      case LucideIconsWeight.w600:
        return 'Lucide600';
      case LucideIconsWeight.w500:
        return 'Lucide500';
      case LucideIconsWeight.w400:
        return 'Lucide400';
      case LucideIconsWeight.w300:
        return 'Lucide300';
      case LucideIconsWeight.w200:
        return 'Lucide200';
      case LucideIconsWeight.w100:
        return 'Lucide100';
      default:
        return 'Lucide400';
    }
  }
}

enum LucideIconsWeight {
  w700,
  w600,
  w500,
  w400,
  w300,
  w200,
  w100,
}

/// The best ratio strokeWidth is size /6 or size /8
class LucideIconWidget extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final double? strokeWidth;
  final LucideIconsWeight? weight;
  final bool isCustomPaint = false;

  const LucideIconWidget(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.strokeWidth = 0.0,
    this.weight,
  }) : super(key: key);
  LucideIconWidget.customPaint(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.strokeWidth,
    this.weight = null,
  });

  @override
  Widget build(BuildContext context) {
    if (isCustomPaint) {
      return CustomPaint(
        painter: _LucideIconPainter(
          icon: icon,
          color: color ?? Colors.black,
          strokeWidth: strokeWidth ?? 0.0,
        ),
        size: Size(size ?? 24, size ?? 24),
      );
    }
    return LucideIconsExtension.toWeight(
      icon,
      size: size,
      color: color,
      weight: weight,
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
