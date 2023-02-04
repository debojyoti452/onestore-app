import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Divider Widget
Widget dividerWidget({
  double height = 1,
  Color color = Colors.grey,
  double indent = 0,
  double endIndent = 0,
}) {
  return Divider(
    height: height,
    color: color,
    indent: indent,
    endIndent: endIndent,
  );
}

/// Separator Widget
Widget separatorWidget({
  double? height,
  Color? color,
}) {
  return Container(
    height: height ?? 12.h,
    color: color,
  );
}
