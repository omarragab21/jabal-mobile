import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// White rounded card with a bold [title] and a chevron that folds [child].
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.open,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.textMdBold.copyWith(
                        color: AppColors.textDefault,
                      ),
                    ),
                  ),
                  Chevron(up: open),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// Thin chevron pointing up (open) or down (closed).
class Chevron extends StatelessWidget {
  const Chevron({super.key, required this.up, this.size = 20});

  final bool up;
  final double size;

  @override
  Widget build(BuildContext context) => RotatedBox(
    quarterTurns: up ? 2 : 0,
    child: SvgPicture.asset(
      'assets/icons/home/chevron_down.svg',
      width: size.w,
      height: size.w,
      colorFilter: const ColorFilter.mode(
        AppColors.textDefault,
        BlendMode.srcIn,
      ),
    ),
  );
}
