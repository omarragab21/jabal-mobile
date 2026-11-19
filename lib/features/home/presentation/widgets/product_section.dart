import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Section title at the start and an arrow at the end that opens the whole
/// section. The arrow points the way the language reads.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.seeAllLabel,
    this.onSeeAll,
  });

  final String title;

  /// Accessibility label of the arrow.
  final String seeAllLabel;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final ltr = Directionality.of(context) == TextDirection.ltr;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textMdBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Semantics(
          button: true,
          label: seeAllLabel,
          child: InkResponse(
            onTap: onSeeAll,
            radius: 20.r,
            // The asset points left (Arabic); mirror it for English.
            child: Transform.flip(
              flipX: ltr,
              child: SvgPicture.asset(
                'assets/icons/home/arrow_forward.svg',
                width: 24.r,
                height: 24.r,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A [SectionHeader] over one sideways-scrolling row of [cards], each
/// [cardWidth] wide.
class ProductSection extends StatelessWidget {
  const ProductSection({
    super.key,
    required this.title,
    required this.seeAllLabel,
    required this.cards,
    this.onSeeAll,
    this.cardWidth = 160,
  });

  final String title;
  final String seeAllLabel;
  final List<Widget> cards;
  final VoidCallback? onSeeAll;

  /// In design points (scaled with the screen width).
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SectionHeader(
            title: title,
            seeAllLabel: seeAllLabel,
            onSeeAll: onSeeAll,
          ),
        ),
        SizedBox(height: 18.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) SizedBox(width: 12.w),
                SizedBox(width: cardWidth.w, child: cards[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
