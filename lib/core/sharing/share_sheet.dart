import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'share_target.dart';

/// How a target looks: a white glyph on a coloured (or gradient) circle.
class _Look {
  const _Look({
    this.asset,
    this.color,
    this.gradient,
    this.icon,
    this.glyph,
    this.size = 28,
    this.height,
  });

  final String? asset;
  final Color? color;
  final Gradient? gradient;
  final IconData? icon;
  final Color? glyph;

  /// Width of the glyph inside the 56pt circle (its side, when [height] is
  /// not given).
  final double size;
  final double? height;
}

const _brandBlue = Color(0xFF0866FF);

_Look _look(ShareTarget target) => switch (target) {
  ShareTarget.whatsapp => const _Look(
    asset: 'assets/icons/account/whatsapp.svg',
    color: Color(0xFF25D366),
  ),
  ShareTarget.facebook => const _Look(
    asset: 'assets/icons/account/facebook.svg',
    color: _brandBlue,
  ),
  ShareTarget.instagram => const _Look(
    asset: 'assets/icons/account/instagram.svg',
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [Color(0xFFF77737), Color(0xFFFD1D1D), Color(0xFF833AB4)],
      stops: [0.22, 0.55, 1],
    ),
  ),
  ShareTarget.snapchat => const _Look(
    asset: 'assets/icons/share/snapchat.svg',
    color: Color(0xFFFFFC00),
  ),
  ShareTarget.messenger => const _Look(
    asset: 'assets/icons/account/messenger.svg',
    color: _brandBlue,
    // The bolt is a wide, flat glyph (16 x 9, as drawn in the design): at the
    // 28pt square of the others it fills the circle.
    size: 16,
    height: 9,
  ),
  ShareTarget.x => const _Look(
    asset: 'assets/icons/account/x.svg',
    color: Color(0xFF000000),
  ),
  ShareTarget.copyLink => const _Look(
    asset: 'assets/icons/account/link.svg',
    color: AppColors.primary,
  ),
  ShareTarget.more => const _Look(
    icon: Icons.more_horiz,
    color: AppColors.buttonSecondary,
    glyph: AppColors.textDefault,
  ),
};

String _labelKey(ShareTarget target) => switch (target) {
  ShareTarget.whatsapp => 'whatsapp',
  ShareTarget.facebook => 'facebook',
  ShareTarget.instagram => 'instagram',
  ShareTarget.snapchat => 'snapchat',
  ShareTarget.messenger => 'messenger',
  ShareTarget.x => 'x',
  ShareTarget.copyLink => 'copy_link',
  ShareTarget.more => 'more',
};

/// The share sheet: a bottom sheet (handle, close button) with the [title] and
/// the share targets in two rows of four. Returns the target the customer
/// picked, or null when the sheet was dismissed. One sheet for every share.
Future<ShareTarget?> showShareSheet(
  BuildContext context, {
  required String title,
}) => showModalBottomSheet<ShareTarget>(
  context: context,
  isScrollControlled: true,
  barrierColor: AppColors.overlay.withValues(alpha: 0.35),
  backgroundColor: Colors.transparent,
  builder: (sheet) => _ShareSheet(title: title),
);

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ShareTarget.values.sublist(0, 4),
      ShareTarget.values.sublist(4),
    ];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 60.h,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 24.h),
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 20.h,
                      start: -8.w,
                      child: Semantics(
                        button: true,
                        label: 'share.close'.tr(context: context),
                        child: GestureDetector(
                          key: const ValueKey('share-close'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: const BoxDecoration(
                              color: AppColors.neutral200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 22.r,
                              color: AppColors.textDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.textLgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              SizedBox(height: 24.h),
              for (var r = 0; r < rows.length; r++) ...[
                if (r > 0) SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final target in rows[r])
                      _ShareItem(
                        key: ValueKey('share-${target.name}'),
                        target: target,
                        label: 'share.${_labelKey(target)}'.tr(
                          context: context,
                        ),
                        onTap: () => Navigator.of(context).pop(target),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareItem extends StatelessWidget {
  const _ShareItem({
    super.key,
    required this.target,
    required this.label,
    required this.onTap,
  });

  final ShareTarget target;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final look = _look(target);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 70.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: look.color,
                gradient: look.gradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: look.asset != null
                  ? SvgPicture.asset(
                      look.asset!,
                      width: look.size.r,
                      height: (look.height ?? look.size).r,
                      fit: BoxFit.contain,
                    )
                  : Icon(look.icon, size: look.size.r, color: look.glyph),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.textDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
