import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Full-screen dim layer (70% #161616) with the design's 44pt spinner.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.overlay.withValues(alpha: 0.7),
      child: const Center(child: AppSpinner()),
    );
  }
}

/// Light track with a rotating green arc.
class AppSpinner extends StatefulWidget {
  const AppSpinner({super.key});

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _c,
      child: CustomPaint(
        size: Size.square(44.r),
        painter: _SpinnerPainter(strokeWidth: 4.r),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.strokeWidth});
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFF2F4F7);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.success;
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, track);
    canvas.drawArc(arcRect, -math.pi / 2, math.pi / 2, false, arc);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.strokeWidth != strokeWidth;
}
