import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/home_banner.dart';

/// Swipeable banners; the next one peeks in from the side. With [autoPlay]
/// it moves on by itself every [interval].
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.banners,
    this.onTap,
    this.autoPlay = true,
    this.interval = const Duration(seconds: 5),
  });

  final List<HomeBanner> banners;
  final ValueChanged<HomeBanner>? onTap;
  final bool autoPlay;
  final Duration interval;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  // 343pt card + 8pt gap on the 375pt frame.
  final PageController _controller = PageController(
    viewportFraction: 351 / 375,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.banners.length != widget.banners.length) {
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (!widget.autoPlay || widget.banners.length < 2) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_controller.hasClients) return;
      final next =
          ((_controller.page ?? 0).round() + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180.h,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.banners.length,
        itemBuilder: (_, index) {
          final banner = widget.banners[index];
          final tappable = widget.onTap != null && banner.link != null;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Semantics(
              label: banner.title,
              image: true,
              button: tappable,
              child: GestureDetector(
                onTap: tappable ? () => widget.onTap!(banner) : null,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  foregroundDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral200),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: AppNetworkImage(url: banner.imageUrl),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
