import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// The app's picture cache on disk: every picture is downloaded once and
/// kept for a month, so lists and product pages never fetch the same picture
/// twice (not while scrolling, not after a restart). Old pictures are dropped
/// first when there are more than [maxObjects].
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  AppImageCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: maxObjects,
        ),
      );

  static const String key = 'drJabelImages';
  static const int maxObjects = 400;

  /// The one cache of the app (a variable so a test can swap in another).
  static BaseCacheManager instance = AppImageCacheManager._();

  /// In memory: the decoded pictures Flutter keeps for what is on screen and
  /// just left it. A bit more than the default 100MB, since the shop is all
  /// pictures.
  static void configureMemoryCache() {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSizeBytes = 200 << 20;
    cache.maximumSize = 600;
  }

  /// Starts downloading [urls] now, so they are ready when their page opens
  /// (the next pictures of a gallery).
  static Future<void> precache(BuildContext context, Iterable<String> urls) =>
      Future.wait([
        for (final url in urls)
          if (url.isNotEmpty && !url.startsWith('assets/'))
            precacheImage(
              CachedNetworkImageProvider(url, cacheManager: instance),
              context,
            ).catchError((Object _) {}),
      ]);
}
