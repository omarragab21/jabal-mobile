import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_theme.dart';

/// Shared setup for widget previews: Almarai theme, screenutil on the
/// 375 x 812 design frame, white page and a forced text direction.
Widget _wrap(Widget child, TextDirection direction) => ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  builder: (_, _) => Theme(
    data: AppTheme.light(),
    child: Directionality(
      textDirection: direction,
      child: ColoredBox(
        color: Colors.white,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  ),
);

/// Arabic / right-to-left (the default layout of the app).
Widget rtlWrapper(Widget child) => _wrap(child, TextDirection.rtl);

/// English / left-to-right.
Widget ltrWrapper(Widget child) => _wrap(child, TextDirection.ltr);
