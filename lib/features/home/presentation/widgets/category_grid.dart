import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';

/// What one tile of the category grid shows. Give [imageAsset] for a bundled
/// picture (the "all categories" tile) or [imageUrl] for a remote one.
class CategoryTileData {
  const CategoryTileData({
    required this.label,
    this.imageUrl,
    this.imageAsset,
    this.onTap,
  });

  final String label;
  final String? imageUrl;
  final String? imageAsset;
  final VoidCallback? onTap;
}

/// Rounded square picture with the category name under it.
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.data});

  final CategoryTileData data;

  @override
  Widget build(BuildContext context) {
    final asset = data.imageAsset;
    return Semantics(
      button: data.onTap != null,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.backgroundBody,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                foregroundDecoration: BoxDecoration(
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: asset != null
                    ? Image.asset(asset, fit: BoxFit.cover)
                    : AppNetworkImage(url: data.imageUrl),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              data.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

/// Tiles in rows of [columns]; a row is as tall as its tallest label.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.tiles, this.columns = 4});

  final List<CategoryTileData> tiles;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final gap = 10.w;
    return Column(
      children: [
        for (var start = 0; start < tiles.length; start += columns) ...[
          if (start > 0) SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = start; i < start + columns; i++) ...[
                if (i > start) SizedBox(width: gap),
                Expanded(
                  child: i < tiles.length
                      ? CategoryTile(data: tiles[i])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
