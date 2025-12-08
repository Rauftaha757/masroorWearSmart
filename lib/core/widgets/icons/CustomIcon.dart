import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CustomIcon({
    Key? key,
    required this.icon,
    this.color,
    this.size,
    this.width,
    this.height,
    this.onTap,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      color: color ?? Colors.grey[600],
      size: size ?? 24.sp,
    );

    // If width and height are specified, wrap in SizedBox
    if (width != null || height != null) {
      iconWidget = SizedBox(width: width, height: height, child: iconWidget);
    }

    // If padding is specified, wrap in Padding
    if (padding != null) {
      iconWidget = Padding(padding: padding!, child: iconWidget);
    }

    // If margin is specified, wrap in Container
    if (margin != null) {
      iconWidget = Container(margin: margin!, child: iconWidget);
    }

    // If onTap is specified, wrap in GestureDetector
    if (onTap != null) {
      iconWidget = GestureDetector(onTap: onTap, child: iconWidget);
    }

    return iconWidget;
  }
}

// Predefined icon styles for common use cases
class IconStyles {
  static const Color primary = Color(0xFF1A1A1A);
  static const Color secondary = Color(0xFF6B7280);
  static const Color accent = Color(0xFF196585);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF9CA3AF);
}

// Common icon sizes
class IconSizes {
  static double get small => 16.sp;
  static double get medium => 24.sp;
  static double get large => 32.sp;
  static double get extraLarge => 48.sp;
}

// Common icon dimensions
class IconDimensions {
  static double get small => 24.w;
  static double get medium => 32.w;
  static double get large => 48.w;
  static double get extraLarge => 64.w;
}
