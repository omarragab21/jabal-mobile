import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../images/app_image_cache.dart';
import '../theme/app_colors.dart';

/// A picture that never breaks the layout and is fetched only once: a soft
/// placeholder while it loads, when the source is missing and when it cannot
/// be loaded. [url] is a web address, or an `assets/...` path for a picture
/// bundled with the app.
///
/// Web pictures go through [AppImageCacheManager] (disk cache) and are
/// decoded no bigger than the space they are shown in, so a grid of products
/// holds small bitmaps in memory, not the full-size originals.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholderColor = AppColors.backgroundBody,
  });

  final String? url;
  final BoxFit fit;
  final Color placeholderColor;

  /// Never decode wider than this, whatever the screen (a 4K phone showing a
  /// full-width picture does not need more).
  static const int _maxDecodeWidth = 1080;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: placeholderColor,
      child: const SizedBox.expand(),
    );
    final source = url;
    if (source == null || source.isEmpty) return placeholder;
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => placeholder,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final width = constraints.maxWidth;
        // Unbounded space (inside a scroll view) gives no size to decode to.
        final decodeWidth = width.isFinite
            ? math.min((width * dpr).ceil(), _maxDecodeWidth)
            : null;
        // A picture is a pile of pixels: repainting it must not repaint what
        // is around it, and the other way round.
        return RepaintBoundary(
          child: CachedNetworkImage(
            imageUrl: source,
            cacheManager: AppImageCacheManager.instance,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            memCacheWidth: decodeWidth,
            fadeInDuration: const Duration(milliseconds: 150),
            fadeOutDuration: Duration.zero,
            // Same address, same picture: keep showing it while it is
            // re-resolved instead of blinking to the placeholder.
            useOldImageOnUrlChange: true,
            placeholder: (_, _) => placeholder,
            errorWidget: (_, _, _) => placeholder,
          ),
        );
      },
    );
  }
}
