import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';

/// A section card: its photo under a 30% dark veil with the name on top.
/// 160 x 110 in the design; it fills the width its parent gives it.
class SectionTile extends StatelessWidget {
  const SectionTile({
    super.key,
    required this.name,
    required this.imageUrl,
    this.onTap,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.r);
    return Semantics(
      button: onTap != null,
      label: name,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.neutral200,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 160 / 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    url: imageUrl,
                    placeholderColor: AppColors.neutral200,
                  ),
                  const ColoredBox(color: Color(0x4D161616)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 12.h),
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textMdBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two columns of [SectionTile]s: 16pt side margins, 23pt between the
/// columns and 16pt between the rows.
class SectionsGrid extends StatelessWidget {
  const SectionsGrid({super.key, required this.tiles, this.padding});

  final List<Widget> tiles;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final rows = (tiles.length / 2).ceil();
    return ListView.separated(
      padding: padding,
      itemCount: rows,
      separatorBuilder: (_, _) => SizedBox(height: 16.h),
      itemBuilder: (_, row) => Row(
        children: [
          Expanded(child: tiles[row * 2]),
          SizedBox(width: 23.w),
          Expanded(
            child: row * 2 + 1 < tiles.length
                ? tiles[row * 2 + 1]
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
