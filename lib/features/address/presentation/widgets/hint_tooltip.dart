import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dark speech bubble with a small arrow on top. The arrow sits [arrowInset]
/// from the start edge, or in the middle when it is null.
class HintTooltip extends StatelessWidget {
  const HintTooltip({
    super.key,
    required this.text,
    this.width,
    this.arrowInset,
    this.textAlign,
    this.onTap,
  });

  final String text;

  /// In design points; null = as wide as the text needs.
  final double? width;

  /// Distance of the arrow from the start edge, in design points.
  final double? arrowInset;
  final TextAlign? textAlign;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final arrow = SizedBox(
      width: 12.w,
      height: 5.r,
      child: CustomPaint(painter: _ArrowPainter(AppColors.textDisplay)),
    );
    final bubble = Container(
      width: width?.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.textDisplay,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: AppTextStyles.textXsRegular.copyWith(color: AppColors.white),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: arrowInset == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: arrowInset?.w ?? 0),
            child: arrow,
          ),
          if (width != null) bubble else IntrinsicWidth(child: bubble),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}
