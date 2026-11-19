import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// White 42pt circle with a thin border that floats over the picture.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.label,
  });

  final Widget child;
  final VoidCallback onTap;

  /// Accessibility label.
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: AppColors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.cardBorder)),
      child: InkResponse(
        onTap: onTap,
        child: SizedBox(
          width: 42.r,
          height: 42.r,
          child: Center(child: child),
        ),
      ),
    ),
  );
}
